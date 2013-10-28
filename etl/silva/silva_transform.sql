--
-- silva_transform.sql
--
-- This file is used by the silva_etl.pl script. It substitutes %LSUSCHEMA% and 
-- %SSUSCHEMA% place-holders by the silva schema names in the correct revision.
-- Thus, this script cannot be executed directly.
--
-- This script reuses the legacy code of
--    silva_regions_v and
--    silva_samples_v
--
-- The views and the script depend on the following silva tables
--    silva_rXXX_Xsu_web.sequence
--    silva_rXXX_Xsu_web.sequenceentry
--    silva_rXXX_Xsu_web.region
--
-- The following MegDb staging tables will be created and filled from the silva tables
--    silva.samplingsites_mat
--    silva.samples_mat
--    silva.sample_measures_mat
--    silva.ribosomal_sequences_mat
--
-- Comments: 
--  -Only SILVA sequences with a geolocation will be used.
--  -Sequences are grouped to samples by geometry, depth and date
--  -Sampling sites are grouped by geometry
--
BEGIN;

DROP INDEX IF EXISTS %LSUSCHEMA%.pa_idx_21;
DROP INDEX IF EXISTS %LSUSCHEMA%.pa_idx_22;
DROP INDEX IF EXISTS %LSUSCHEMA%.pa_idx_23;
DROP INDEX IF EXISTS %SSUSCHEMA%.pa_idx_11;
DROP INDEX IF EXISTS %SSUSCHEMA%.pa_idx_12;
DROP INDEX IF EXISTS %SSUSCHEMA%.pa_idx_13;

DROP SCHEMA IF EXISTS silva CASCADE;

CREATE SCHEMA silva;

set search_path = silva, public;

--get some speed-up
CREATE INDEX pa_idx_21 ON %LSUSCHEMA%.sequenceentry USING BTREE (seqent_id);
CREATE INDEX pa_idx_22 ON %LSUSCHEMA%.sequence USING BTREE (seqent_id);
CREATE INDEX pa_idx_23 ON %LSUSCHEMA%.region USING BTREE (seqent_id);
CREATE INDEX pa_idx_11 ON %SSUSCHEMA%.sequenceentry USING BTREE (seqent_id);
CREATE INDEX pa_idx_12 ON %SSUSCHEMA%.sequence USING BTREE (seqent_id);
CREATE INDEX pa_idx_13 ON %SSUSCHEMA%.region USING BTREE (seqent_id);

-- legacy code reused
CREATE OR REPLACE VIEW silva_regions_v AS 
  SELECT r.seqent_id, r.start AS l, r.stop AS r, 
      core.parse_latlon(s.latlong) AS geom, s.latlong, r.rna_type, 
      s.alternativename, s.biomaterial, s.clone, s.clonelib, 
      upper(s.collectiondate) AS collectiondate, s.collector, s.country, r.crc, 
      s.culturecollection, s.dataclass, s.datasource, s.dateimported, 
      s.datemodified, s.datesubmitted, s.depth, s.description, s.division, 
      s.envsample, s.haplotype, s.habitat, s.identifiedby, s.insdc, s.isolate, 
      s.isolationsource, s.keywords, s.labhost, s.moleculartype, s.nameshist, 
      s.organelle, s.organismname, s.pcrprimers, s.plasmidname, s.refs, 
      s.sequencelength, s.sequenceversion, s.specifichost, s.specimenvoucher, 
      s.strain, s.strainid, s.subspecies, s.taxonomy
    FROM (
      SELECT sequenceentry.seqent_id, 
      sequenceentry.accessions, sequenceentry.alternativename, 
      sequenceentry.biomaterial, sequenceentry.circular, 
      sequenceentry.clone, sequenceentry.clonelib, 
      sequenceentry.collectiondate, sequenceentry.collector, 
      sequenceentry.country, 
      sequenceentry.culturecollection, sequenceentry.dataclass, 
      sequenceentry.datasource, sequenceentry.dateimported, 
      sequenceentry.datemodified, sequenceentry.datesubmitted, 
      sequenceentry.depth, sequenceentry.description, 
      sequenceentry.division, sequenceentry.envsample, 
      sequenceentry.filename, sequenceentry.flags, 
      sequenceentry.haplotype, sequenceentry.habitat, 
      sequenceentry.identifiedby, sequenceentry.insdc, 
      sequenceentry.isolate, sequenceentry.isolationsource, 
      sequenceentry.keywords, sequenceentry.labhost, 
      sequenceentry.latlong, sequenceentry.moleculartype, 
      sequenceentry.nameshist, sequenceentry.organelle, 
      sequenceentry.organismname, sequenceentry.pcrprimers, 
      sequenceentry.plasmidname, sequenceentry.refs, 
      sequenceentry.sequencelength, 
      sequenceentry.sequenceversion, sequenceentry.specifichost, 
      sequenceentry.specimenvoucher, sequenceentry.strain, 
      sequenceentry.strainid, sequenceentry.subspecies, 
      sequenceentry.taxonomy, 
      's'::character varying(1) AS rna_type
    FROM %SSUSCHEMA%.sequenceentry
    UNION 
    SELECT sequenceentry.seqent_id, 
      sequenceentry.accessions, sequenceentry.alternativename, 
            sequenceentry.biomaterial, sequenceentry.circular, 
            sequenceentry.clone, sequenceentry.clonelib, 
            sequenceentry.collectiondate, sequenceentry.collector, 
            sequenceentry.country, 
            sequenceentry.culturecollection, sequenceentry.dataclass, 
            sequenceentry.datasource, sequenceentry.dateimported, 
            sequenceentry.datemodified, sequenceentry.datesubmitted, 
            sequenceentry.depth, sequenceentry.description, 
            sequenceentry.division, sequenceentry.envsample, 
            sequenceentry.filename, sequenceentry.flags, 
            sequenceentry.haplotype, sequenceentry.habitat, 
            sequenceentry.identifiedby, sequenceentry.insdc, 
            sequenceentry.isolate, sequenceentry.isolationsource, 
            sequenceentry.keywords, sequenceentry.labhost, 
            sequenceentry.latlong, sequenceentry.moleculartype, 
            sequenceentry.nameshist, sequenceentry.organelle, 
            sequenceentry.organismname, sequenceentry.pcrprimers, 
            sequenceentry.plasmidname, sequenceentry.refs, 
            sequenceentry.sequencelength, 
            sequenceentry.sequenceversion, sequenceentry.specifichost, 
            sequenceentry.specimenvoucher, sequenceentry.strain, 
            sequenceentry.strainid, sequenceentry.subspecies, 
            sequenceentry.taxonomy, 
            'l'::character varying(1) AS rna_type
    FROM %LSUSCHEMA%.sequenceentry) s
  JOIN (
    SELECT seqent_id, primaryaccession, 
      start, stop, alignmentquality, 
      bpscore, isref, regionlength, 
            percentambiguity, percentrepetative, 
            percentvector, product, quality, 
            startflag, stopflag, percentaligned, 
            pintailquality, crc,
            's'::character varying(1) AS rna_type
    FROM %SSUSCHEMA%.region
        UNION 
        SELECT seqent_id, primaryaccession, start, 
      stop, alignmentquality, bpscore, 
            isref, regionlength, percentambiguity, 
            percentrepetative, percentvector, 
            product, quality, startflag, 
            stopflag, percentaligned, 
            pintailquality, crc,
            'l'::character varying(1) AS rna_type
    FROM %LSUSCHEMA%.region) r
  USING (seqent_id, rna_type)
;

-- legacy code reused
CREATE OR REPLACE VIEW silva_samples_v AS 
  SELECT f.geom,
         f.site AS label,
         f.site AS locdesc,
         f.site AS locshortdesc, 
         core.pp_geom(f.geom) AS latlong,
         st_y(f.geom)::text AS lat, 
         st_x(f.geom)::text AS lon,
         core.pangaea_url(f.geom) AS pangaea_url, 
         array_to_string(
           (
             SELECT array_agg(t.col) AS array_agg FROM (
               SELECT unnest(s.acclist) AS col GROUP BY unnest(s.acclist)
             ) t
           ), ','::text
         ) AS ssu_acc,
         array_to_string(
           (
             SELECT array_agg(t.col) AS array_agg FROM (
               SELECT unnest(l.acclist) AS col GROUP BY unnest(l.acclist)
             ) t
           ), ','::text
         ) AS lsu_acc, 
         COALESCE(s.nseq, 0::bigint)::text AS ssu_count, 
         COALESCE(l.nseq, 0::bigint)::text AS lsu_count, 
         CASE
           WHEN f.depth = ''::text THEN 'NA'::text
           ELSE f.depth
         END AS depth, 
         (
           SELECT parse_silva_coldate.datum FROM web_r8.parse_silva_coldate(f.collectiondate) parse_silva_coldate(datum, res)
         ) AS datum, 
         (
           SELECT parse_silva_coldate.res FROM web_r8.parse_silva_coldate(f.collectiondate) parse_silva_coldate(datum, res)
         ) AS dat_res, 
         COALESCE(f.site, 'name not available'::text) AS site_name, 
         COALESCE(f.habitat, 'unclassified'::text) AS hab_lite, 
         COALESCE(f.habitat, 'unclassified'::text) AS hab_uri, 
         COALESCE(f.nseq, 0::bigint)::text AS num_seq, 'rRNA'::text AS sample_type
  FROM
  (
    SELECT silva_regions_v.geom,
           silva_regions_v.depth,
           silva_regions_v.collectiondate, 
           max(silva_regions_v.isolationsource) AS site,
           CASE
             WHEN max(silva_regions_v.habitat) = ''::text THEN NULL::text
             ELSE max(silva_regions_v.habitat)
           END AS habitat, 
           count(*) AS nseq
    FROM silva_regions_v
--    WHERE silva_regions_v.geom IS NOT NULL
    GROUP BY silva_regions_v.geom, silva_regions_v.depth, silva_regions_v.collectiondate
  ) f
  LEFT JOIN
  (
    SELECT array_agg(silva_regions_v.seqent_id) AS acclist, 
           silva_regions_v.geom,
           silva_regions_v.depth, 
           silva_regions_v.collectiondate, 
           count(*) AS nseq
    FROM silva_regions_v
    WHERE --silva_regions_v.geom IS NOT NULL AND 
silva_regions_v.rna_type::text = 'l'::text
    GROUP BY silva_regions_v.geom, silva_regions_v.depth, silva_regions_v.collectiondate
  ) l ON f.geom = l.geom AND f.depth = l.depth AND f.collectiondate = l.collectiondate
  LEFT JOIN
  (
    SELECT array_agg(silva_regions_v.seqent_id) AS acclist, 
           silva_regions_v.geom,
           silva_regions_v.depth, 
           silva_regions_v.collectiondate, count(*) AS nseq
    FROM silva_regions_v
    WHERE --silva_regions_v.geom IS NOT NULL AND 
silva_regions_v.rna_type::text = 's'::text
    GROUP BY silva_regions_v.geom, silva_regions_v.depth, silva_regions_v.collectiondate
  ) s ON s.geom = f.geom AND s.depth = f.depth AND s.collectiondate = f.collectiondate;

-----------------------------------------------------------------------------------------------------
-- Part A: core.samplingsites staging
-----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW samplingsites AS
  SELECT
    max(label) AS label,
    max(locdesc) AS locdesc,
    max(locshortdesc) AS locshortdesc,
    'NaN'::numeric AS max_uncertain,
    NULL::text AS loc_estim,
    NULL::text AS region,
    NULL::int4 AS project,
    NULL::text AS own,
    NULL::geometry AS old_geom,
    max(latlong) AS verb_coords,
    ''::text AS verb_coords_sys,
    ''::text AS verification,
    ''::text AS georef_validation,
    ''::text AS georef_prot,
    ''::text AS georef_source,
    -1::float AS spatial_fit,
    'megdb'::text AS georef_by,
    max(datum) AS georef_time,
    ''::text AS georef_remark,
    geom
  FROM silva_samples_v WHERE geom IS NOT NULL GROUP BY geom;
--
-- materialize samplingsites view
--  
CREATE TABLE samplingsites_mat (LIKE samplingsites);
INSERT INTO samplingsites_mat SELECT * FROM samplingsites;

-- set all reference systems to WGS84
UPDATE silva.samplingsites_mat SET geom = ST_SetSRID(geom,4326);

-- change NULL to empty string
UPDATE silva.samplingsites_mat SET label = '' WHERE label IS NULL;
UPDATE silva.samplingsites_mat SET locdesc = '' WHERE locdesc IS NULL;
UPDATE silva.samplingsites_mat SET locshortdesc = '' WHERE locshortdesc IS NULL;

-----------------------------------------------------------------------------------------------------
-- Part B: core.samples staging
-----------------------------------------------------------------------------------------------------
-- to obtain a uid for the samples
CREATE SEQUENCE sample_id;
SELECT setval('sample_id', max(sid)) FROM core.samples;

CREATE OR REPLACE VIEW samples AS
  SELECT
    nextval('sample_id') AS sid,
    'NaN'::numeric as max_uncertain,
    datum AS date_taken,
    dat_res AS date_res,
    'silva:' || currval('sample_id')::text AS label,
    ''::text AS material,
    ''::text AS habitat,
    ''::text AS hab_lite,
    ''::text AS country,
    0::int4 AS project,
    ''::text AS own,
    NULL::geometry AS old_geom,
    'silva'::text AS study,
    0::int2 AS pool,
    geom::geometry,
    ''::text AS device,
    ''::text AS biome,
    ''::text AS feature,
    CASE
      WHEN depth = 'NA'::text THEN hstore(NULL)
      ELSE hstore('depth',depth)
    END AS attr
  FROM silva_samples_v; 

-- materialization
CREATE TABLE samples_mat (LIKE samples);
INSERT INTO samples_mat SELECT * FROM samples;

-- set to WGS84
UPDATE silva.samples_mat SET geom = ST_SetSRID(geom,4326);

-----------------------------------------------------------------------------------------------------
-- Part C: core.sample_measures - depth only
-----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW sample_measures AS
  SELECT
    sid::int,
    ''::text AS material,
    'depth'::text AS param,
    'm'::text AS unit,
    ARRAY[(attr -> 'depth')::numeric] AS vals,
    ''::text AS mcode,
    date_taken AS conducted,
    date_res AS conducted_res,
    device,
    project,
    'megdb'::text As own,
    (attr -> 'depth')::numeric AS min,
    (attr -> 'depth')::numeric AS max,
    0::numeric AS std,
    0::int AS meas_tot,
    study,
    label AS sample_name 
  FROM silva.samples_mat
  WHERE (attr -> 'depth') IS NOT NULL;
  
CREATE TABLE silva.sample_measures_mat (LIKE sample_measures);
INSERT INTO silva.sample_measures_mat SELECT * FROM sample_measures;

-----------------------------------------------------------------------------------------------------
-- Part D: core.ribosomal_sequences
-----------------------------------------------------------------------------------------------------

-- pre staging table
CREATE TABLE silva.ribosomal_sequences_pre (
  seqent_id text,
  sequence text,
  size int,
  collectiondate timestamptz,
  samplename text,
  mol_type text,
  geom geometry,
  depth text
);

-- insert from LSU
INSERT INTO silva.ribosomal_sequences_pre 
  SELECT 
    seqent.seqent_id || '_' || region.start || '_' || region.stop ||'_lsu',
    CASE WHEN region.complement = 'yes'
    THEN translate(substr(seq.sequence, region.start, region.stop - region.start), 'ACGT', 'TGCA')
    ELSE substr(seq.sequence, region.start, region.stop - region.start)
    END as sequence,
    region.stop - region.start + 1,
    (
      SELECT parse_silva_coldate.datum FROM web_r8.parse_silva_coldate(collectiondate) parse_silva_coldate(datum, res)
    ) AS collectiondate,
    '',
    'LSU rRNA',
    ST_SetSRID(core.parse_latlon(seqent.latlong),4326),
    CASE
    WHEN seqent.depth = ''::text
    THEN 'NA'::text
    ELSE seqent.depth
    END AS depth
  FROM (
    SELECT seqent_id, latlong, collectiondate, depth FROM %LSUSCHEMA%.sequenceentry
  ) seqent
  INNER JOIN (
    SELECT seqent_id, sequence FROM %LSUSCHEMA%.sequence
  ) seq ON seq.seqent_id = seqent.seqent_id
  INNER JOIN (
    SELECT seqent_id, start, stop, complement FROM %LSUSCHEMA%.region
  ) region ON region.seqent_id = seq.seqent_id
  ;
  
-- insert from SSU
  INSERT INTO silva.ribosomal_sequences_pre 
  SELECT
    seqent.seqent_id || '_' || region.start || '_' || region.stop,
    CASE WHEN region.complement = 'yes'
    THEN translate(substr(seq.sequence, region.start, region.stop- region.start + 1), 'ACGT', 'TGCA')
    ELSE substr(seq.sequence, region.start, region.stop - region.start + 1)
    END as sequence,
    region.stop - region.start + 1,
    (
      SELECT parse_silva_coldate.datum FROM web_r8.parse_silva_coldate(collectiondate) parse_silva_coldate(datum, res)
    ) AS collectiondate,
    '',
    'SSU rRNA',
    ST_SetSRID(core.parse_latlon(seqent.latlong),4326),
    CASE
    WHEN seqent.depth = ''::text
    THEN 'NA'::text
    ELSE seqent.depth
    END AS depth
  FROM (
    SELECT seqent_id, latlong, collectiondate, depth FROM %SSUSCHEMA%.sequenceentry
  ) seqent
  INNER JOIN (
    SELECT seqent_id, sequence FROM %SSUSCHEMA%.sequence
  ) seq ON seq.seqent_id = seqent.seqent_id
  INNER JOIN (
    SELECT seqent_id, start, stop, complement FROM %SSUSCHEMA%.region
    EXCEPT
    SELECT seqent_id, start, stop, complement FROM %LSUSCHEMA%.region
  ) region ON region.seqent_id = seq.seqent_id
  ;

-- update sample names
CREATE INDEX location_idx_se ON silva.ribosomal_sequences_pre USING GIST (geom);
CREATE INDEX location_idx_samp ON silva.samples_mat USING GIST (geom);
UPDATE silva.ribosomal_sequences_pre SET samplename = samples_mat.label FROM silva.samples_mat 
  WHERE ST_equals(ribosomal_sequences_pre.geom, samples_mat.geom)
  AND ribosomal_sequences_pre.collectiondate = samples_mat.date_taken
  AND 
    (CASE WHEN (samples_mat.attr -> 'depth') IS NULL
      THEN 'NA'::TEXT
      ELSE (samples_mat.attr -> 'depth')::TEXT
      END)
    =
     ribosomal_sequences_pre.depth::TEXT
;

-- avoid duplicate ids

-- actual staging view
CREATE OR REPLACE VIEW silva.ribosomal_sequences AS
  SELECT 
    sequence,
    size,
    0::numeric AS gc,
    'silva'::text AS data_source,
    collectiondate as retrieved,
    0::int AS project,
    'megdb'::text AS own,
    seqent_id AS did,
    'silva'::text AS did_auth,
    mol_type,
    ''::text AS acc_ver,
    0 AS isolate_id,
    0::int AS gpid,
    ''::text AS center,
    ''::text AS status,
    ''::text AS seq_platform,
    ''::text AS seq_approach,
    ''::text AS seq_method,
    'silva'::text AS study,
    samplename AS sample_name,
    ''::text AS isolate_name,
    ''::text AS estimated_error_rate,
    ''::text AS calculation_method
  FROM silva.ribosomal_sequences_pre;
    
-- materialization
CREATE TABLE silva.ribosomal_sequences_mat (like silva.ribosomal_sequences);
INSERT INTO silva.ribosomal_sequences_mat SELECT * FROM silva.ribosomal_sequences;

-- data for web view

DROP TABLE IF EXISTS web_r8.silva_samples CASCADE;
CREATE TABLE web_r8.silva_samples (
  LIKE silva.silva_samples_v
);

INSERT INTO web_r8.silva_samples SELECT * FROM silva.silva_samples_v;
UPDATE web_r8.silva_samples SET geom = ST_SetSRID(geom,4326);

ALTER TABLE web_r8.silva_samples ADD COLUMN sid INT;
UPDATE web_r8.silva_samples
  SET sid = samples_mat.sid
  FROM silva.samples_mat
  WHERE silva_samples.geom = samples_mat.geom
  AND silva_samples.datum = samples_mat.date_taken
  AND 
    (CASE WHEN (samples_mat.attr -> 'depth') IS NULL
      THEN -1::numeric
      ELSE (samples_mat.attr -> 'depth')::numeric
      END)
    =
    (CASE WHEN silva_samples.depth = 'NA'
      THEN -1::numeric
      ELSE silva_samples.depth::numeric
      END);

CREATE OR REPLACE VIEW web_r8.silva AS 
 SELECT silva_samples.sid, silva_samples.geom, 
        CASE
            WHEN silva_samples.label = ''::text THEN 'unnamed'::text
            ELSE silva_samples.label
        END AS site_name, 
    silva_samples.lat::text AS lat, silva_samples.lon::text AS lon, 
    core.pp_geom(silva_samples.geom) AS latlon, 
    core.pp_depth(silva_samples.sid) AS depth, 
        CASE
            WHEN silva_samples.datum::text = '-'::text THEN 'NA'::text
            ELSE silva_samples.datum::text
        END AS date_taken, 
    silva_samples.hab_lite, silva_samples.hab_uri, 
    silva_samples.sample_type AS study_type, 
    'rRNA sample'::text AS entity_name, ''::text AS entity_url, 
    ''::text AS entity_country, ''::text AS entity_iho, 
    ''::text AS entity_region, ''::text AS entity_descr, 
    core.pp_temperature(silva_samples.sid) AS temperature, 
    core.pp_salinity(silva_samples.sid) AS salinity, 
    core.pp_oxygen(silva_samples.sid) AS oxygen, 
    core.pp_chlorophyll(silva_samples.sid) AS chlorophyll
   FROM web_r8.silva_samples;
    

COMMIT;