BEGIN;

SELECT _v.register_patch('30-move-partition-bookkeeping' , ARRAY['1-partitioning','28-compress-sequence-data','29-fix-partitioning','30-drop-clonelib-trigger'], NULL );

/*
 * Part I: Metagenomic Sequences
 *
 */
ALTER TABLE core.metagenomic_sequences_template SET SCHEMA partitions;
ALTER TABLE core.metagenomic_partitions SET SCHEMA partitions;
ALTER SEQUENCE core.mg_partition_seq SET SCHEMA partitions;
ALTER FUNCTION core.create_mg_partition(text) SET SCHEMA partitions;
ALTER FUNCTION core.rebuild_mg_view() SET SCHEMA partitions;
ALTER FUNCTION core.insert_into_correct_mg_partition() SET SCHEMA partitions;
ALTER FUNCTION core.update_correct_mg_partition() SET SCHEMA partitions;
ALTER FUNCTION core.delete_from_correct_mg_partition() SET SCHEMA partitions;

CREATE OR REPLACE FUNCTION partitions.insert_into_correct_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, sample_name, active, included INTO this_partition FROM partitions.metagenomic_partitions WHERE sample_name = NEW.sample_name; 
    IF this_partition IS NULL THEN 
      PERFORM partitions.create_mg_partition(NEW.sample_name);
      RAISE NOTICE 'New partition % created', NEW.sample_name;
      SELECT partition_id, sample_name, active, included INTO this_partition FROM partitions.metagenomic_partitions WHERE sample_name = NEW.sample_name;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE EXCEPTION 'partition % is inactive.', this_partition.sample_name
        USING HINT = 'Activate partition with UPDATE partitions.metagenomic_partitions SET active = TRUE WHERE sample_name = [sample name]'; 
    END IF;

    insertSql := 'INSERT INTO partitions.sample_' || CAST(this_partition.partition_id as text) || ' ';
    FOR field IN SELECT * FROM skeys(insertRecord) LOOP
      rowOrder := rowOrder || field || ', ';
      IF (insertRecord->field::text) IS NULL THEN
        insertValues := insertValues || ' DEFAULT, ';
      ELSE
        insertValues := insertValues || E'\'' || (insertRecord->field::text) || E'\'' || ', ' ;
      END IF;
    END LOOP;
    insertValues := trim(trailing ', ' from insertValues) || ');';
    rowOrder := trim(trailing ', ' from rowOrder) || ') ';
    --RAISE NOTICE 'INSERT: % - % - %', insertSql, rowOrder, insertValues;
    insertSql := insertSql || rowOrder || insertValues;
    EXECUTE insertSql;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.update_correct_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, sample_name, active, included INTO this_partition FROM partitions.metagenomic_partitions WHERE sample_name = NEW.sample_name; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE 'partition % is inactive.', this_partition.sample_name
        USING HINT = 'Activate partition with UPDATE partitions.metagenomic_partitions SET active = TRUE WHERE sample_name = [sample name]';
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.sample_name
        USING HINT = 'To include: SELECT partitions.rebuild_mg_view();';
      RETURN NULL; 
    END IF;

    updateSql := 'UPDATE partitions.sample_' || CAST(this_partition.partition_id AS text) || ' SET ';
    FOR field IN SELECT * FROM skeys(updateRecord) LOOP
      IF (updateRecord->field::text) IS NOT NULL THEN
        updateValues := updateValues || field || E' = \'' || (updateRecord->field::text) || E'\'' || ', ' ;
      END IF;
    END LOOP;
    updateValues := trim(trailing ', ' from updateValues);
    whereClause := ' WHERE ' ||
                   E'did = \'' || OLD.did || E'\' AND ' || 
                   E'did_auth = \'' || OLD.did_auth || E'\' AND ' ||
                   E'sample_name = \'' || OLD.sample_name || E'\' AND ' ||
                   E'study = \'' || OLD.study || E'\';';
    updateSql := updateSql || updateValues  || whereClause;
    --RAISE NOTICE 'UPDATE: %', updateSql;
    EXECUTE updateSql;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;
    
CREATE OR REPLACE FUNCTION partitions.delete_from_correct_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
  BEGIN
    SELECT partition_id, sample_name, active, included INTO this_partition FROM partitions.metagenomic_partitions WHERE sample_name = OLD.sample_name; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE E'partition % is inactive.', this_partition.sample_name
        USING HINT = 'Activate partition with UPDATE partitions.metagenomic_partitions SET active = TRUE WHERE sample_name = [sample name]';
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE E'partition % is not included.', this_partition.sample_name
        USING HINT = 'To include: SELECT partitions.rebuild_mg_view();';
      RETURN NULL; 
    END IF;

    EXECUTE 'DELETE FROM partitions.sample_' || this_partition.partition_id || 
      ' where did = ' ||  E'\'' || OLD.did || E'\'' || ' and ' ||
      'did_auth = ' || E'\'' || OLD.did_auth ||  E'\'' || ' and ' ||
      'sample_name = ' || E'\'' || OLD.sample_name ||  E'\'' || ' and ' ||
      'study = ' ||  E'\'' || OLD.study ||  E'\'' || ';';
    RETURN OLD;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.rebuild_mg_view() RETURNS BOOLEAN AS $$
  DECLARE part_tables text[];
  DECLARE view_ddl text = 'CREATE OR REPLACE VIEW core.mg_dnas as select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, sample_name from partitions.metagenomic_sequences_template union all ';
  DECLARE i text;
  BEGIN
    select array_agg(a.tablename) from (select ('partitions.sample_' || cast(partition_id as text)) as tablename from partitions.metagenomic_partitions where active = true) as a into part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, sample_name from '|| i || ' union all '; 
      END LOOP;
    END IF;
    select trim(trailing ' union all ' from view_ddl) into view_ddl;
    EXECUTE view_ddl;
    update partitions.metagenomic_partitions set included = true where active = true;
    RETURN true;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.create_mg_partition(sample_name text) RETURNS INT AS $$
  DECLARE
    next_id int4;
  BEGIN
    SELECT nextval('partitions.mg_partition_seq') INTO next_id;
    EXECUTE 'create table partitions.sample_' || next_id || ' (' ||
      'like partitions.metagenomic_sequences_template including defaults,' ||
      'primary key (sample_name, did, did_auth, study),' ||
      'FOREIGN KEY (assembly_status)' ||
      '    REFERENCES cv.assembly_status (term) MATCH SIMPLE' ||
      '    ON UPDATE CASCADE ON DELETE NO ACTION,' ||
      'FOREIGN KEY (own)' ||
      '    REFERENCES auth.users (logname) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (project)' ||
      '    REFERENCES core.projects (id) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (seq_method)' ||
      '    REFERENCES cv.seq_methods (term) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (sample_name)' ||
      '    REFERENCES core.samples(label) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (study)' ||
      '    REFERENCES core.studies(label) MATCH SIMPLE' || -- actually core.mg_studies, atm it's empty
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'check (sample_name = ' || E'\'' || sample_name || E'\'' || ')' ||
    '); ';
    EXECUTE 'insert into partitions.metagenomic_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || sample_name || E'\'' || 
      ', true, false);';
    RETURN next_id;
  END;
$$ LANGUAGE plpgsql;

SELECT partitions.rebuild_mg_view();

/*
 * Part II: Clonelibs
 *
 */
ALTER TABLE core.clonelib_sequences_template SET SCHEMA partitions;
ALTER TABLE core.clonelib_partitions SET SCHEMA partitions;
ALTER SEQUENCE core.cl_partition_seq SET SCHEMA partitions;
ALTER FUNCTION core.create_cl_partition(text) SET SCHEMA partitions;
ALTER FUNCTION core.rebuild_cl_view() SET SCHEMA partitions;
ALTER FUNCTION core.insert_into_correct_cl_partition() SET SCHEMA partitions;
ALTER FUNCTION core.update_correct_cl_partition() SET SCHEMA partitions;
ALTER FUNCTION core.delete_from_correct_cl_partition() SET SCHEMA partitions;

CREATE OR REPLACE FUNCTION partitions.insert_into_correct_cl_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, lib_name, active, included INTO this_partition FROM partitions.clonelib_partitions WHERE lib_name = NEW.lib_name; 
    IF this_partition IS NULL THEN 
      PERFORM partitions.create_cl_partition(NEW.lib_name);
      RAISE NOTICE 'New partition % created', NEW.lib_name;
      SELECT partition_id, lib_name, active, included INTO this_partition FROM partitions.clonelib_partitions WHERE lib_name = NEW.lib_name;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE EXCEPTION 'partition % is inactive.', this_partition.lib_name
        USING HINT = 'Activate partition with UPDATE partitions.clonelib_partitions SET active = TRUE WHERE lib_name = [lib name];'; 
    END IF;

    insertSql := 'INSERT INTO partitions.clonelib_' || CAST(this_partition.partition_id AS text) || ' ';
    FOR field IN SELECT * FROM skeys(insertRecord) LOOP
      rowOrder := rowOrder || field || ', ';
      IF (insertRecord->field::text) IS NULL THEN
        insertValues := insertValues || ' DEFAULT, ';
      ELSE
        insertValues := insertValues || E'\'' || (insertRecord->field::text) || E'\'' || ', ' ;
      END IF;
    END LOOP;
    insertValues := trim(trailing ', ' from insertValues) || ');';
    rowOrder := trim(trailing ', ' from rowOrder) || ') ';
    insertSql := insertSql || rowOrder || insertValues;
    --RAISE NOTICE 'INSERT: %', insertSql;
    EXECUTE insertSql;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.update_correct_cl_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, lib_name, active, included INTO this_partition FROM partitions.clonelib_partitions WHERE lib_name = NEW.lib_name; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE 'partition % is inactive.', this_partition.lib_name
        USING HINT = 'Activate partition with UPDATE partitions.clonelib_partitions SET active = TRUE WHERE lib_name = [lib name];'; 
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.lib_name
        USING HINT = 'To include: SELECT partitions.rebuild_cl_view();'; 
      RETURN NULL; 
    END IF;
    
    updateSql := 'UPDATE partitions.clonelib_' || CAST(this_partition.partition_id AS text) || ' SET ';
    FOR field IN SELECT * FROM skeys(updateRecord) LOOP
      IF (updateRecord->field::text) IS NOT NULL THEN
        updateValues := updateValues || field || E' = \'' || (updateRecord->field::text) || E'\'' || ', ' ;
      END IF;
    END LOOP;
    updateValues := trim(trailing ', ' from updateValues);
    whereClause := ' WHERE ' ||
                   E'did = \'' || OLD.did || E'\' AND ' || 
                   E'did_auth = \'' || OLD.did_auth || E'\' AND ' ||
                   E'lib_name = \'' || OLD.lib_name || E'\' AND ' ||
                   E'clone_name = \'' || OLD.clone_name || E'\' AND ' ||
                   E'study = \'' || OLD.study || E'\';';
    updateSql := updateSql || updateValues  || whereClause;
    --RAISE NOTICE 'UPDATE: %', updateSql;
    EXECUTE updateSql;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.delete_from_correct_cl_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
  BEGIN
    SELECT partition_id, lib_name, active, included INTO this_partition FROM partitions.clonelib_partitions WHERE lib_name = OLD.lib_name; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE 'partition % is inactive.', this_partition.lib_name
        USING HINT = 'Activate partition with UPDATE partitions.clonelib_partitions SET active = TRUE WHERE lib_name = [lib name];'; 
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.lib_name
        USING HINT = 'To include: SELECT partitions.rebuild_cl_view();'; 
      RETURN NULL; 
    END IF;

    EXECUTE 'DELETE FROM partitions.clonelib_' || this_partition.partition_id || 
      ' where did = ' ||  E'\'' || OLD.did || E'\'' || ' and ' ||
      'did_auth = ' || E'\'' || OLD.did_auth ||  E'\'' || ' and ' ||
      'lib_name = ' || E'\'' || OLD.lib_name ||  E'\'' || ' and ' ||
      'clone_name = ' || E'\'' || OLD.clone_name ||  E'\'' || ' and ' ||
      'study = ' ||  E'\'' || OLD.study ||  E'\'' || ';';
    RETURN OLD;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.rebuild_cl_view() RETURNS BOOLEAN AS $$
  DECLARE
    part_tables text[];
    view_ddl text = 'CREATE OR REPLACE VIEW core.clonelib_dnas as select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, lib_name, clone_name from partitions.clonelib_sequences_template union all ';
    i text;
  BEGIN
    SELECT array_agg(a.tablename) FROM (
      SELECT ('partitions.clonelib_' || CAST(partition_id AS text)) AS tablename FROM partitions.clonelib_partitions WHERE active = TRUE
    ) AS a INTO part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, lib_name, clone_name from '|| i || ' union all '; 
      END LOOP;
    END IF;
    SELECT trim(trailing ' union all ' FROM view_ddl) INTO view_ddl;
    EXECUTE view_ddl;
    UPDATE partitions.clonelib_partitions SET included = TRUE WHERE active = TRUE;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.create_cl_partition(lib_name text) RETURNS INT AS $$
  DECLARE
    next_id int4;
  BEGIN
    SELECT nextval('partitions.cl_partition_seq') INTO next_id;
    EXECUTE 'create table partitions.clonelib_' || next_id || ' (' ||
      'like partitions.clonelib_sequences_template including defaults,' ||
      'primary key (lib_name, did, did_auth, study, clone_name),' ||
      'FOREIGN KEY (study, lib_name, clone_name)' ||
      '    REFERENCES core.clones (study, lib_name, label) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (assembly_status)' ||
      '    REFERENCES cv.assembly_status (term) MATCH SIMPLE' ||
      '    ON UPDATE CASCADE ON DELETE NO ACTION,' ||
      'FOREIGN KEY (own)' ||
      '    REFERENCES auth.users (logname) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (project)' ||
      '    REFERENCES core.projects (id) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (seq_method)' ||
      '    REFERENCES cv.seq_methods (term) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'check (lib_name = ' || E'\'' || lib_name || E'\'' || ')' ||
    '); ';
    EXECUTE 'insert into partitions.clonelib_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || lib_name || E'\'' || 
      ', true, false);';
    RETURN next_id;
  END;
$$ LANGUAGE plpgsql;

SELECT partitions.rebuild_cl_view();

/*
 * Part II: Pooled Metagenomic Sequences
 *
 */
ALTER TABLE core.pooled_metagenomic_sequences_template SET SCHEMA partitions;
ALTER TABLE core.pooled_metagenomic_partitions SET SCHEMA partitions;
ALTER SEQUENCE core.pooled_mg_partition_seq SET SCHEMA partitions;
ALTER FUNCTION core.create_pooled_mg_partition(text) SET SCHEMA partitions;
ALTER FUNCTION core.rebuild_pooled_mg_view() SET SCHEMA partitions;
ALTER FUNCTION core.insert_into_correct_pooled_mg_partition() SET SCHEMA partitions;
ALTER FUNCTION core.update_correct_pooled_mg_partition() SET SCHEMA partitions;
ALTER FUNCTION core.delete_from_correct_pooled_mg_partition() SET SCHEMA partitions;

CREATE OR REPLACE FUNCTION partitions.insert_into_correct_pooled_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, pool_label, active, included INTO this_partition FROM partitions.pooled_metagenomic_partitions WHERE pool_label = NEW.pool_label; 
    IF this_partition IS NULL THEN 
      PERFORM partitions.create_pooled_mg_partition(NEW.pool_label);
      RAISE NOTICE 'New partition % created', NEW.pool_label;
      SELECT partition_id, pool_label, active, included INTO this_partition FROM partitions.pooled_metagenomic_partitions WHERE pool_label = NEW.pool_label;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE EXCEPTION E'partition % is inactive.', this_partition.pool_label
        USING HINT = 'Activate partition with UPDATE partitions.pooled_metagenomic_partitions SET active = TRUE WHERE pool_label = [pool label]'; 
    END IF;

    insertSql := 'INSERT INTO partitions.pool_' || CAST(this_partition.partition_id AS text) || ' ';
    FOR field IN SELECT * FROM skeys(insertRecord) LOOP
      rowOrder := rowOrder || field || ', ';
      IF (insertRecord->field::text) IS NULL THEN
        insertValues := insertValues || ' DEFAULT, ';
      ELSE
        insertValues := insertValues || E'\'' || (insertRecord->field::text) || E'\'' || ', ' ;
      END IF;
    END LOOP;
    insertValues := trim(trailing ', ' from insertValues) || ');';
    rowOrder := trim(trailing ', ' from rowOrder) || ') ';
    insertSql := insertSql || rowOrder || insertValues;
    --RAISE NOTICE 'INSERT: %', insertSql;
    EXECUTE insertSql;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.update_correct_pooled_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, pool_label, active, included INTO this_partition FROM partitions.pooled_metagenomic_partitions WHERE pool_label = NEW.pool_label; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE E'partition % is inactive.', this_partition.pool_label
        USING HINT = 'Activate partition with UPDATE partitions.pooled_metagenomic_partitions SET active = TRUE WHERE pool_label = [pool label]'; 
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.pool_label
        USING HINT = 'To include: SELECT partitions.rebuild_pooled_mg_view();'; 
      RETURN NULL; 
    END IF;
    updateSql := 'UPDATE partitions.pool_' || CAST(this_partition.partition_id AS text) || ' SET ';
    FOR field IN SELECT * FROM skeys(updateRecord) LOOP
      IF (updateRecord->field::text) IS NOT NULL THEN
        updateValues := updateValues || field || E' = \'' || (updateRecord->field::text) || E'\'' || ', ' ;
      END IF;
    END LOOP;
    updateValues := trim(trailing ', ' from updateValues);
    whereClause := ' WHERE ' ||
                   E'did = \'' || OLD.did || E'\' AND ' || 
                   E'did_auth = \'' || OLD.did_auth || E'\' AND ' ||
                   E'pool_label = \'' || OLD.pool_label || E'\' AND ' ||
                   E'study = \'' || OLD.study || E'\';';
    updateSql := updateSql || updateValues  || whereClause;
    --RAISE NOTICE 'UPDATE: %', updateSql;
    EXECUTE updateSql;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.delete_from_correct_pooled_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
  BEGIN
    SELECT partition_id, pool_label, active, included INTO this_partition FROM partitions.pooled_metagenomic_partitions WHERE pool_label = OLD.pool_label; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE E'partition % is inactive.', this_partition.pool_label
        USING HINT = 'Activate partition with UPDATE partitions.pooled_metagenomic_partitions SET active = TRUE WHERE pool_label = [pool label]'; 
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.pool_label
        USING HINT = 'To include: SELECT partitions.rebuild_pooled_mg_view();';       RETURN NULL; 
    END IF;
    EXECUTE 'DELETE FROM partitions.pool_' || this_partition.partition_id || 
      ' where did = ' ||  E'\'' || OLD.did || E'\'' || ' and ' ||
      'did_auth = ' || E'\'' || OLD.did_auth ||  E'\'' || ' and ' ||
      'pool_label = ' || E'\'' || OLD.pool_label ||  E'\'' || ' and ' ||
      'study = ' ||  E'\'' || OLD.study ||  E'\'' || ';';
    RETURN OLD;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.rebuild_pooled_mg_view() RETURNS BOOLEAN AS $$
  DECLARE part_tables text[];
  DECLARE view_ddl text = 'CREATE OR REPLACE VIEW core.mg_pooled_dnas as select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, pool_label from partitions.pooled_metagenomic_sequences_template union all ';
  DECLARE i text;
  BEGIN
    select array_agg(a.tablename) from (select ('partitions.pool_' || cast(partition_id as text)) as tablename from partitions.pooled_metagenomic_partitions where active = true) as a into part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, pool_label from '|| i || ' union all '; 
      END LOOP;
    END IF;
    select trim(trailing ' union all ' from view_ddl) into view_ddl;
    EXECUTE view_ddl;
    update partitions.pooled_metagenomic_partitions set included = true where active = true;
    RETURN true;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION partitions.create_pooled_mg_partition(pool_label text) RETURNS INT AS $$
  DECLARE
    next_id int4;
  BEGIN
    SELECT nextval('partitions.pooled_mg_partition_seq') INTO next_id;
    EXECUTE 'create table partitions.pool_' || next_id || ' (' ||
      'like partitions.pooled_metagenomic_sequences_template including defaults,' ||
      'primary key (pool_label, did, did_auth, study),' ||
      'FOREIGN KEY (assembly_status)' ||
      '    REFERENCES cv.assembly_status (term) MATCH SIMPLE' ||
      '    ON UPDATE CASCADE ON DELETE NO ACTION,' ||
      'FOREIGN KEY (own)' ||
      '    REFERENCES auth.users (logname) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (project)' ||
      '    REFERENCES core.projects (id) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (seq_method)' ||
      '    REFERENCES cv.seq_methods (term) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (pool_label, study)' ||
      '    REFERENCES core.sample_pools(label, study) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'check (pool_label = ' || E'\'' || pool_label || E'\'' || ')' ||
    '); ';
    EXECUTE 'insert into partitions.pooled_metagenomic_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || pool_label || E'\'' || 
      ', true, false);';
    RETURN next_id;
  END;
$$ LANGUAGE plpgsql;

SELECT partitions.rebuild_pooled_mg_view();

COMMIT;
BEGIN;
/*
 * Test Metagenomic Sequences
 */
INSERT INTO core.studies (label) VALUES ('study1');
INSERT INTO core.samples (label, study) VALUES ('sample1','study1');
INSERT INTO core.samples (label, study) VALUES ('sample2','study1');
INSERT INTO core.samples (label, study) VALUES ('sample3','study1');
INSERT INTO core.samples (label, study) VALUES ('sample4','study1');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status) VALUES ('seq1', 'ref', 'study1', 'sample1', 'ACGATG', '');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status) VALUES ('seq2', 'ref', 'study1', 'sample1', 'ACGATG', '');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status) VALUES ('seq3', 'ref', 'study1', 'sample1', 'ACGATG', '');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status) VALUES ('seq1', 'ref', 'study1', 'sample2', 'ACGATG', '');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status) VALUES ('seq2', 'ref', 'study1', 'sample2', 'ACGATG', '');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status) VALUES ('seq3', 'ref', 'study1', 'sample2', 'ACGATG', '');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status) VALUES ('seq1', 'ref', 'study1', 'sample3', 'ACGATG', '');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status) VALUES ('seq2', 'ref', 'study1', 'sample3', 'ACGATG', '');
INSERT INTO core.mg_dnas (did, did_auth, study, sample_name, dna, assembly_status)
  VALUES ('seq1', 'ref', 'study1', 'sample4', 'ACGATG', ''),
         ('seq2', 'ref', 'study1', 'sample4', 'ACGATG', ''),
         ('seq3', 'ref', 'study1', 'sample4', 'ACGATG', ''),
         ('seq4', 'ref', 'study1', 'sample4', 'ACGATG', '');

UPDATE core.mg_dnas SET dna = 'updated' WHERE did = 'seq1';
UPDATE core.mg_dnas SET dna = 'updated2' WHERE sample_name = 'sample4';

DELETE FROM core.mg_dnas WHERE sample_name = 'sample2';


SELECT * FROM core.mg_dnas WHERE sample_name = 'sample1';
SELECT * FROM core.mg_dnas WHERE sample_name = 'sample2';
SELECT * FROM core.mg_dnas WHERE sample_name = 'sample3';
SELECT * FROM core.mg_dnas WHERE study = 'study1';

SELECT * FROM partitions.metagenomic_partitions;

/*
 * Test Clonelibs
 */ 
INSERT INTO core.clonelibs (label, study, sample_name) VALUES ('clonelib1', 'study1', 'sample1');
INSERT INTO core.clonelibs (label, study, sample_name) VALUES ('clonelib2', 'study1', 'sample1');
INSERT INTO core.clonelibs (label, study, sample_name) VALUES ('clonelib3', 'study1', 'sample1');
INSERT INTO core.clones (label, study, lib_name) VALUES ('clone1', 'study1', 'clonelib1');
INSERT INTO core.clones (label, study, lib_name) VALUES ('clone2', 'study1', 'clonelib2');
INSERT INTO core.clones (label, study, lib_name) VALUES ('clone3', 'study1', 'clonelib3');
INSERT INTO core.clonelib_dnas (did, did_auth, study, lib_name, clone_name, dna, assembly_status)
  VALUES ('seq1', 'ref', 'study1', 'clonelib1', 'clone1', 'ACGATG', ''),
         ('seq2', 'ref', 'study1', 'clonelib1', 'clone1', 'ACGATG', ''),
         ('seq3', 'ref', 'study1', 'clonelib1', 'clone1', 'ACGATG', ''),
         ('seq4', 'ref', 'study1', 'clonelib1', 'clone1', 'ACGATG', ''),
         ('seq1', 'ref', 'study1', 'clonelib2', 'clone2', 'ACGATG', ''),
         ('seq2', 'ref', 'study1', 'clonelib2', 'clone2', 'ACGATG', ''),
         ('seq3', 'ref', 'study1', 'clonelib2', 'clone2', 'ACGATG', ''),
         ('seq4', 'ref', 'study1', 'clonelib2', 'clone2', 'ACGATG', ''),
         ('seq1', 'ref', 'study1', 'clonelib3', 'clone3', 'ACGATG', ''),
         ('seq2', 'ref', 'study1', 'clonelib3', 'clone3', 'ACGATG', ''),
         ('seq3', 'ref', 'study1', 'clonelib3', 'clone3', 'ACGATG', ''),
         ('seq4', 'ref', 'study1', 'clonelib3', 'clone3', 'ACGATG', '');

UPDATE core.clonelib_dnas SET dna = 'updated' WHERE did = 'seq1';
UPDATE core.clonelib_dnas SET dna = 'updated2' WHERE clone_name = 'clone3';

DELETE FROM core.clonelib_dnas WHERE clone_name = 'clone2';

SELECT * FROM core.clonelib_dnas WHERE clone_name = 'clone1';
SELECT * FROM core.clonelib_dnas WHERE clone_name = 'clone2';
SELECT * FROM core.clonelib_dnas WHERE clone_name = 'clone3';
SELECT * FROM core.clonelib_dnas WHERE study = 'study1';

SELECT * FROM partitions.clonelib_partitions;

/*
 * Test Pooled Metagenomic Sequences
 */
INSERT INTO core.sample_pools (label, study) VALUES ('pool1','study1');
INSERT INTO core.sample_pools (label, study) VALUES ('pool2','study1');
INSERT INTO core.sample_pools (label, study) VALUES ('pool3','study1');
INSERT INTO core.sample_pools (label, study) VALUES ('pool4','study1');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status) VALUES ('seq1', 'ref', 'study1', 'pool1', 'ACGATG', '');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status) VALUES ('seq2', 'ref', 'study1', 'pool1', 'ACGATG', '');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status) VALUES ('seq3', 'ref', 'study1', 'pool1', 'ACGATG', '');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status) VALUES ('seq1', 'ref', 'study1', 'pool2', 'ACGATG', '');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status) VALUES ('seq2', 'ref', 'study1', 'pool2', 'ACGATG', '');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status) VALUES ('seq3', 'ref', 'study1', 'pool2', 'ACGATG', '');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status) VALUES ('seq1', 'ref', 'study1', 'pool3', 'ACGATG', '');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status) VALUES ('seq2', 'ref', 'study1', 'pool3', 'ACGATG', '');
INSERT INTO core.mg_pooled_dnas (did, did_auth, study, pool_label, dna, assembly_status)
  VALUES ('seq1', 'ref', 'study1', 'pool4', 'ACGATG', ''),
         ('seq2', 'ref', 'study1', 'pool4', 'ACGATG', ''),
         ('seq3', 'ref', 'study1', 'pool4', 'ACGATG', ''),
         ('seq4', 'ref', 'study1', 'pool4', 'ACGATG', '');

UPDATE core.mg_pooled_dnas SET dna = 'updated' WHERE did = 'seq1';
UPDATE core.mg_pooled_dnas SET dna = 'updated2' WHERE pool_label = 'pool4';

DELETE FROM core.mg_pooled_dnas WHERE pool_label = 'pool2';

SELECT * FROM core.mg_pooled_dnas WHERE pool_label = 'pool1';
SELECT * FROM core.mg_pooled_dnas WHERE pool_label = 'pool2';
SELECT * FROM core.mg_pooled_dnas WHERE pool_label = 'pool3';
SELECT * FROM core.mg_pooled_dnas WHERE study = 'study1';

SELECT * FROM partitions.pooled_metagenomic_partitions;

ROLLBACK;