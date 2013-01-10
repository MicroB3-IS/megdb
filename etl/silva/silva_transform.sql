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

CREATE SCHEMA silva;

set search_path = silva, public;

--get some speed-up
CREATE INDEX pa_idx_21 ON %LSUSCHEMA%.sequenceentry USING BTREE (primaryaccession);
CREATE INDEX pa_idx_22 ON %LSUSCHEMA%.sequence USING BTREE (primaryaccession);
CREATE INDEX pa_idx_11 ON %SSUSCHEMA%.sequenceentry USING BTREE (primaryaccession);
CREATE INDEX pa_idx_12 ON %SSUSCHEMA%.sequence USING BTREE (primaryaccession);

-- legacy code reused
CREATE OR REPLACE VIEW silva_regions_v AS 
  SELECT r.primaryaccession, r.start AS l, r.stop AS r, 
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
      SELECT sequenceentry.primaryaccession, 
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
    SELECT sequenceentry.primaryaccession, 
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
  USING (primaryaccession, rna_type)
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
    WHERE silva_regions_v.geom IS NOT NULL
    GROUP BY silva_regions_v.geom, silva_regions_v.depth, silva_regions_v.collectiondate
  ) f
  LEFT JOIN
  (
    SELECT array_agg(silva_regions_v.primaryaccession) AS acclist, 
           silva_regions_v.geom,
           silva_regions_v.depth, 
           silva_regions_v.collectiondate, 
           count(*) AS nseq
    FROM silva_regions_v
    WHERE silva_regions_v.geom IS NOT NULL AND silva_regions_v.rna_type::text = 'l'::text
    GROUP BY silva_regions_v.geom, silva_regions_v.depth, silva_regions_v.collectiondate
  ) l ON f.geom = l.geom AND f.depth = l.depth AND f.collectiondate = l.collectiondate
  LEFT JOIN
  (
    SELECT array_agg(silva_regions_v.primaryaccession) AS acclist, 
           silva_regions_v.geom,
           silva_regions_v.depth, 
           silva_regions_v.collectiondate, count(*) AS nseq
    FROM silva_regions_v
    WHERE silva_regions_v.geom IS NOT NULL AND silva_regions_v.rna_type::text = 's'::text
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
  FROM silva_samples_v GROUP BY geom;
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

CREATE OR REPLACE VIEW samples AS
  SELECT
    nextval('sample_id') AS sid,
    NULL::numeric as max_uncertain,
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
    sid,
    ''::text AS material,
    'depth'::text AS param,
    'm'::text AS unit,
    ARRAY[(attr -> 'depth')::numeric] AS vals,
    ''::text AS mcode,
    date_taken AS conducted,
    date_res AS conducted_res,
    device,
    project,
    own,
    (attr -> 'depth')::numeric AS min,
    (attr -> 'depth')::numeric AS max,
    0::numeric AS std,
    0::int AS meas_tot,
    study,
    label AS sample_name 
  FROM silva.samples_mat
  WHERE (attr -> 'depth') IS NOT NULL;
  
CREATE TABLE sample_measures_mat (LIKE sample_measures);
INSERT INTO sample_measures_mat SELECT * FROM sample_measures;

-----------------------------------------------------------------------------------------------------
-- Part D: core.ribosomal_sequences - only those with latlon != ''
-----------------------------------------------------------------------------------------------------

-- pre staging table
CREATE TABLE silva.ribosomal_sequences_pre (
  primaryaccession text,
  sequence text,
  size int,
  retrieved timestamp,
  samplename text,
  mol_type text,
  geom geometry
);

-- insert from LSU
INSERT INTO silva.ribosomal_sequences_pre 
  SELECT 
      seqent.primaryaccession,
    seq.sequence,
    seqent.sequenceLength,
    seqent.dateimported::timestamp,
    '',
    'LSU rRNA',
    ST_SetSRID(core.parse_latlon(seqent.latlong),4326)
  FROM (
    SELECT * FROM %LSUSCHEMA%.sequenceentry WHERE latlong != ''
  ) seqent
  INNER JOIN (
    SELECT * FROM %LSUSCHEMA%.sequence
  ) seq ON seq.primaryaccession = seqent.primaryaccession
  ;

-- insert from SSU
INSERT INTO silva.ribosomal_sequences_pre 
  SELECT 
      seqent.primaryaccession,
    seq.sequence,
    seqent.sequenceLength,
    seqent.dateimported::timestamp,
    '',
    'SSU rRNA',
    ST_SetSRID(core.parse_latlon(seqent.latlong),4326)
  FROM (
    SELECT * FROM %SSUSCHEMA%.sequenceentry WHERE latlong != ''
  ) seqent
  INNER JOIN (
    SELECT * FROM %SSUSCHEMA%.sequence
  ) seq ON seq.primaryaccession = seqent.primaryaccession
  ;

-- update sample names
CREATE INDEX location_idx_se ON silva.ribosomal_sequences_pre USING GIST (geom);
CREATE INDEX location_idx_samp ON silva.samples_mat USING GIST (geom);
UPDATE silva.ribosomal_sequences_pre SET samplename = label FROM silva.samples_mat WHERE ST_Equals(silva.samples_mat.geom, silva.ribosomal_sequences_pre.geom);

-- actual staging view
CREATE OR REPLACE VIEW silva.ribosomal_sequences AS
  SELECT 
    sequence,
    size,
    0::numeric AS gc,
    'silva'::text AS data_source,
    retrieved,
    0::int AS project,
    ''::text AS own,
    primaryaccession AS did,
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
    

