BEGIN;

SELECT _v.register_patch( '28-compress-sequence-data', ARRAY['1-partitioning'], NULL );

CREATE EXTENSION postbis;

/*
 * Part I: Genomic Sequences
 */
ALTER TABLE core.genomic_sequences ADD COLUMN dna_compressed dna_sequence NOT NULL DEFAULT ''::dna_sequence;

UPDATE core.genomic_sequences SET dna_compressed = dna::dna_sequence;

CREATE FUNCTION check_genomic_sequences() RETURNS INT AS $$
DECLARE
  rows RECORD;
BEGIN
  FOR rows IN SELECT did, did_auth FROM core.genomic_sequences WHERE dna != dna_compressed::text LOOP
    RAISE EXCEPTION 'Sequence mismatch for sequence %', rows.did;
  END LOOP;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

SELECT check_genomic_sequences();

DROP FUNCTION check_genomic_sequences();

ALTER TABLE core.genomic_sequences DROP COLUMN dna;
ALTER TABLE core.genomic_sequences RENAME COLUMN dna_compressed TO dna;

/*
 * Part II: Metagenomic Sequences
 */
CREATE FUNCTION compress_metagenomic_partitions() RETURNS integer AS $$
DECLARE
  partitions RECORD;
  c INT;
BEGIN
  FOR partitions IN SELECT * FROM core.metagenomic_partitions LOOP
    RAISE NOTICE 'Compressing metagenomic partition # %', partitions.partition_id;
    EXECUTE 'ALTER TABLE partitions.sample_' || partitions.partition_id || ' ' ||
               'ADD COLUMN dna_compressed dna_sequence NOT NULL DEFAULT ' || E'\'\'' || '::dna_sequence;';
    EXECUTE 'UPDATE partitions.sample_' || partitions.partition_id || ' ' ||
               'SET dna_compressed = dna::dna_sequence;';
    EXECUTE 'SELECT count(*) FROM partitions.sample_' || partitions.partition_id || ' WHERE dna != dna_compressed::text' INTO c;
    IF c > 0 THEN
      RAISE EXCEPTION 'Sequence mismatch for % sequences', c;
    END IF;
    EXECUTE 'ALTER TABLE partitions.sample_' || partitions.partition_id || ' ' ||
               'DROP COLUMN dna;';
    EXECUTE 'ALTER TABLE partitions.sample_' || partitions.partition_id || ' ' ||
               'RENAME COLUMN dna_compressed TO dna;';
  END LOOP;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION core.rebuild_mg_view() RETURNS BOOLEAN AS $$
  DECLARE part_tables text[];
  DECLARE view_ddl text = 'CREATE OR REPLACE VIEW core.mg_dnas as select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, sample_name from core.metagenomic_sequences_template union all ';
  DECLARE i text;
  BEGIN
    select array_agg(a.tablename) from (select ('partitions.sample_' || cast(partition_id as text)) as tablename from core.metagenomic_partitions where active = true) as a into part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, sample_name from '|| i || ' union all '; 
      END LOOP;
    END IF;
    select trim(trailing ' union all ' from view_ddl) into view_ddl;
    EXECUTE view_ddl;
    update core.metagenomic_partitions set included = true where active = true;
    RETURN true;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW core.mg_dnas AS
  SELECT
	''::text AS dna, 
	0::integer AS size, 
	'NaN'::numeric AS gc, 
	''::text AS seq_method, 
	''::text AS data_source, 
	''::text AS assembly_status, 
	now()::timestamp AS retrieved, 
	0::integer AS project, 
	'megdb'::text AS own, 
	''::text AS did, 
	''::text AS did_auth, 
	''::text AS mol_type, 
	''::text AS acc_ver, 
	''::char(32) AS md5sum, 
	''::text AS study, 
	''::text AS sample_name
  ;

SELECT compress_metagenomic_partitions();
DROP FUNCTION compress_metagenomic_partitions();

ALTER TABLE core.metagenomic_sequences_template DROP COLUMN dna;
ALTER TABLE core.metagenomic_sequences_template ADD COLUMN dna dna_sequence NOT NULL DEFAULT ''::dna_sequence;

SELECT core.rebuild_mg_view();

/*
 * Part III: Clonelib Sequences
 */
CREATE FUNCTION compress_clonelib_partitions() RETURNS integer AS $$
DECLARE
  partitions RECORD;
  c INT;
BEGIN
  FOR partitions IN SELECT * FROM core.clonelib_partitions LOOP
    RAISE NOTICE 'Compressing clonelib partition # %', partitions.partition_id;
    EXECUTE 'ALTER TABLE partitions.clonelib_' || partitions.partition_id || ' ' ||
               'ADD COLUMN dna_compressed dna_sequence NOT NULL DEFAULT ' || E'\'\'' || '::dna_sequence;';
    EXECUTE 'UPDATE partitions.clonelib_' || partitions.partition_id || ' ' ||
               'SET dna_compressed = dna::dna_sequence;';
    EXECUTE 'SELECT count(*) FROM partitions.clonelib_' || partitions.partition_id || ' WHERE dna != dna_compressed::text' INTO c;
    IF c > 0 THEN
      RAISE EXCEPTION 'Sequence mismatch for % sequences', c;
    END IF;
    EXECUTE 'ALTER TABLE partitions.clonelib_' || partitions.partition_id || ' ' ||
               'DROP COLUMN dna;';
    EXECUTE 'ALTER TABLE partitions.clonelib_' || partitions.partition_id || ' ' ||
               'RENAME COLUMN dna_compress TO dna;';
  END LOOP;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

create or replace function core.rebuild_cl_view() returns boolean as $$
  DECLARE part_tables text[];
  DECLARE view_ddl text = 'CREATE OR REPLACE VIEW core.clonelib_dnas as select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, lib_name, clone_name from core.clonelib_sequences_template union all ';
  DECLARE i text;
  BEGIN
    select array_agg(a.tablename) from (select ('partitions.clonelib_' || cast(partition_id as text)) as tablename from core.clonelib_partitions where active = true) as a into part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, lib_name, clone_name from '|| i || ' union all '; 
      END LOOP;
    END IF;
    select trim(trailing ' union all ' from view_ddl) into view_ddl;
    EXECUTE view_ddl;
    update core.clonelib_partitions set included = true where active = true;
    RETURN true;
  END;
$$ language plpgsql;

CREATE OR REPLACE VIEW core.clonelib_dnas AS
  SELECT
	''::text AS dna,
	0::integer AS size,
	'NaN'::numeric AS gc,
	''::text AS seq_method,
	''::text AS data_source,
	''::text AS assembly_status,
	now()::timestamp AS retrieved,
	0::integer AS project,
	'megdb'::text AS own,
	''::text AS did,
	''::text AS did_auth,
	''::text AS mol_type,
	''::text AS acc_ver,
	''::char(32) AS md5sum,
	''::text AS study,
	''::text AS lib_name,
	''::text AS clone_name
  ;

SELECT compress_clonelib_partitions();
DROP FUNCTION compress_clonelib_partitions();

ALTER TABLE core.clonelib_sequences_template DROP COLUMN dna;
ALTER TABLE core.clonelib_sequences_template ADD COLUMN dna dna_sequence NOT NULL DEFAULT ''::dna_sequence;

SELECT core.rebuild_cl_view();

/*
 * Part III: Pooled Sequences
 */
CREATE FUNCTION compress_pooled_partitions() RETURNS integer AS $$
DECLARE
  partitions RECORD;
  c INT;
BEGIN
  FOR partitions IN SELECT * FROM core.pooled_metagenomic_partitions LOOP
    RAISE NOTICE 'Compressing pooled metagenomic partition # %', partitions.partition_id;
    EXECUTE 'ALTER TABLE partitions.pool_' || partitions.partition_id || ' ' ||
               'ADD COLUMN dna_compressed dna_sequence NOT NULL DEFAULT ' || E'\'\'' || '::dna_sequence;';
    EXECUTE 'UPDATE partitions.pool_' || partitions.partition_id || ' ' ||
               'SET dna_compressed = dna::dna_sequence;';
    EXECUTE 'SELECT count(*) FROM partitions.pool_' || partitions.partition_id || ' WHERE upper(dna) != dna_compressed::text' INTO c;
    IF c > 0 THEN
      RAISE EXCEPTION 'Sequence mismatch for % sequences', c;
    END IF;
    EXECUTE 'ALTER TABLE partitions.pool_' || partitions.partition_id || ' ' ||
               'DROP COLUMN dna;';
    EXECUTE 'ALTER TABLE partitions.pool_' || partitions.partition_id || ' ' ||
               'RENAME COLUMN dna_compressed TO dna;';
  END LOOP;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION core.rebuild_pooled_mg_view() RETURNS BOOLEAN AS $$
  DECLARE part_tables text[];
  DECLARE view_ddl text = 'CREATE OR REPLACE VIEW core.mg_pooled_dnas as select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, pool_label from core.pooled_metagenomic_sequences_template union all ';
  DECLARE i text;
  BEGIN
    select array_agg(a.tablename) from (select ('partitions.pool_' || cast(partition_id as text)) as tablename from core.pooled_metagenomic_partitions where active = true) as a into part_tables;
    IF part_tables IS NOT NULL THEN
      FOREACH i IN ARRAY part_tables
      LOOP
        view_ddl = view_ddl || 'select dna::text AS dna, size, gc, seq_method, data_source, assembly_status, retrieved, project, own, did, did_auth, mol_type, acc_ver, md5sum, study, pool_label from '|| i || ' union all '; 
      END LOOP;
    END IF;
    select trim(trailing ' union all ' from view_ddl) into view_ddl;
    EXECUTE view_ddl;
    update core.pooled_metagenomic_partitions set included = true where active = true;
    RETURN true;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW core.mg_pooled_dnas AS
  SELECT
    ''::text AS dna,
    0::integer AS size,
    'NaN'::numeric AS gc,
    ''::text AS seq_method,
    ''::text AS data_source,
    ''::text AS assembly_status,
    now()::timestamp retrieved,
    0::integer AS project,
    'megdb'::text AS own,
    ''::text AS did,
    ''::text AS did_auth,
    ''::text AS mol_type,
    ''::text AS acc_ver,
    ''::char(32) AS md5sum,
    ''::text AS study,
    ''::text AS pool_label
  ;

SELECT compress_pooled_partitions();
DROP FUNCTION compress_pooled_partitions();

ALTER TABLE core.pooled_metagenomic_sequences_template DROP COLUMN dna;
ALTER TABLE core.pooled_metagenomic_sequences_template ADD COLUMN dna dna_sequence NOT NULL DEFAULT ''::dna_sequence;

SELECT core.rebuild_pooled_mg_view();

/*
 * Fix views
 */
SET search_path TO core, public; 

CREATE OR REPLACE VIEW core.mg_all_dnas AS 
         SELECT mg_dnas.study, mg_dnas.sample_name AS sample_label, mg_dnas.did, mg_dnas.did_auth as did_code
           FROM core.mg_dnas mg_dnas
UNION ALL 
         SELECT mg_pooled_dnas.study, mg_pooled_dnas.pool_label AS sample_label, mg_pooled_dnas.did, mg_pooled_dnas.did_auth as did_code
           FROM core.mg_pooled_dnas mg_pooled_dnas;

SET search_path TO web, public;

CREATE OR REPLACE VIEW web.blast_gos AS 
 SELECT t.sid, t.jid, t.id, t.hit, t.hsp, 'GOS read '::text || t.hit_acc AS descr, t.hit_acc AS acc, t.h_length, t.evalue, t.bit_score, t.q_from, t.q_to, t.h_from, t.h_to, t.q_frame, t.h_frame, t.ident, t.pos, t.a_length, 'GOS read '::text || t.hit_acc AS locdesc, core.pp_geom(s.old_geom) AS latlon, s.old_geom AS geom, s.hab_lite, mgd.sample_name, ( SELECT (sm.vals[1]::text || ' '::text) || sm.unit AS vals
           FROM core.sample_measures sm
          WHERE sm.param = 'depth'::text AND sm.sid = s.sid) AS depth, ( SELECT (sm.vals[1]::text || ' '::text) || sm.unit AS vals
           FROM core.sample_measures sm
          WHERE sm.param = 'temperature'::text AND sm.sid = s.sid) AS temperature
   FROM core.blast_hits t
   JOIN core.mg_dnas mgd ON mgd.did = t.hit_acc
   JOIN core.samples s ON s.label = mgd.sample_name
  WHERE t.db = 'gos'::text;

COMMIT;

