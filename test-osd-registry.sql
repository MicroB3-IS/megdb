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
        id::integer as submission_id,
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
        (raw_json #>> '{investigators}')::json AS investigators,
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
          raw_json #>> '{environment, bacterial_production_respiration, bacterial_production_respiration-choice}'        END as bacterial_production_respiration,
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


-- TODO maybe add time range here
-- TODO add check regex
CREATE TABLE campaigns (
  label text PRIMARY KEY 
);

select curation.add_audit_trg('campaigns');
  
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



CREATE TABLE participants (
  email text PRIMARY KEY,
  first_name text NOT NULL,
  last_name text NOT NULL
);


CREATE TABLE affiliated (
  email text REFERENCES participants(email),
  institute text REFERENCES institutes(id),
  PRIMARY KEY (email,institute)
);



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

/*
SELECT submission_id, 
       row_number() OVER (PARTITION BY submission_id),
       o.first_name AS main_first_name,
       o.last_name AS main_last_name,
       o.email AS main_email,
       o.institute AS main_institute,

       t.i ->> 'first_name' as first_name,
       t.i ->> 'last_name' as last_name,
       t.i ->> 'email' as email,
       t.i ->> 'institute' as institute,
       o.investigators
  FROM submission_overview o, json_array_elements( o.investigators ) as t(i) 
 WHERE submission_id in (12,19,44);
--*/

select json_array_elements( investigators ) from submission_overview   WHERE submission_id in (12,19,44);

select s.investigators, g, g+2 as order, s.investigators->>g as p, (s.investigators->g)->>'email' 
 FROM submission_overview s,LATERAL generate_series(0, json_array_length(s.investigators)-1) g where submission_id in (12,44);
;
/*
WITH investigators AS (
  SELECT * from ( json_array_elements( select investigators from submission_overview ) ) as t
) 
Select * from investigators order by submission_id limit 10 ;
*/


/*
\echo copy curation_submissions overview json
\copy (SELECT * FROM curation_submissions) TO 'submission_overview.csv' CSV HEADER DELIMITER E'\t' 
\echo copy submission overview finished
--*/

--- Osd registry data insert patch


INSERT 
  INTO institutes (id, label, geom) 
SELECT DISTINCT ON ( trim(lower(institution)) )
       trim(lower(institution)) as l,
       institution,  
       ST_geomFromText( 'POINT(' || institution_long || ' ' || institution_lat || ')', 4326)

  FROM web_r8.osd_participants;


 -- add particpants
INSERT 
  INTO participants (email, first_name, last_name) 
SELECT DISTINCT ON (email)
       email, first_name, last_name
  FROM submission_overview;

\echo inserting more institutes

INSERT 
  INTO institutes (id, label) 
SELECT DISTINCT ON ( trim(lower(institute)) ) 
           trim(lower(o.institute)) as l, o.institute
    FROM submission_overview o
   WHERE NOT EXISTS (SELECT institute 
                       FROM institutes i 
                      WHERE trim(lower(i.label)) = trim(lower(o.institute)));



INSERT 
  INTO affiliated (email, institute) 
SELECT DISTINCT ON (email)
       email, trim(lower(institute))
  FROM submission_overview;


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
       COALESCE (water_temperature::numeric, 'nan'::numeric),
       start_lat::text,
       start_lon::text,
       stop_lat::text,
       stop_lon::text

  FROM osdregistry.submission_overview; 


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

