SET search_path TO core, cv, public;
SET constraint_exclusion TO on;

begin;
SELECT _v.register_patch( '4-regions-partitioning', ARRAY['1-partitioning'], NULL );

ALTER TABLE core.multiregion_members DROP CONSTRAINT multiregion_members_regions_fkey;
ALTER TABLE core.multiregion_members DROP CONSTRAINT multiregions_fkey;

-- TODO adapt partition schema to regions

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

ROLLBACK;