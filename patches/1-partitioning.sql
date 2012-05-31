SET search_path TO core, cv, public;
SET constraint_exclusion TO on;

/*
 * Part A: Separation of genomic and metagenomic dna sequences
 */
begin;
SELECT _v.register_patch( '1-partitioning', NULL, NULL );

--drop foreign keys to dna_seqs
alter table genome_dnas drop constraint genome_dnas_did_fkey;
alter table clonelib_dnas drop constraint clonelib_dnas_did_fkey;
alter table dna_sets drop constraint dna_sets_did_fkey;
alter table mg_pooled_dnas drop constraint mg_pooled_dnas_did_fkey;
--mg_dnas has no explicit reference

--remove unused columns from dna_seqs and genome_dnas
alter table core.dna_seqs drop column msid;
alter table core.dna_seqs drop column gi;

--calculate md5 sum for all sequences
alter table dna_seqs add column md5sum char(32);
update dna_seqs set md5sum = md5(dna); 

--new column will contain all sequencing methods used in a study
alter table genome_studies add column seq_methods text[];

--create new table for genomic sequences
create table genomic_sequences (
  dna text NOT NULL DEFAULT ''::text, -- whole DNA nucleotid sequence
  size integer NOT NULL DEFAULT 0, -- nucleotid length of the sequence
  gc numeric NOT NULL DEFAULT 'NaN'::numeric, -- GC content in %
  seq_method text NOT NULL DEFAULT ''::text, -- method used for sequencing
  data_source text, -- origin of data
  assembly_status text NOT NULL,
  retrieved timestamp without time zone NOT NULL DEFAULT now(), -- when was the data retrieved
  project integer DEFAULT 0,
  own text DEFAULT 'megdb'::text, -- owner
  did text NOT NULL DEFAULT ''::text, -- A DNA identifier from some resource see did_auth
  did_auth text NOT NULL DEFAULT ''::text, -- The authority of the did. Technically a symbol refering to the organisation which issues the identifiers see table is_codes.
  mol_type text DEFAULT ''::text,
  acc_ver text NOT NULL DEFAULT ''::text,
  isolate_id integer NOT NULL, -- isolate identifier
  gpid integer,
  center text, -- name of the center where the genome was sequenced
  fold_coverage numeric NOT NULL DEFAULT 'NaN'::numeric, -- how often was the whole genome sequenced
  topology text DEFAULT ''::text, -- the structure of the genome: linear or circular
  genome_material text, -- content of the genome: chromosome or not
  status text DEFAULT ''::text, -- status of the sequencing
  seq_platform text NOT NULL DEFAULT ''::text,
  seq_approach text NOT NULL DEFAULT ''::text, -- TODO better define. most propably approach means which sequencing strategy was used e.g. WGS MDA
  study text NOT NULL DEFAULT ''::text, -- kind of study
  isolate_name text NOT NULL DEFAULT ''::text, -- name of the sequenced isolate
  assembly_tool text NOT NULL DEFAULT 'unknown'::text,
  assembly_tool_version text NOT NULL DEFAULT ''::text,
  assembly_method text NOT NULL DEFAULT ''::text,
  estimated_error_rate text NOT NULL DEFAULT ''::text,
  calculation_method text NOT NULL DEFAULT ''::text,
  CONSTRAINT genomic_sequences_pkey PRIMARY KEY (isolate_id, did, did_auth),
  CONSTRAINT genomic_sequences_assembly_tool_fkey FOREIGN KEY (assembly_tool, assembly_tool_version)
      REFERENCES core.tool_versions (label, ver) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT genomic_sequences_genomic_material_fkey FOREIGN KEY (genome_material)
      REFERENCES cv.genome_materials (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT genomic_sequences_seq_approach_fkey FOREIGN KEY (seq_approach)
      REFERENCES cv.seq_approaches (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT genomic_sequences_seq_method_fkey FOREIGN KEY (seq_method)
      REFERENCES cv.seq_methods (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT genomic_sequences_seq_platform_fkey FOREIGN KEY (seq_platform)
      REFERENCES cv.seq_platforms (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT genomic_sequences_study_fkey FOREIGN KEY (study, isolate_name)
      REFERENCES core.genome_studies (label, isolate_name) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT genomic_sequences_status_check CHECK (status = ANY (ARRAY['draft'::text, 'complete'::text, ''::text])),
  CONSTRAINT genomic_sequences_topology_check CHECK (topology = ANY (ARRAY['circular'::text, 'linear'::text, ''::text])),
  CONSTRAINT genomic_sequences_assembly_status_fkey FOREIGN KEY (assembly_status)
      REFERENCES cv.assembly_status (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT genomic_sequences_id_auth_fkey FOREIGN KEY (did_auth)
      REFERENCES core.id_codes (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT genomic_sequences_own_fkey FOREIGN KEY (own)
      REFERENCES core.logins (logname) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT genomic_sequences_project_fkey FOREIGN KEY (project)
      REFERENCES core.projects (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- import into new structure
insert into genomic_sequences 
  select a.dna, a.size, a.gc, a.seq_method, a.data_source, a.assembly_status, a.retrieved, a.project, a.own, a.did, a.did_auth, a.mol_type, a.acc_ver,
         b.isolate_id, b.gpid, b.center, b.fold_coverage, b.topology, b.genome_material, b.status, b.seq_platform, b.seq_approach, b.study, b.isolate_name,
         b.assembly_tool, b.assembly_tool_version, b.assembly_method, b.estimated_error_rate, b.calculation_method
    from 
    core.dna_seqs as a 
    inner join
    core.genome_dnas as b 
    on a.did = b.did and a.did_auth = b.did_auth;
delete from dna_seqs where exists (select 1 from genome_dnas where dna_seqs.did = genome_dnas.did and dna_seqs.did_auth = genome_dnas.did_auth);

--rename table so it matches the convention
--drop table genome_dnas;
--alter table genomic_sequences rename to genome_dnas;

/*
 * Part B: Partitioning of metagenomic sequences
 */

--schema to store all partitions separately
create schema partitions;

--template for partitions, should not be accessed in any way
create table metagenomic_sequences_template (
	like dna_seqs including defaults,
	study text,
	sample_name text,
	check (sample_name = '')
);
revoke insert on metagenomic_sequences_template from public;
comment on table metagenomic_sequences_template is 'Template for all sample-separated instances';

-- table to store partition ids 
create sequence mg_partition_seq;
alter table samples add constraint sample_label_unique unique (label);
create table metagenomic_partitions (
  partition_id int4,
  sample_name text references samples(label),
  active boolean,
  included boolean
);

--function to create a new partition by sample name
create or replace function create_mg_partition(sample_name text) returns int as $$
  DECLARE next_id int4;
  BEGIN
    select nextval('core.mg_partition_seq') into next_id;
    EXECUTE 'create table partitions.sample_' || next_id || ' (' ||
      'like core.metagenomic_sequences_template including defaults,' ||
      'primary key (sample_name, did, did_auth, study),' ||
      'FOREIGN KEY (assembly_status)' ||
      '    REFERENCES cv.assembly_status (term) MATCH SIMPLE' ||
      '    ON UPDATE CASCADE ON DELETE NO ACTION,' ||
      'FOREIGN KEY (own)' ||
      '    REFERENCES core.logins (logname) MATCH SIMPLE' ||
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
    EXECUTE 'insert into core.metagenomic_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || sample_name || E'\'' || 
      ', true, false);';
    return next_id;
  END;
$$ language plpgsql;

create or replace function core.rebuild_mg_view() returns boolean as $$
  DECLARE part_tables text[];
  DECLARE view_ddl text = 'CREATE OR REPLACE VIEW core.mg_dnas as select * from core.metagenomic_sequences_template union all ';
  DECLARE i text;
  BEGIN
    select array_agg(a.tablename) from (select ('partitions.sample_' || cast(partition_id as text)) as tablename from core.metagenomic_partitions where active = true) as a into part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select * from '|| i || ' union all '; 
      END LOOP;
    END IF;
    select trim(trailing ' union all ' from view_ddl) into view_ddl;
    EXECUTE view_ddl;
    update core.metagenomic_partitions set included = true where active = true;
    RETURN true;
  END;
$$ language plpgsql;

-- function to import data from dna_seqs to new partition
create or replace function import_mg_partition(this_sample_name text) returns boolean as $$
  DECLARE
    this_study text;
    part_id int;
  BEGIN
    select core.mg_dnas.study into this_study from core.mg_dnas where core.mg_dnas.sample_name = this_sample_name;
    raise notice 'Importing sample % from study  %...', this_sample_name, this_study;
    EXECUTE 'select core.create_mg_partition(' || E'\'' || this_sample_name || E'\'' || ');';
    select partition_id from core.metagenomic_partitions where sample_name = this_sample_name into part_id;
    EXECUTE 'insert into partitions.sample_' || part_id ||
      ' select *, ' || E'\'' || this_study || E'\'' || ', ' ||
      E'\'' || this_sample_name || E'\'' || 
      ' from core.dna_seqs where exists ' ||
      ' (select 1 from core.mg_dnas where dna_seqs.did = mg_dnas.did ' ||
      'and dna_seqs.did_auth = mg_dnas.did_code and ' ||
      'mg_dnas.sample_name = ' || 
      E'\'' || this_sample_name || E'\'' ||
      ');';
    EXECUTE 'delete from core.dna_seqs where exists ' ||
      ' (select 1 from core.mg_dnas where dna_seqs.did = mg_dnas.did ' ||
      'and dna_seqs.did_auth = mg_dnas.did_code and ' ||
      'mg_dnas.sample_name = ' || 
      E'\'' || this_sample_name || E'\'' ||
      ');';
    EXECUTE 'delete from core.mg_dnas where sample_name = ' ||
      E'\'' || this_sample_name || E'\'' ||
      ';';
    return true;
  END;
$$ language plpgsql; 

-- create partitions for all samples, that have metagenomic sequences attached
select import_mg_partition(sample_name) from mg_dnas group by sample_name;
-- test only select import_mg_partition('GS001b'); 

alter table mg_dnas rename to mg_dnas_old;
select count(*) from mg_dnas_old;

-- create mg_dnas view 
select rebuild_mg_view();

-- function to import data should not be used afterwards
drop function import_mg_partition(text);

create or replace function core.insert_into_correct_mg_partition() returns trigger as $$
  DECLARE
    this_part_id int;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id into this_part_id from core.metagenomic_partitions where sample_name = NEW.sample_name and active = true  and included = true; 
    IF this_part_id IS NULL THEN 
      PERFORM core.create_mg_partition(NEW.sample_name);
      SELECT partition_id into this_part_id from core.metagenomic_partitions where sample_name = NEW.sample_name;
    END IF;
    insertSql := 'INSERT INTO partitions.sample_' || cast(this_part_id as text) || ' ';
    FOR field IN select * from skeys(insertRecord) LOOP
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
    return NEW;
  END;
$$ language plpgsql;

CREATE TRIGGER mg_dnas_insert
    INSTEAD OF INSERT ON mg_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE insert_into_correct_mg_partition();
    
CREATE OR REPLACE RULE mg_dnas_rebuild
	AS ON INSERT TO core.mg_dnas
	DO ALSO SELECT core.rebuild_mg_view();
    
create or replace function core.update_correct_mg_partition() returns trigger as $$
  DECLARE
    this_part_id int;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id into this_part_id from core.metagenomic_partitions where sample_name = OLD.sample_name and active = true  and included = true; 
    IF this_part_id IS NULL THEN 
      RETURN NULL;
    END IF;
    updateSql := 'UPDATE partitions.sample_' || cast(this_part_id as text) || ' SET ';
    FOR field IN select * from skeys(updateRecord) LOOP
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
    return NEW;
  END;
$$ language plpgsql;

CREATE TRIGGER mg_dnas_update
    INSTEAD OF UPDATE ON core.mg_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE core.update_correct_mg_partition();
    
create or replace function core.delete_from_correct_mg_partition() returns trigger as $$
  DECLARE this_part_id int;
  BEGIN
    SELECT partition_id from core.metagenomic_partitions where sample_name = OLD.sample_name  and active = true  and included = true into this_part_id;
    IF this_part_id IS NULL THEN 
      RETURN NULL;
    END IF; 
    EXECUTE 'DELETE FROM partitions.sample_' || this_part_id || 
      ' where did = ' ||  E'\'' || OLD.did || E'\'' || ' and ' ||
      'did_auth = ' || E'\'' || OLD.did_auth ||  E'\'' || ' and ' ||
      'sample_name = ' || E'\'' || OLD.sample_name ||  E'\'' || ' and ' ||
      'study = ' ||  E'\'' || OLD.study ||  E'\'' || ';';
    return OLD;
  END;
$$ language plpgsql;

CREATE TRIGGER mg_dnas_delete
    INSTEAD OF DELETE ON mg_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE delete_from_correct_mg_partition();

/*
 * Part C: Partitioning of clonelib sequences
 */

--template for partitions, should not be accessed in any way
create table clonelib_sequences_template (
  like dna_seqs including defaults,
  study text,
  lib_name text NOT NULL, -- name of clone library
  clone_name text NOT NULL, -- name of clone
  check (lib_name = '')
);
revoke insert on clonelib_sequences_template from public;

-- table to store partition ids 
create sequence cl_partition_seq;
create table clonelib_partitions (
  partition_id int4,
  lib_name text unique,
  active boolean,
  included boolean
);

--function to create a new partition by sample name
create or replace function core.create_cl_partition(lib_name text) returns int as $$
  DECLARE next_id int4;
  BEGIN
    select nextval('core.cl_partition_seq') into next_id;
    EXECUTE 'create table partitions.clonelib_' || next_id || ' (' ||
      'like core.clonelib_sequences_template including defaults,' ||
      'primary key (lib_name, did, did_auth, study, clone_name),' ||
      'FOREIGN KEY (study, lib_name, clone_name)' ||
      '    REFERENCES core.clones (study, lib_name, label) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (assembly_status)' ||
      '    REFERENCES cv.assembly_status (term) MATCH SIMPLE' ||
      '    ON UPDATE CASCADE ON DELETE NO ACTION,' ||
      'FOREIGN KEY (own)' ||
      '    REFERENCES core.logins (logname) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (project)' ||
      '    REFERENCES core.projects (id) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'FOREIGN KEY (seq_method)' ||
      '    REFERENCES cv.seq_methods (term) MATCH SIMPLE' ||
      '    ON UPDATE NO ACTION ON DELETE NO ACTION,' ||
      'check (lib_name = ' || E'\'' || lib_name || E'\'' || ')' ||
    '); ';
    EXECUTE 'insert into core.clonelib_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || lib_name || E'\'' || 
      ', true, false);';
    return next_id;
  END;
$$ language plpgsql;

create or replace function core.rebuild_cl_view() returns boolean as $$
  DECLARE part_tables text[];
  DECLARE view_ddl text = 'CREATE OR REPLACE VIEW core.clonelib_dnas as select * from core.clonelib_sequences_template union all ';
  DECLARE i text;
  BEGIN
    select array_agg(a.tablename) from (select ('partitions.clonelib_' || cast(partition_id as text)) as tablename from core.clonelib_partitions where active = true) as a into part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select * from '|| i || ' union all '; 
      END LOOP;
    END IF;
    select trim(trailing ' union all ' from view_ddl) into view_ddl;
    EXECUTE view_ddl;
    update core.clonelib_partitions set included = true where active = true;
    RETURN true;
  END;
$$ language plpgsql;

-- function to import data from dna_seqs to new partition
create or replace function import_cl_partition(this_lib_name text) returns boolean as $$
  DECLARE
    this_study text;
    this_clone text;
    part_id int;
  BEGIN
    select core.clonelib_dnas.study into this_study from core.clonelib_dnas where core.clonelib_dnas.lib_name = this_lib_name;
    select core.clonelib_dnas.clone_name into this_clone from core.clonelib_dnas where core.clonelib_dnas.lib_name = this_lib_name;
    raise notice 'Importing clonelib % from clone %, study  %...', this_lib_name, this_clone, this_study;
    EXECUTE 'select core.create_cl_partition(' || E'\'' || this_lib_name || E'\'' || ');';
    select partition_id from core.clonelib_partitions where lib_name = this_lib_name into part_id;
    EXECUTE 'insert into partitions.clonelib_' || part_id ||
      ' select *, ' || E'\'' || this_study || E'\'' || ', ' ||
      E'\'' || this_lib_name || E'\',' || 
      E'\'' || thia_clone || E'\'' ||
      ' from core.dna_seqs where exists ' ||
      ' (select 1 from core.clonelib_dnas where dna_seqs.did = clonelib_dnas.did ' ||
      'and dna_seqs.did_auth = clonelib_dnas.did_code and ' ||
      'clonelib_dnas.sample_name = ' || 
      E'\'' || this_lib_name || E'\'' ||
      ');';
    EXECUTE 'delete from core.dna_seqs where exists ' ||
      ' (select 1 from core.clonelib_dnas where dna_seqs.did = clonelib_dnas.did ' ||
      'and dna_seqs.did_auth = clonelib_dnas.did_code and ' ||
      'clonelib_dnas.sample_name = ' || 
      E'\'' || this_lib_name || E'\'' ||
      ');';
    EXECUTE 'delete from core.clonelib_dnas where lib_name = ' ||
      E'\'' || this_lib_name || E'\'' ||
      ';';
    return true;
  END;
$$ language plpgsql; 

-- create partitions for all samples, that have metagenomic sequences attached
select import_cl_partition(lib_name) from clonelib_dnas group by lib_name;
-- test only select import_mg_partition('GS001b'); 

alter table clonelib_dnas rename to clonelib_dnas_old;
select count(*) from clonelib_dnas_old;

-- create mg_dnas view 
select rebuild_cl_view();

-- function to import data should not be used afterwards
drop function import_cl_partition(text);

create or replace function core.insert_into_correct_cl_partition() returns trigger as $$
  DECLARE
    this_part_id int;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id into this_part_id from core.clonelib_partitions where lib_name = NEW.lib_name and active = true and included = true; 
    IF this_part_id IS NULL THEN 
      PERFORM core.create_cl_partition(NEW.lib_name);
      SELECT partition_id into this_part_id from core.clonelib_partitions where lib_name = NEW.lib_name;
    END IF;
    insertSql := 'INSERT INTO partitions.clonelib_' || cast(this_part_id as text) || ' ';
    FOR field IN select * from skeys(insertRecord) LOOP
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
    return NEW;
  END;
$$ language plpgsql;

CREATE TRIGGER clonelib_dnas_insert
    INSTEAD OF INSERT ON clonelib_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE insert_into_correct_cl_partition();
    
CREATE OR REPLACE RULE clonelib_dnas_rebuild
	AS ON INSERT TO core.clonelib_dnas
	DO ALSO SELECT core.rebuild_cl_view();

create or replace function core.update_correct_cl_partition() returns trigger as $$
  DECLARE
    this_part_id int;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id into this_part_id from core.clonelib_partitions where lib_name = OLD.lib_name and active = true and included = true;
    IF this_part_id IS NULL THEN 
      RETURN NULL;
    END IF;
    updateSql := 'UPDATE partitions.clonelib_' || cast(this_part_id as text) || ' SET ';
    FOR field IN select * from skeys(updateRecord) LOOP
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
    return NEW;
  END;
$$ language plpgsql;

CREATE TRIGGER clonelib_dnas_update
    INSTEAD OF UPDATE ON clonelib_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE update_correct_cl_partition();

create or replace function delete_from_correct_cl_partition() returns trigger as $$
  DECLARE this_part_id int;
  BEGIN
    SELECT partition_id from core.clonelib_partitions where lib_name = OLD.lib_name  and active = true  and included = true into this_part_id; 
    IF this_part_id IS NULL THEN 
      RETURN NULL;
    END IF;
    EXECUTE 'DELETE FROM partitions.clonelib_' || this_part_id || 
      ' where did = ' ||  E'\'' || OLD.did || E'\'' || ' and ' ||
      'did_auth = ' || E'\'' || OLD.did_auth ||  E'\'' || ' and ' ||
      'lib_name = ' || E'\'' || OLD.lib_name ||  E'\'' || ' and ' ||
      'clone_name = ' || E'\'' || OLD.clone_name ||  E'\'' || ' and ' ||
      'study = ' ||  E'\'' || OLD.study ||  E'\'' || ';';
    return OLD;
  END;
$$ language plpgsql;

CREATE TRIGGER clonelib_dnas_delete
    INSTEAD OF DELETE ON clonelib_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE delete_from_correct_cl_partition();
/*
 * Part D: Partitioning of pooled metagenomic sequences
 */
--template for partitions, should not be accessed in any way
create table pooled_metagenomic_sequences_template (
	like dna_seqs including defaults,
	study text,
	pool_label text,
	check (pool_label = '')
);
revoke insert on pooled_metagenomic_sequences_template from public;

-- table to store partition ids 
create sequence pooled_mg_partition_seq;
alter table sample_pools add constraint sample_pool_label_unique unique (label);
create table pooled_metagenomic_partitions (
  partition_id int4,
  pool_label text references sample_pools(label),
  active boolean,
  included boolean
);

--function to create a new partition by sample name
create or replace function core.create_pooled_mg_partition(pool_label text) returns int as $$
  DECLARE next_id int4;
  BEGIN
    select nextval('core.pooled_mg_partition_seq') into next_id;
    EXECUTE 'create table partitions.pool_' || next_id || ' (' ||
      'like core.pooled_metagenomic_sequences_template including defaults,' ||
      'primary key (pool_label, did, did_auth, study),' ||
      'FOREIGN KEY (assembly_status)' ||
      '    REFERENCES cv.assembly_status (term) MATCH SIMPLE' ||
      '    ON UPDATE CASCADE ON DELETE NO ACTION,' ||
      'FOREIGN KEY (own)' ||
      '    REFERENCES core.logins (logname) MATCH SIMPLE' ||
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
    EXECUTE 'insert into core.pooled_metagenomic_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || pool_label || E'\'' || 
      ', true, false);';
    return next_id;
  END;
$$ language plpgsql;

create or replace function core.rebuild_pooled_mg_view() returns boolean as $$
  DECLARE part_tables text[];
  DECLARE view_ddl text = 'CREATE OR REPLACE VIEW core.mg_pooled_dnas as select * from core.pooled_metagenomic_sequences_template union all ';
  DECLARE i text;
  BEGIN
    select array_agg(a.tablename) from (select ('partitions.pool_' || cast(partition_id as text)) as tablename from core.pooled_metagenomic_partitions where active = true) as a into part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select * from '|| i || ' union all '; 
      END LOOP;
    END IF;
    select trim(trailing ' union all ' from view_ddl) into view_ddl;
    EXECUTE view_ddl;
    update core.pooled_metagenomic_partitions set included = true where active = true;
    RETURN true;
  END;
$$ language plpgsql;

-- function to import data from dna_seqs to new partition
create or replace function import_pooled_mg_partition(this_pool_label text) returns boolean as $$
  DECLARE
    this_study text;
    part_id int;
  BEGIN
    select core.sample_pools.study into this_study from core.sample_pools where core.sample_pools.label = this_pool_label;
    raise notice 'Importing pool % from study  %...', this_pool_label, this_study;
    EXECUTE 'select core.create_pooled_mg_partition(' || E'\'' || this_pool_label || E'\'' || ');';
    select partition_id from core.pooled_metagenomic_partitions where pool_label = this_pool_label into part_id;
    EXECUTE 'insert into partitions.pool_' || part_id ||
      ' select *, ' || E'\'' || this_study || E'\'' || ', ' ||
      E'\'' || this_pool_label || E'\'' || 
      ' from core.dna_seqs where exists ' ||
      ' (select 1 from core.mg_pooled_dnas where dna_seqs.did = mg_pooled_dnas.did ' ||
      'and dna_seqs.did_auth = mg_pooled_dnas.did_code and ' ||
      'mg_pooled_dnas.pool_label = ' || 
      E'\'' || this_pool_label || E'\'' ||
      ');';
    EXECUTE 'delete from core.dna_seqs where exists ' ||
      ' (select 1 from core.mg_pooled_dnas where dna_seqs.did = mg_pooled_dnas.did ' ||
      'and dna_seqs.did_auth = mg_pooled_dnas.did_code and ' ||
      'mg_pooled_dnas.pool_label = ' || 
      E'\'' || this_pool_label || E'\'' ||
      ');';
    EXECUTE 'delete from core.mg_pooled_dnas where pool_label = ' ||
      E'\'' || this_pool_label || E'\'' ||
      ';';
    return true;
  END;
$$ language plpgsql; 

-- create partitions for all samples, that have metagenomic sequences attached
select import_pooled_mg_partition(pool_label) from mg_pooled_dnas group by pool_label;
-- test only select import_mg_partition('GS001b'); 

alter table mg_pooled_dnas rename to mg_pooled_dnas_old;
select count(*) from mg_pooled_dnas_old;

-- create mg_dnas view 
select rebuild_pooled_mg_view();

-- function to import data should not be used afterwards
drop function import_pooled_mg_partition(text);

create or replace function core.insert_into_correct_pooled_mg_partition() returns trigger as $$
  DECLARE
    this_part_id int;
    insertSql text;
    rowOrder text = '(';
    insertValues text = 'values (';
    insertRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id into this_part_id from core.pooled_metagenomic_partitions where pool_label = NEW.pool_label and active = true  and included = true; 
    IF this_part_id IS NULL THEN 
      select core.create_pooled_mg_partition(NEW.pool_label);
      SELECT partition_id into this_part_id from core.pooled_metagenomic_partitions where pool_label = NEW.pool_label;
    END IF;
    insertSql := 'INSERT INTO partitions.pool_' || cast(this_part_id as text) || ' ';
    FOR field IN select * from skeys(insertRecord) LOOP
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
    return NEW;
  END;
$$ language plpgsql;

CREATE TRIGGER pooled_mg_dnas_insert
    INSTEAD OF INSERT ON core.mg_pooled_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE insert_into_correct_pooled_mg_partition();
    
CREATE OR REPLACE RULE pooled_mg_dnas_rebuild
	AS ON INSERT TO core.mg_pooled_dnas
	DO ALSO SELECT core.rebuild_pooled_mg_view();

create or replace function core.update_correct_pooled_mg_partition() returns trigger as $$
  DECLARE
    this_part_id int;
    updateSql text;
    updateValues text = '';
    whereClause text;
    updateRecord hstore = hstore(NEW); -- record as hstore to iterate through fields
    field text;
  BEGIN
    SELECT partition_id into this_part_id from core.pooled_metagenomic_partitions where pool_label = OLD.pool_label and active = true  and included = true; 
    IF this_part_id IS NULL THEN 
      RETURN NULL;
    END IF;
    updateSql := 'UPDATE partitions.pool_' || cast(this_part_id as text) || ' SET ';
    FOR field IN select * from skeys(updateRecord) LOOP
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
    return NEW;
  END;
$$ language plpgsql;

CREATE TRIGGER pooled_mg_dnas_update
    INSTEAD OF UPDATE ON core.mg_pooled_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE update_correct_pooled_mg_partition();

create or replace function delete_from_correct_pooled_mg_partition() returns trigger as $$
  DECLARE this_part_id int;
  BEGIN
    SELECT partition_id from core.pooled_metagenomic_partitions where pool_label = OLD.pool_label  and active = true  and included = true into this_part_id; 
    IF this_part_id IS NULL THEN 
      RETURN NULL;
    END IF;
    EXECUTE 'DELETE FROM partitions.pool_label_' || this_part_id || 
      ' where did = ' ||  E'\'' || OLD.did || E'\'' || ' and ' ||
      'did_auth = ' || E'\'' || OLD.did_auth ||  E'\'' || ' and ' ||
      'pool_label = ' || E'\'' || OLD.pool_label ||  E'\'' || ' and ' ||
      'study = ' ||  E'\'' || OLD.study ||  E'\'' || ';';
    return OLD;
  END;
$$ language plpgsql;

CREATE TRIGGER pooled_mg_dnas_delete
    INSTEAD OF DELETE ON mg_pooled_dnas
    FOR EACH ROW
    EXECUTE PROCEDURE delete_from_correct_pooled_mg_partition();

commit;

--begin;
--select create_mg_partition('gprj:103');
--select create_mg_partition('gprj:101');
--select create_mg_partition('gprj:104');
--select * from core.metagenomic_partitions;
--select rebuild_mg_view();
--insert into mg_dnas (did, did_auth, assembly_status, study, sample_name, dna) values ('test', 'ref', 'contig', 'genome', 'gprj:101', 'ACGACTACGACTAC');
--explain select * from mg_dnas where sample_name = 'gprj:101';
--select * from mg_dnas where sample_name = 'gprj:101';
--delete from mg_dnas where sample_name = 'gprj:101';  
--select * from mg_dnas where sample_name = 'gprj:101';
--rollback;

