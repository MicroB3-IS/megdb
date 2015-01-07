\pset null NULL
\x auto

BEGIN;

SET search_path TO osdregistry,public;

SET ROLE megdb_admin;

-- patch 1: fix-default-privs-osdregistry

ALTER DEFAULT PRIVILEGES IN SCHEMA osdregistry REVOKE SELECT ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA osdregistry REVOKE ALL ON FUNCTIONS FROM PUBLIC;

DROP TABLE IF EXISTS osdregistry.test_samples;

-- delete old tests data
DELETE FROM osdregistry.osd_raw_samples 
 WHERE id in (6,41,57,64,98,99,100,185);



CREATE OR REPLACE FUNCTION osdregistry.cleantrimtab(text) RETURNS text AS $$
   SELECT translate( trim( $1 ), E'\t', ' '  );
$$ LANGUAGE SQL; 


DROP VIEW IF EXISTS  osdregistry.submission_overview;

CREATE OR REPLACE VIEW  osdregistry.submission_overview AS
   select
        id::integer,
        submitted,
        substring (raw_json #>> '{sampling_site, site_id}' from E'(?i)[OSD ]{3,4}(\\d{1,3})')::integer as osd_id,
        cleantrimtab( raw_json #>> '{sampling_site, site_name}' ) AS site_name,
        version,
        raw_json #>> '{sampling_site, marine_region}' as marine_region,
        CASE WHEN
          version  = 6
        THEN
          raw_json #>> '{sampling_site, start_coordinates,latitude}'
        ELSE
          raw_json #>> '{sampling_site,latitude}'
        END AS start_lat,
        CASE WHEN
          version  = 6
        THEN
          raw_json #>> '{sampling_site, start_coordinates,longitude}'
        ELSE
          raw_json #>> '{sampling_site, longitude}'
        END as start_lon,
        -- now stop coordinates
        CASE WHEN
          version  = 6
        THEN
          raw_json #>> '{sampling_site, stop_coordinates,latitude}'
        ELSE
          raw_json #>> '{sampling_site,latitude}'
        END AS stop_lat,
        CASE WHEN
          version  = 6
        THEN
          raw_json #>> '{sampling_site, stop_coordinates,longitude}'
        ELSE
          raw_json #>> '{sampling_site, longitude}'
        END as stop_lon,
        raw_json #>> '{sample,start_time}' as sample_start_time,
        raw_json #>> '{sample,end_time}' as sample_end_time,
        cleantrimtab( raw_json #>> '{sample,label}' ) as sample_label,
        trim( raw_json #>> '{sample,protocol_label}' ) as sample_protocol,
        COALESCE ( raw_json #>> '{sample, depth}', 'nan' ) as sample_depth,
        raw_json #>> '{sample, date}' as sample_date,
        trim( raw_json #>> '{contact, first_name}' ) as first_name,
        trim( raw_json #>> '{contact, last_name}' ) as last_name,
        trim( raw_json #>> '{contact, institute}' ) as institute,
        raw_json #>> '{contact, email}' as email,
        raw_json -> 'environment' ->> 'water_temperature' as water_temperature,
        raw_json -> 'environment' ->> 'salinity' as salinity,
        CASE WHEN 
          raw_json #>> '{environment, ph, choice}' = 'measured'
        THEN
          raw_json #>> '{environment, ph, measurement, value}'
        ELSE
          raw_json #>> '{environment, ph, choice}'
        END as ph,
        CASE WHEN 
          raw_json #>> '{environment, phosphate, choice}' = 'measured'
        THEN
          raw_json #>> '{environment, phosphate, measurement, value}'
        ELSE
          raw_json #>> '{environment, phosphate, choice}'
        END as phospahte,
       CASE WHEN 
          raw_json #>> '{environment, nitrate, nitrate-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, nitrate, nitrate-measurement}'
        ELSE
          raw_json #>> '{environment,nitrate , nitrate-choice}'
        END as nitrate,
        CASE WHEN 
          raw_json #>> '{environment, carbon_organic_particulate_poc, carbon_organic_particulate_poc-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, carbon_organic_particulate_poc, carbon_organic_particulate_poc-measurement}'
        ELSE
          raw_json #>> '{environment, carbon_organic_particulate_poc, carbon_organic_particulate_poc-choice}'
        END as carbon_organic_particulate,
        CASE WHEN 
          raw_json #>> '{environment, nitrite, nitrite-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, nitrite, nitrite-measurement}'
        ELSE
          raw_json #>> '{environment, nitrite, nitrite-choice}'
        END as nitrite,
        CASE WHEN 
          raw_json #>> '{environment, carbon_organic_dissolved_doc, carbon_organic_dissolved_doc-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, carbon_organic_dissolved_doc, carbon_organic_dissolved_doc-measurement}'
        ELSE
          raw_json #>> '{environment, carbon_organic_dissolved_doc, carbon_organic_dissolved_doc-choice}'
        END as carbon_organic_dissolved_doc,
        CASE WHEN 
          raw_json #>> '{environment, nano_microplankton, nano_microplankton-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, nano_microplankton, nano_microplankton-measurement}'
        ELSE
          raw_json #>> '{environment, nano_microplankton, nano_microplankton-choice}'
        END as nano_microplankton,
        CASE WHEN 
          raw_json #>> '{environment, downward_par, downward_par-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, downward_par, downward_par-measurement}'
        ELSE
          raw_json #>> '{environment, downward_par, downward_par-choice}'
        END as downward_par,
        CASE WHEN 
          raw_json #>> '{environment, conductivity, conductivity-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, conductivity, conductivity-measurement}'
        ELSE
          raw_json #>> '{environment, conductivity, conductivity-choice}'
        END as conductivity,
        CASE WHEN 
          raw_json #>> '{environment, primary_production_isotope_uptake, primary_production_isotope_uptake-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, primary_production_isotope_uptake, primary_production_isotope_uptake-measurement}'
        ELSE
          raw_json #>> '{environment, primary_production_isotope_uptake, primary_production_isotope_uptake-choice}'
        END as primary_production_isotope_uptake,
        CASE WHEN 
          raw_json #>> '{environment, primary_production_oxygen, primary_production_oxygen-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, primary_production_oxygen, primary_production_oxygen-measurement}'
        ELSE
          raw_json #>> '{environment, primary_production_oxygen, primary_production_oxygen-choice}'
        END as primary_production_oxygen,
        CASE WHEN 
          raw_json #>> '{environment, dissolved_oxygen_concentration, dissolved_oxygen_concentration-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, dissolved_oxygen_concentration, dissolved_oxygen_concentration-measurement}'
        ELSE
          raw_json #>> '{environment, dissolved_oxygen_concentration, dissolved_oxygen_concentration-choice}'
        END as dissolved_oxygen_concentration,
        CASE WHEN 
          raw_json #>> '{environment, nitrogen_organic_particulate_pon, nitrogen_organic_particulate_pon-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, nitrogen_organic_particulate_pon, nitrogen_organic_particulate_pon-measurement}'
        ELSE
          raw_json #>> '{environment, nitrogen_organic_particulate_pon, nitrogen_organic_particulate_pon-choice}'
        END as nitrogen_organic_particulate_pon,
        CASE WHEN 
          raw_json #>> '{environment, meso_macroplankton, meso_macroplankton-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, meso_macroplankton, meso_macroplankton-measurement}'
        ELSE
          raw_json #>> '{environment, meso_macroplankton, meso_macroplankton-choice}'
        END as meso_macroplankton,
        CASE WHEN 
          raw_json #>> '{environment, bacterial_production_isotope_uptake, bacterial_production_isotope_uptake-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, bacterial_production_isotope_uptake, bacterial_production_isotope_uptake-measurement}'
        ELSE
          raw_json #>> '{environment, bacterial_production_isotope_uptake, bacterial_production_isotope_uptake-choice}'
        END as bacterial_production_isotope_uptake,
        CASE WHEN 
          raw_json #>> '{environment, nitrogen_organic_dissolved_don, nitrogen_organic_dissolved_don-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, nitrogen_organic_dissolved_don, nitrogen_organic_dissolved_don-measurement}'
        ELSE
          raw_json #>> '{environment, nitrogen_organic_dissolved_don, nitrogen_organic_dissolved_don-choice}'
        END as nitrogen_organic_dissolved_don,
        CASE WHEN 
          raw_json #>> '{environment, ammonium, ammonium-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, ammonium, ammonium-measurement}'
        ELSE
          raw_json #>> '{environment, ammonium, ammonium-choice}'
        END as ammonium,
        CASE WHEN 
          raw_json #>> '{environment, silicate, silicate-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, silicate, silicate-measurement}'
        ELSE
          raw_json #>> '{environment, silicate, silicate-choice}'
        END as silicate,
        CASE WHEN 
          raw_json #>> '{environment, bacterial_production_respiration, bacterial_production_respiration-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, bacterial_production_respiration, bacterial_production_respiration-measurement}'
        ELSE
          raw_json #>> '{environment, bacterial_production_respiration, bacterial_production_respiration-choice}'
        END as bacterial_production_respiration,
        CASE WHEN 
          raw_json #>> '{environment, turbidity, turbidity-choice}' = 'measured'
        THEN
          raw_json #>> '{environment, turbidity, turbidity-measurement}'
        ELSE
          raw_json #>> '{environment, turbidity, turbidity-choice}'
        END as turbidity,
        CASE WHEN 
          raw_json #>> '{environment, fluorescence, choice}' = 'measured'
        THEN
          raw_json #>> '{environment, fluorescence, measurement, value}'
        ELSE
          raw_json #>> '{environment, fluorescence, choice}'
        END as fluorescence,
          CASE WHEN 
          raw_json #>> '{environment, pigment_concentration, choice}' = 'measured'
        THEN
          raw_json #>> '{environment, pigment_concentration, measurement, value}'
        ELSE
          raw_json #>> '{environment, pigment_concentration, choice}'
        END as pigment_concentration,
          CASE WHEN 
          raw_json #>> '{environment, picoplankton_flow_cytometry, choice}' = 'measured'
        THEN
          raw_json #>> '{environment, picoplankton_flow_cytometry, measurement, value}'
        ELSE
          raw_json #>> '{environment, picoplankton_flow_cytometry, choice}'
        END as picoplankton_flow_cytometry,
        
        COALESCE ( (raw_json -> 'environment' ->> 'other_parameters'), 'not determined') as other_params,

        raw_json -> 'comment' as remarks,
        raw_json #>> '{sample,filters}' as filters,
        raw_json
         
   from osdregistry.osd_raw_samples 
   WHERE (raw_json ->> 'version' = '6' OR raw_json ->> 'version' = '5') order by osd_id  desc
;
-- end osdregistry.submission_overview


\set idlist '46,48,49,50,51,52,65,70,89,106,107,223,224,225,226,227'

CREATE TABLE osdregistry.curation_submissions AS
   SELECT 
id AS submission_id,
submitted,
osd_id,
''::text AS curation_remark,
''::text AS curator,
site_name, site_name AS site_name_verb,
version,
marine_region, marine_region AS marine_region_verb,
start_lat, start_lat AS start_lat_verb,
start_lon, start_lon AS start_lon_verb,
stop_lat, stop_lat AS stop_lat_verb,
stop_lon, stop_lon AS stop_lon_verb,
sample_start_time::time, sample_start_time AS sample_start_time_verb, 
sample_end_time::time, sample_end_time::time AS sample_end_time_verb,
sample_label, sample_label AS sample_label_verb,
sample_protocol, sample_protocol AS sample_protocol_verb,
sample_depth, sample_depth AS sample_depth_verb,
sample_date::date, sample_date::date AS sample_date_verb,
first_name, first_name AS first_name_verb,
last_name, last_name AS last_name_verb,
institute, institute AS institute_verb,
email, email AS email_verb,
COALESCE (water_temperature, 'nan') as water_temperature, water_temperature AS water_temperature_verb, 
salinity::numeric, salinity::numeric AS salinity_verb,
ph, ph AS ph_verb,
phospahte, phospahte AS phospahte_verb,
nitrate, nitrate AS nitrate_verb,
carbon_organic_particulate, carbon_organic_particulate AS carbon_organic_particulate_verb,
nitrite, nitrite AS nitrite_verb,
carbon_organic_dissolved_doc, carbon_organic_dissolved_doc AS carbon_organic_dissolved_doc_verb,
nano_microplankton, nano_microplankton AS nano_microplankton_verb,
downward_par, downward_par AS downward_par_verb,
conductivity, conductivity AS conductivity_verb,
primary_production_isotope_uptake, primary_production_isotope_uptake AS primary_production_isotope_uptake_verb,
primary_production_oxygen, primary_production_oxygen AS primary_production_oxygen_verb,
dissolved_oxygen_concentration, dissolved_oxygen_concentration AS dissolved_oxygen_concentration_verb,
nitrogen_organic_particulate_pon, nitrogen_organic_particulate_pon AS nitrogen_organic_particulate_pon_verb,
meso_macroplankton, meso_macroplankton AS meso_macroplankton_verb,
bacterial_production_isotope_uptake, bacterial_production_isotope_uptake AS bacterial_production_isotope_uptake_verb,
nitrogen_organic_dissolved_don, nitrogen_organic_dissolved_don AS nitrogen_organic_dissolved_don_verb,
ammonium, ammonium AS ammonium_verb,
silicate, silicate AS silicate_verb,
bacterial_production_respiration, bacterial_production_respiration AS bacterial_production_respiration_verb,
turbidity, turbidity AS turbidity_verb,
fluorescence, fluorescence AS fluorescence_verb,
pigment_concentration, pigment_concentration AS pigment_concentration_verb,
picoplankton_flow_cytometry, picoplankton_flow_cytometry AS picoplankton_flow_cytometry_verb,
other_params,
remarks,
filters

FROM osdregistry.submission_overview 
   WHERE 
     -- temporarliy filter duplicates keeping highest id
     -- these are OSD 9,17, 21, 22, 30,49,52,55,62, 63,71, 72,74,117,120,152,155,156, 157
     id not in (7,19,27,58,60,61,62,63,67,68,69,72,73,74,75,95,101,111,113,118,126,137,138,159,161,162,165,187,201,202,203,208,210,216);

COMMENT ON TABLE curation_submissions 
   IS 'A one time snapshot of submitted data to proxy curation edits to the model tables';

REVOKE ALL ON curation_submissions FROM PUBLIC;

GRANT SELECT (submission_id ,
curation_remark,
curator,
site_name,
marine_region,
start_lat,
start_lon,
stop_lat,
stop_lon,
sample_start_time,
sample_end_time,
sample_label,
sample_protocol,
sample_depth,
sample_date,
first_name,
last_name,
institute,
email,
water_temperature,
salinity,
ph,
phospahte,
nitrate,
carbon_organic_particulate,
nitrite,
carbon_organic_dissolved_doc,
nano_microplankton,
downward_par,
conductivity,
primary_production_isotope_uptake,
primary_production_oxygen,
dissolved_oxygen_concentration,
nitrogen_organic_particulate_pon,
meso_macroplankton,
bacterial_production_isotope_uptake,
nitrogen_organic_dissolved_don,
ammonium,
silicate,
bacterial_production_respiration,
turbidity,
fluorescence,
pigment_concentration,
picoplankton_flow_cytometry
) ON curation_submissions TO megdb_admin,megx_team;


GRANT UPDATE (
curation_remark,
curator,
site_name_verb,
marine_region_verb,
start_lat_verb,
start_lon_verb,
stop_lat_verb,
stop_lon_verb,
sample_start_time_verb,
sample_end_time_verb,
sample_label_verb,
sample_protocol_verb,
sample_depth_verb,
sample_date_verb,
first_name_verb,
last_name_verb,
institute_verb,
email_verb,
water_temperature_verb,
salinity_verb,
ph_verb,
phospahte_verb,
nitrate_verb,
carbon_organic_particulate_verb,
nitrite_verb,
carbon_organic_dissolved_doc_verb,
nano_microplankton_verb,
downward_par_verb,
conductivity_verb,
primary_production_isotope_uptake_verb,
primary_production_oxygen_verb,
dissolved_oxygen_concentration_verb,
nitrogen_organic_particulate_pon_verb,
meso_macroplankton_verb,
bacterial_production_isotope_uptake_verb,
nitrogen_organic_dissolved_don_verb,
ammonium_verb,
silicate_verb,
bacterial_production_respiration_verb,
turbidity_verb,
fluorescence_verb,
pigment_concentration_verb,
picoplankton_flow_cytometry_verb
) ON curation_submissions TO megdb_admin,megx_team;



CREATE TABLE osdregistry.curation_submission_audits (
   id integer,
   entity json NOT NULL,
   from_value text NOT NULL,
   to_value text NOT NULL,
   remark text NOT NULL,
   changed_on timestamp with time zone NOT NULL DEFAULT now(),
   who text NOT NULL DEFAULT current_user,
   PRIMARY KEY(id,changed_on)
); 


CREATE FUNCTION osdregistry.curation_site_geom_trg()
  RETURNS trigger AS
$BODY$
BEGIN

UPDATE osdregistry.samples AS s
   SET (start_lat,start_lon,stop_lat,stop_lon) 
     = (NEW.start_lat::numeric,NEW.start_lon::numeric,NEW.stop_lat::numeric,NEW.stop_lon::numeric) 
  WHERE submission_id = NEW.submission_id;
 
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql
;

CREATE TRIGGER curation_submissions_updates
  BEFORE UPDATE OF start_lat,start_lon,stop_lat,stop_lon
  ON osdregistry.curation_submissions
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.curation_site_geom_trg();


\copy (SELECT * FROM osdregistry.curation_submissions) TO '/home/renzo/src/megdb/osd_submissions_2014-12-22.csv' CSV HEADER


-- select institute from curation_submissions;

-- todo correct handling of version 5

-- select osd_id, start_lat, stop_lat, start_lon, stop_lon from
-- curation_submissions where version = 6;


-- TODO maybe add time range here
-- TODO add check regex
CREATE TABLE campaigns (
  label text PRIMARY KEY 
);
  
INSERT INTO campaigns 
     VALUES ('OSD-Jun-2012'),('OSD-Dec-2012'),
            ('OSD-Jun-2013'),('OSD-Dec-2013'),
            ('OSD-Jun-2014'),('OSD-Dec-2014'),
            ('OSD-Jun-2015'),('OSD-Dec-2015'), 
            ('OSD-Jun-2016'),('OSD-Dec-2017');


-- todo add lat,lon and automatic update trigger
CREATE TABLE institutes (
  id text PRIMARY KEY, -- uniquness is defined as trimemd loweercase
		  -- version of the name in utf-8
  label text NOT NULL, -- the label for display
  country_verb text NOT NULL DEFAULT '',
  country text,
  country_iso_cd text,
  FOREIGN KEY (country, country_iso_cd) 
     REFERENCES elayers.boundaries (terr_name, iso3_code),  
  homepage text check (homepage like 'http://%'),
  max_uncertain numeric NOT NULL DEFAULT 'nan'::numeric
);

COMMENT ON TABLE institutes 
   IS 'Past and future registered institutes participating in OSD';
COMMENT ON COLUMN institutes.id 
   IS 'lower case version of label to circumvent entries which just differ in case';
COMMENT ON COLUMN institutes.label 
   IS 'Name of Institute (best for display)';


SELECT AddGeometryColumn(
  'institutes',
  'geom',
   4326,
  'POINT',
  2
);

CREATE UNIQUE INDEX lower_unq_institution_id ON osdregistry.institutes (lower(label));

-- todo add institute geo-reference table


INSERT 
  INTO institutes (id, label, geom) 
SELECT DISTINCT ON ( trim(lower(institution)) )
       trim(lower(institution)) as l,
       institution,  
       ST_geomFromText( 'POINT(' || institution_long || ' ' || institution_lat || ')', 4326)

  FROM web_r8.osd_participants;


CREATE TABLE participants (
  email text PRIMARY KEY,
  first_name text NOT NULL,
  last_name text NOT NULL
);

-- add particpant
INSERT 
  INTO participants (email, first_name, last_name) 
SELECT DISTINCT ON (email)
       email, first_name, last_name
  FROM curation_submissions;

\echo inserting more institutes

INSERT 
  INTO institutes (id, label) 
SELECT DISTINCT ON ( trim(lower(institute)) ) 
           trim(lower(o.institute)) as l, o.institute
    FROM curation_submissions o
   WHERE NOT EXISTS (SELECT institute 
                       FROM institutes i 
                      WHERE trim(lower(i.label)) = trim(lower(o.institute)));


CREATE TABLE affiliated (
  email text REFERENCES participants(email),
  institute text REFERENCES institutes(id),
  PRIMARY KEY (email,institute)
);


INSERT 
  INTO affiliated (email, institute) 
SELECT DISTINCT ON (email)
       email, trim(lower(institute))
  FROM curation_submissions;

-- todo add geometry
-- todo add sync between geom ang geog trigger
-- todo add georef stuff
-- add geog and geom idx

CREATE TABLE sites (
  id integer check (id > 0) PRIMARY KEY, 
  label text NOT NULL DEFAULT '',
  label_verb text NOT NULL,
  region text NOT NULL DEFAULT '',
  region_verb text NOT NULL DEFAULT '',
  geog geography(POINT,4326),
  max_uncertain numeric NOT NULL DEFAULT 'nan'::numeric
);



SELECT AddGeometryColumn(
  'sites',
  'geom',
   4326,
  'POINT',
  2
);

COMMENT ON TABLE sites IS 'The registered OSD sites';
COMMENT ON COLUMN sites.id IS 'the OSD id number missing the OSD prefix';
COMMENT ON COLUMN sites.label IS 'Curated name of OSD site (mainly for display)';


CREATE FUNCTION osdregistry.sites_geom_sync_trg(
-- geometry_col_name text
-- geography_col_name text
)
  RETURNS trigger AS
$BODY$

declare

begin
   NEW.geog := NEW.geom::geography;

RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql
;

CREATE TRIGGER geom_geog_sync_trg
  BEFORE INSERT OR UPDATE OF geom
  ON osdregistry.sites
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.sites_geom_sync_trg();
 

-- first inserting data from osd-registry g-doc
INSERT 
  INTO sites 
       (id, label_verb, geom)
SELECT substring(osd_id from 4)::integer,
       trim(os.site_name),
       os.site_geom
  FROM web_r8.osd_samplingsites os
  --RETURNING st_x(geom), st_asText(geog)
; 


-- todo add date
CREATE TABLE osdregistry.samples (
  submission_id bigint  UNIQUE,
  osd_id integer NOT NULL REFERENCES sites(id),
  label text,  -- todo maybe hanbokk def of label
  label_verb text NOT NULL DEFAULT '',
  start_lat numeric DEFAULT 'nan', 
  start_lon numeric DEFAULT 'nan', 
  stop_lat numeric DEFAULT 'nan', 
  stop_lon numeric DEFAULT 'nan', 
  start_lat_verb text NOT NULL,
  start_lon_verb text NOT NULL,
  stop_lat_verb text NOT NULL,
  stop_lon_verb text NOT NULL,
  start_geog geography(POINT,4326),
  stop_geog geography(POINT,4326),
  water_depth numeric 
     NOT NULL DEFAULT 'nan' check ( water_depth >= 0 ),
  local_start time (0),
  local_end time (0),
  water_temperature numeric 
     NOT NULL DEFAULT 'nan' check ( water_temperature > -273),
  salinity numeric 
     NOT NULL DEFAULT 'nan' check ( salinity >= 0),
  -- accuracy
  protocol text NOT NULL DEFAULT '',
  env_params hstore,
  raw json
  -- submitted, modified : check naming
);

SELECT AddGeometryColumn(
  'osdregistry',
  'samples',
  'start_geom',
   4326,
  'POINT',
  2
);

SELECT AddGeometryColumn(
  'osdregistry',
  'samples',
  'stop_geom',
   4326,
  'POINT',
  2
);
COMMENT ON TABLE samples IS 'Collected environmental samples';


CREATE UNIQUE INDEX 
    ON osdregistry.samples (start_lat,start_lon,water_depth,local_start,protocol) 
 WHERE start_lat <> 'nan' AND start_lon <> 'nan' ;


CREATE FUNCTION osdregistry.curation_samples_geom_trg()
  RETURNS trigger AS
$BODY$

DECLARE

BEGIN
   IF (NEW.start_lat <> 'nan' AND NEW.start_lon <> 'nan') THEN
      NEW.start_geom 
         := st_geometryFromText(
               'POINT(' || NEW.start_lon || ' ' || NEW.start_lat ||')',
               4326 
            );
       RAISE DEBUG 'start geom=%', st_asText(NEW.start_geom);
      NEW.start_geog := NEW.start_geom::geography;
   END IF;
 
   IF ((NEW.stop_lat <> 'nan' AND NEW.stop_lon <> 'nan')) THEN
      NEW.stop_geom 
         := st_geometryFromText(
               'POINT(' || NEW.stop_lon || ' ' || NEW.stop_lat ||')',
                4326
            );
       RAISE DEBUG 'stop geom=%', st_asText(NEW.stop_geom);
      NEW.stop_geog := NEW.stop_geom::geography;
   END IF;
   RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;


CREATE TRIGGER start_geom_geog_sync_trg
  BEFORE INSERT OR UPDATE OF start_lat,start_lon
  ON osdregistry.samples
  FOR EACH ROW
  WHEN (NEW.start_lat <> 'nan' AND NEW.start_lon <> 'nan')
  EXECUTE PROCEDURE osdregistry.curation_samples_geom_trg();
 

CREATE TRIGGER stop_geom_geog_sync_trg
  BEFORE INSERT OR UPDATE OF stop_lat, stop_lon
  ON osdregistry.samples
  FOR EACH ROW
  WHEN (NEW.stop_lat <> 'nan' AND NEW.stop_lon <> 'nan')
  EXECUTE PROCEDURE osdregistry.curation_samples_geom_trg();


-- select * from osdregistry.curation_submissions where sample_label ilike '%SaoMiguel%';

/*
\echo copy curation_submissions overview json
\copy (SELECT * FROM curation_submissions) TO 'curation_submissions.csv' CSV HEADER DELIMITER E'\t' 
\echo copy submission overview finished
--*/

-- insert driectly inot domain model table
INSERT 
  INTO osdregistry.samples (
       submission_id,
       osd_id,
       label,
       label_verb,
       protocol,
       water_depth,
       local_start,
       local_end,
       water_temperature,
       start_lat_verb,
       start_lon_verb,
       stop_lat_verb,
       stop_lon_verb
       )
SELECT submission_id::bigint,
       osd_id::integer,
       sample_label,
       sample_label,
       sample_protocol,
       sample_depth::numeric,
       sample_start_time::time,
       sample_end_time::time,
       water_temperature::numeric,
       start_lat::text,
       start_lon::text,
       stop_lat::text,
       stop_lon::text

  FROM osdregistry.curation_submissions; 

-- better update on curation_submissions

UPDATE osdregistry.curation_submissions 
   SET (start_lat,start_lon,stop_lat,stop_lon,sample_depth) 
     = (start_lat_verb::numeric,start_lon_verb::numeric,stop_lat_verb::numeric,stop_lon_verb::numeric, sample_depth_verb)
 WHERE start_lat_verb NOT IN ('41.1416','33.32306','43.63871944444445')
       --AND start_lon_verb NOT IN ('24.99')
       AND sample_start_time_verb != '07:15:00'
       AND start_lat_verb ~ E'(^(-|\\+)?\\d+\.?\\d+$)'
       AND start_lon_verb ~ E'(^(-|\\+)?\\d+\.?\\d+$)'
       AND stop_lat_verb ~ E'(^(-|\\+)?\\d+\.?\\d+$)'
       AND stop_lon_verb ~ E'(^(-|\\+)?\\d+\.?\\d+$)'
       AND start_lat_verb::numeric BETWEEN -90 AND 90
       AND 
       start_lon_verb::numeric BETWEEN -180 AND 180
       AND 
       stop_lat_verb::numeric BETWEEN -90 AND 90
       AND 
       stop_lon_verb::numeric BETWEEN -180 AND 180
;  

-- TODO maybe name submission_owned by or internal_owned_by
CREATE TABLE owned_by (
  sample_id integer REFERENCES samples(submission_id),
  email text REFERENCES participants(email),
  seq_author_order integer check(seq_author_order > 0)
);


CREATE TABLE filters (
  sample_id integer REFERENCES samples(submission_id),
  label text,
  raw json
);

\echo number osd particpanats

select count(*) from web_r8.osd_participants;
--select * from osd_participants;

-- not really needed now

CREATE TABLE site_registrations (
  institute text REFERENCES institutes(id),
  site_id integer REFERENCES sites(id),
  campaign text REFERENCES campaigns (label),
  -- TODO check name
  registration_date timestamp with time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE site_registrations 
   IS 'Which institute registers a site for OSD campaign at a certain time';

INSERT 
  INTO site_registrations 
       (institute, site_id, campaign, registration_date)
SELECT trim(lower(institution)), substring(id from 4)::integer, 'OSD-Jun-2014', 'infinity' 
  FROM web_r8.osd_participants
--  RETURNING * 
; 



ROLLBACK;

