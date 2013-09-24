BEGIN;

SELECT _v.register_patch('29-fix-partitioning' , ARRAY['1-partitioning','28-compress-sequence-data'], NULL );

/*
 * Part B: Partitioning of metagenomic sequences
 */

CREATE OR REPLACE FUNCTION core.insert_into_correct_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, sample_name, active, included INTO this_partition FROM core.metagenomic_partitions WHERE sample_name = NEW.sample_name; 
    IF this_partition IS NULL THEN 
      PERFORM core.create_mg_partition(NEW.sample_name);
      RAISE NOTICE 'New partition % created', NEW.sample_name;
      SELECT partition_id, sample_name, active, included INTO this_partition FROM core.metagenomic_partitions WHERE sample_name = NEW.sample_name;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE EXCEPTION 'partition % is inactive.', this_partition.sample_name
        USING HINT = 'Activate partition with UPDATE core.metagenomic_partitions SET active = TRUE WHERE sample_name = [sample name]'; 
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

CREATE OR REPLACE FUNCTION core.update_correct_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, sample_name, active, included INTO this_partition FROM core.metagenomic_partitions WHERE sample_name = NEW.sample_name; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE 'partition % is inactive.', this_partition.sample_name
        USING HINT = 'Activate partition with UPDATE core.metagenomic_partitions SET active = TRUE WHERE sample_name = [sample name]';
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.sample_name
        USING HINT = 'To include: SELECT core.rebuild_mg_view();';
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
    
CREATE OR REPLACE FUNCTION core.delete_from_correct_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
  BEGIN
    SELECT partition_id, sample_name, active, included INTO this_partition FROM core.metagenomic_partitions WHERE sample_name = OLD.sample_name; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE E'partition % is inactive.', this_partition.sample_name
        USING HINT = 'Activate partition with UPDATE core.metagenomic_partitions SET active = TRUE WHERE sample_name = [sample name]';
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE E'partition % is not included.', this_partition.sample_name
        USING HINT = 'To include: SELECT core.rebuild_mg_view();';
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

/*
 * Part C: Partitioning of clonelib sequences
 */

CREATE OR REPLACE FUNCTION core.insert_into_correct_cl_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, lib_name, active, included INTO this_partition FROM core.clonelib_partitions WHERE lib_name = NEW.lib_name; 
    IF this_partition IS NULL THEN 
      PERFORM core.create_cl_partition(NEW.lib_name);
      RAISE NOTICE 'New partition % created', NEW.lib_name;
      SELECT partition_id, lib_name, active, included INTO this_partition FROM core.clonelib_partitions WHERE lib_name = NEW.lib_name;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE EXCEPTION 'partition % is inactive.', this_partition.lib_name
        USING HINT = 'Activate partition with UPDATE core.clonelib_partitions SET active = TRUE WHERE lib_name = [lib name];'; 
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

CREATE OR REPLACE FUNCTION core.update_correct_cl_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, lib_name, active, included INTO this_partition FROM core.clonelib_partitions WHERE lib_name = NEW.lib_name; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE 'partition % is inactive.', this_partition.lib_name
        USING HINT = 'Activate partition with UPDATE core.clonelib_partitions SET active = TRUE WHERE lib_name = [lib name];'; 
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.lib_name
        USING HINT = 'To include: SELECT core.rebuild_cl_view();'; 
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

CREATE OR REPLACE FUNCTION delete_from_correct_cl_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
  BEGIN
    SELECT partition_id, lib_name, active, included INTO this_partition FROM core.clonelib_partitions WHERE lib_name = NEW.lib_name; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE 'partition % is inactive.', this_partition.lib_name
        USING HINT = 'Activate partition with UPDATE core.clonelib_partitions SET active = TRUE WHERE lib_name = [lib name];'; 
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.lib_name
        USING HINT = 'To include: SELECT core.rebuild_cl_view();'; 
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

/*
 * Part D: Partitioning of pooled metagenomic sequences
 */

CREATE OR REPLACE FUNCTION core.insert_into_correct_pooled_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, pool_label, active, included INTO this_partition FROM core.pooled_metagenomic_partitions WHERE pool_label = NEW.pool_label; 
    IF this_partition IS NULL THEN 
      PERFORM core.create_pooled_mg_partition(NEW.pool_label);
      RAISE NOTICE 'New partition % created', NEW.pool_label;
      SELECT partition_id, pool_label, active, included INTO this_partition FROM core.pooled_metagenomic_partitions WHERE pool_label = NEW.pool_label;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE EXCEPTION E'partition % is inactive.', this_partition.pool_label
        USING HINT = 'Activate partition with UPDATE core.pooled_metagenomic_partitions SET active = TRUE WHERE pool_label = [pool label]'; 
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

CREATE OR REPLACE FUNCTION core.update_correct_pooled_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id, pool_label, active, included INTO this_partition FROM core.pooled_metagenomic_partitions WHERE pool_label = NEW.pool_label; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE E'partition % is inactive.', this_partition.pool_label
        USING HINT = 'Activate partition with UPDATE core.pooled_metagenomic_partitions SET active = TRUE WHERE pool_label = [pool label]'; 
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.pool_label
        USING HINT = 'To include: SELECT core.rebuild_pooled_mg_view();'; 
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

CREATE OR REPLACE FUNCTION delete_from_correct_pooled_mg_partition() RETURNS TRIGGER AS $$
  DECLARE
    this_partition record;
  BEGIN
    SELECT partition_id, pool_label, active, included INTO this_partition FROM core.pooled_metagenomic_partitions WHERE pool_label = NEW.pool_label; 
    IF this_partition IS NULL THEN 
      RETURN NULL;
    END IF;
    IF this_partition.active = FALSE THEN
      RAISE NOTICE E'partition % is inactive.', this_partition.pool_label
        USING HINT = 'Activate partition with UPDATE core.pooled_metagenomic_partitions SET active = TRUE WHERE pool_label = [pool label]'; 
      RETURN NULL; 
    END IF;
    IF this_partition.included = FALSE THEN
      RAISE NOTICE 'partition % is not included.', this_partition.pool_label
        USING HINT = 'To include: SELECT core.rebuild_pooled_mg_view();';       RETURN NULL; 
    END IF;
    EXECUTE 'DELETE FROM partitions.pool_label_' || this_partition.partition_id || 
      ' where did = ' ||  E'\'' || OLD.did || E'\'' || ' and ' ||
      'did_auth = ' || E'\'' || OLD.did_auth ||  E'\'' || ' and ' ||
      'pool_label = ' || E'\'' || OLD.pool_label ||  E'\'' || ' and ' ||
      'study = ' ||  E'\'' || OLD.study ||  E'\'' || ';';
    RETURN OLD;
  END;
$$ LANGUAGE plpgsql;

COMMIT;

BEGIN;
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

SELECT * FROM core.metagenomic_partitions;
ROLLBACK;