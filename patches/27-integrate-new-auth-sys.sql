BEGIN;

SELECT _v.register_patch( '27-integrate-new-auth-sys', ARRAY['8-authdb'], NULL );

/*
 * Step 1: Insert old users into new authorities table
 */
INSERT INTO auth.users (logname, first_name, initials, last_name, description, join_date, disabled, email)
  SELECT logname, first_name, initials, last_name, descr, join_date, FALSE, 'no@email.addi' FROM core.logins ;

/*
 * Step 2: Divert all hard-wired foreign keys on core.logins to auth.users
 */
ALTER TABLE core.clonelibs DROP CONSTRAINT clonelibs_own_fkey,
                           ADD CONSTRAINT clonelibs_own_fkey
                             FOREIGN KEY (own) REFERENCES auth.users (logname)
                             MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.data_sources DROP CONSTRAINT data_sources_maintainer_fkey,
                              ADD CONSTRAINT data_sources_maintainer_fkey
                                FOREIGN KEY (maintainer) REFERENCES auth.users (logname)
                                MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.genomic_sequences DROP CONSTRAINT genomic_sequences_own_fkey,
                                   ADD CONSTRAINT genomic_sequences_own_fkey
                                     FOREIGN KEY (own) REFERENCES auth.users (logname)
                                     MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.isolates DROP CONSTRAINT isolates_own_fkey,
                          ADD CONSTRAINT isolates_own_fkey
                            FOREIGN KEY (own) REFERENCES auth.users (logname)
                            MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.sample_measures DROP CONSTRAINT sample_measures_own_fkey,
                                 ADD CONSTRAINT sample_measures_own_fkey
                                   FOREIGN KEY (own) REFERENCES auth.users (logname)
                                   MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.sample_set_mdata DROP CONSTRAINT sample_set_mdata_own_fkey,
                                   ADD CONSTRAINT sample_set_mdata_own_fkey
                                     FOREIGN KEY (own) REFERENCES auth.users (logname)
                                     MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.aux_project DROP CONSTRAINT samples_own_fkey,
                             ADD CONSTRAINT aux_project_own_fkey
                               FOREIGN KEY (own) REFERENCES auth.users (logname)
                               MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.samplingsites DROP CONSTRAINT samplingsites_georef_by_fkey,
                               ADD CONSTRAINT samplingsites_georef_by_fkey
                                 FOREIGN KEY (georef_by) REFERENCES auth.users (logname)
                                 MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.samplingsites DROP CONSTRAINT samplingsites_own_fkey,
                               ADD CONSTRAINT samplingsites_own_fkey
                                 FOREIGN KEY (own) REFERENCES auth.users (logname)
                                 MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.tool_dna_runs DROP CONSTRAINT tool_dna_runs_who_fkey,
                               ADD CONSTRAINT tool_dna_runs_who_fkey
                                 FOREIGN KEY (who) REFERENCES auth.users (logname)
                                 MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.ribosomal_sequences DROP CONSTRAINT ribosomal_sequences_own_fkey,
                                     ADD CONSTRAINT ribosomal_sequences_own_fkey
                                       FOREIGN KEY (own) REFERENCES auth.users (logname)
                                       MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.ribosomal_sequences DROP CONSTRAINT ribosomal_sequences_own_fkey,
                                     ADD CONSTRAINT ribosomal_sequences_own_fkey
                                       FOREIGN KEY (own) REFERENCES auth.users (logname)
                                       MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE core.assignments DROP CONSTRAINT assignments_person_fkey,
                             ADD CONSTRAINT assignments_person_fkey
                               FOREIGN KEY (person, "role") REFERENCES auth.has_roles (user_login, "role")
                               MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
/*
 * Step 3: Rewire all partition foreign keys on core.logins to auth.users
 */
CREATE FUNCTION rewire_partitions() RETURNS integer AS $$
DECLARE
  partitions RECORD;
BEGIN
  FOR partitions IN SELECT * FROM core.metagenomic_partitions LOOP
    RAISE NOTICE 'Rewiring metagenomic partition # %', partitions.partition_id;
    EXECUTE 'ALTER TABLE partitions.sample_' || partitions.partition_id || ' ' ||
               'DROP CONSTRAINT sample_' || partitions.partition_id || '_own_fkey, ' ||
               'ADD CONSTRAINT sample_' || partitions.partition_id || '_own_fkey ' ||
                 'FOREIGN KEY (own) REFERENCES auth.users (logname) ' ||
                 'MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION';
  END LOOP;
  FOR partitions IN SELECT * FROM core.clonelib_partitions LOOP
    RAISE NOTICE 'Rewiring clonelib partition # %', partitions.partition_id;
    EXECUTE 'ALTER TABLE partitions.clonelib_' || partitions.partition_id || ' ' ||
               'DROP CONSTRAINT clonelib_' || partitions.partition_id || '_own_fkey, ' ||
               'ADD CONSTRAINT clonelib_' || partitions.partition_id || '_own_fkey ' ||
                 'FOREIGN KEY (own) REFERENCES auth.users (logname) ' ||
                 'MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION';
  END LOOP;
  FOR partitions IN SELECT * FROM core.pooled_metagenomic_partitions LOOP
    RAISE NOTICE 'Rewiring pooled metagenomic partition # %', partitions.partition_id;
    EXECUTE 'ALTER TABLE partitions.pool_' || partitions.partition_id || ' ' ||
               'DROP CONSTRAINT pool_' || partitions.partition_id || '_own_fkey, ' ||
               'ADD CONSTRAINT pool_' || partitions.partition_id || '_own_fkey ' ||
                 'FOREIGN KEY (own) REFERENCES auth.users (logname) ' ||
                 'MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION';
  END LOOP;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

SELECT rewire_partitions();

DROP FUNCTION rewire_partitions();

/*
 * Step 4: Update partition creation functions
 */
create or replace function core.create_mg_partition(sample_name text) returns int as $$
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
    EXECUTE 'insert into core.metagenomic_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || sample_name || E'\'' || 
      ', true, false);';
    return next_id;
  END;
$$ language plpgsql;

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
    EXECUTE 'insert into core.clonelib_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || lib_name || E'\'' || 
      ', true, false);';
    return next_id;
  END;
$$ language plpgsql;

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
    EXECUTE 'insert into core.pooled_metagenomic_partitions values ( ' ||
      next_id || ',' ||
      E'\'' || pool_label || E'\'' || 
      ', true, false);';
    return next_id;
  END;
$$ language plpgsql;

/*
 * Step 5: Remove remainders
 */
DROP TABLE core.person_roles;
DROP TABLE core.role_links;
DROP TABLE core.role_privs;
DROP TABLE core.roles;
DROP TABLE core.privs;
                                     
COMMIT;

