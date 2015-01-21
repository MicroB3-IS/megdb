
BEGIN;
SELECT _v.register_patch('00110-full-osd-registry',
                          array['00109-new-curation-schema'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

\pset pager off

SET search_path TO osdregistry,public;

SET ROLE megdb_admin;

-- patch 1: fix-default-privs-osdregistry

ALTER DEFAULT PRIVILEGES IN SCHEMA osdregistry REVOKE SELECT ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA osdregistry GRANT SELECT ON TABLES TO megx_team;
ALTER DEFAULT PRIVILEGES IN SCHEMA osdregistry REVOKE ALL ON FUNCTIONS FROM PUBLIC;

DROP TABLE IF EXISTS osdregistry.test_samples;

-- creating domains for latitude and longitudes

CREATE DOMAIN osdregistry.latitude AS numeric
   DEFAULT 'NaN'
   CHECK ( VALUE = 'NaN' OR (VALUE >= -90::numeric AND VALUE <= 90::numeric));


CREATE DOMAIN osdregistry.longitude AS numeric
   DEFAULT 'nan'
   CHECK (VALUE = 'NaN' OR ( VALUE >= -180::numeric AND VALUE <= 180::numeric));


-- delete old test data
DELETE FROM osdregistry.osd_raw_samples 
 WHERE id in (5,6,41,57,64,98,99,100,185);


CREATE OR REPLACE FUNCTION osdregistry.cleantrimtab(text) RETURNS text AS $$
   SELECT translate( trim( $1 ), E'\t', ' '  );
$$ LANGUAGE SQL; 


DROP VIEW IF EXISTS  osdregistry.submission_overview;

CREATE OR REPLACE VIEW  osdregistry.submission_overview AS
   select
        id::integer as submission_id,
        submitted,
        CASE WHEN
          (raw_json #>> '{sampling_site, site_id}')::text = 'OSDFamagusta' 
        THEN
          19::integer 
        ELSE 
         substring (raw_json #>> '{sampling_site, site_id}' 
                    from E'(?i)[OSD ]{3,4}(\\d{1,3})')::integer 
        END as osd_id,
        cleantrimtab( raw_json #>> '{sampling_site, site_name}' ) AS site_name,
        version,
        raw_json #>> '{sampling_site, marine_region}' as marine_region,
        CASE WHEN
          version  = 6
        THEN
          ltrim (raw_json #>> '{sampling_site, start_coordinates,latitude}', '+0')
        ELSE
          ltrim( raw_json #>> '{sampling_site,latitude}','+0')
        END AS start_lat,
        CASE WHEN
          version  = 6
        THEN
          ltrim(raw_json #>> '{sampling_site, start_coordinates,longitude}', '+0')
        ELSE
          ltrim(raw_json #>> '{sampling_site, longitude}', '+0')
        END as start_lon,
        -- now stop coordinates
        CASE WHEN
          version  = 6
        THEN
          ltrim(raw_json #>> '{sampling_site, stop_coordinates,latitude}', '+0')
        ELSE
          ltrim(raw_json #>> '{sampling_site,latitude}', '+0')
        END AS stop_lat,
        CASE WHEN
          version  = 6
        THEN
          ltrim(raw_json #>> '{sampling_site, stop_coordinates,longitude}', '+0')
        ELSE
          ltrim(raw_json #>> '{sampling_site, longitude}', '+0')
        END as stop_lon,
        raw_json #>> '{sample,start_time}' as sample_start_time,
        raw_json #>> '{sample,end_time}' as sample_end_time,
        cleantrimtab( raw_json #>> '{sample,label}' ) as sample_label,
        trim( raw_json #>> '{sample, protocol_label}' ) as sample_protocol,
        cleantrimtab(raw_json #>> '{sampling_site, objective}') as objective,
        cleantrimtab(raw_json #>> '{sampling_site, platform}') as platform,
        cleantrimtab(raw_json #>> '{sampling_site, device}') as device,
        COALESCE ( raw_json #>> '{sample, depth}', 'nan' ) as sample_depth,
        raw_json #>> '{sample, date}' as sample_date,
        raw_json #>> '{sample, description}' as sample_description,
        trim( raw_json #>> '{contact, first_name}' ) as first_name,
        trim( raw_json #>> '{contact, last_name}' ) as last_name,
        trim( raw_json #>> '{contact, institute}' ) as institute,
        raw_json #>> '{contact, email}' as email,
        (raw_json #>> '{investigators}')::json AS investigators,
        raw_json -> 'environment' ->> 'water_temperature' as water_temperature,
        (raw_json -> 'environment' ->> 'salinity')::numeric as salinity,
        raw_json -> 'environment' ->> 'biome' as biome,
        raw_json -> 'environment' ->> 'feature' as feature,
        raw_json -> 'environment' ->> 'material' as material,
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
        END as phosphate,
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
        
        (COALESCE ( (raw_json -> 'environment' ->> 'other_parameters'), '{"param":"not determined"}'))::json as other_params,

        raw_json -> 'comment' as remarks,
        (raw_json #>> '{sample,filters}')::json as filters,
        raw_json
         
   from osdregistry.osd_raw_samples 
   WHERE (raw_json ->> 'version' = '6' OR raw_json ->> 'version' = '5') order by osd_id  desc
;
-- end osdregistry.submission_overview

/*
SELECT ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'osdregistry' -- Default is usually 'public'.
AND table_name = 'submission_overview'
ORDER BY ordinal_position;
--*/






CREATE VIEW osdregistry.submission_dirty_participants AS
 SELECT osd_id::integer,
        submission_id::integer,
         g+2::integer as author_position,
        (s.investigators->g)->>'email' as email,
        (s.investigators->g)->>'first_name' as first_name,
        (s.investigators->g)->>'last_name' as last_name,
        (s.investigators->g)->>'institute' as institute,
        s.investigators->>g as raw
   FROM osdregistry.submission_overview s,
        LATERAL 
        generate_series(0, json_array_length(s.investigators)-1) g

UNION 

SELECT osd_id::integer,
       submission_id::integer,
       1::integer as author_position,
       email,
       first_name,
       last_name,
       institute,
       trim( raw_json #>> '{contact}' )
 FROM submission_overview
;

CREATE VIEW submission_duplicate_particiapnts AS

 SELECT osd_id,
        submission_id,
        max(author_position) as author_position,
        email as email,
        min(first_name) as first_name,
        min(last_name) as last_name,
        max(institute) as institute,
        max(raw) as raw
   FROM osdregistry.submission_dirty_participants
  --WHERE osd_id IN ( 187, 188, 198, 196, 221, 223) 
GROUP BY osd_id, submission_id, email HAVING count(author_position) > 1 
--order by osd_id, submission_id
;


select * from submission_duplicate_particiapnts;



CREATE VIEW osdregistry.submission_participants AS
 SELECT d.osd_id,
        d.submission_id,
        d.author_position,
        d.email,
        d.first_name,
        d.last_name,
        d.institute,
        d.raw
   FROM osdregistry.submission_dirty_participants d 
LEFT JOIN
        osdregistry.submission_duplicate_particiapnts t
     ON (d.submission_id = t.submission_id 
         AND
         d.author_position = t.author_position)
WHERE t.email IS NULL 

;



CREATE VIEW osdregistry.submission_filters AS
 SELECT osd_id,
        submission_id,
        g + 1 as num, --json arrays start at 0
        (s.filters->g)->>'filtration_time' as filtration_time,
        (s.filters->g)->>'quantity' as quantity,
        (s.filters->g)->>'container' as container,
        (s.filters->g)->>'content' as content,
        (s.filters->g)->>'size-fraction_lower-threshold' as size_fraction_lower_threshold,
        (s.filters->g)->>'size-fraction_upper-threshold' as size_fraction_upper_threshold,
        (s.filters->g)->>'treatment_chemicals' as treatment_chemicals,
        (s.filters->g)->>'treatment_storage' as treatment_storage,
        (s.filters->g) as raw
   FROM osdregistry.submission_overview s,
        LATERAL 
        generate_series(0, json_array_length(s.filters)-1) g
;

-- select * from osdregistry.submission_filters;
-- select * from submission_participants order by submission_id, author_position;



CREATE FUNCTION osdregistry.lat_lon_sync_trg(
-- geometry_col_name text
-- geography_col_name text
)
  RETURNS trigger AS
$BODY$

declare

begin
   IF NEW.lat <> 'nan' AND NEW.lon <> 'nan' THEN
      NEW.geom := ST_geomFromText( 'POINT(' || NEW.lon || ' ' || NEW.lat || ')', 4326);
      NEW.geog := NEW.geom::geography;
   END IF;

   RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;



-- TODO maybe add time range here
-- TODO add check regex
CREATE TABLE campaigns (
  label text PRIMARY KEY 
);
GRANT UPDATE ON campaigns TO megx_team;

-- do not want this to be audited  
INSERT INTO campaigns 
     VALUES ('OSD-Jun-2012'),('OSD-Dec-2012'),
            ('OSD-Jun-2013'),('OSD-Dec-2013'),
            ('OSD-Jun-2014'),('OSD-Dec-2014'),
            ('OSD-Jun-2015'),('OSD-Dec-2015'), 
            ('OSD-Jun-2016'),('OSD-Dec-2017');

select curation.add_audit_trg('campaigns');

-- todo add lat,lon and automatic update trigger
CREATE TABLE institutes (
  label text PRIMARY KEY, -- the label for display
  label_short text NOT NULL DEFAULT '',
  label_verb text NOT NULL,
  lat latitude NOT NULL,
  lat_verb text NOT NULL DEFAULT ''::text,
  lon longitude NOT NULL,
  lon_verb text NOT NULL DEFAULT ''::text,
  geog geography(POINT,4326),
  country_verb text NOT NULL DEFAULT '',
  country text,
  country_iso_cd text ,
  FOREIGN KEY (country, country_iso_cd) 
     REFERENCES elayers.boundaries (terr_name, iso3_code) ON UPDATE CASCADE,  
  homepage text check (homepage like 'http://%'),
  -- geo-referencing part
  georef_geodetic_datum text NOT NULL DEFAULT 'not recorded',
  max_uncertain numeric NOT NULL DEFAULT 'NaN'::numeric,
  coord_sys_verb text NOT NULL DEFAULT ''::text,
  georef_verification text NOT NULL DEFAULT ''::text,
  georef_validation text NOT NULL DEFAULT ''::text,
  georef_protocol text NOT NULL DEFAULT ''::text,
  georef_source text NOT NULL DEFAULT ''::text,
  spatial_fit numeric NOT NULL DEFAULT 'nan',
  curator text NOT NULL DEFAULT '',
  curation_remark text NOT NULL DEFAULT ''
);
GRANT UPDATE ( 
  label, lat, lon, 
  country, country_iso_cd, homepage, max_uncertain, 
  georef_verification, georef_validation, georef_protocol, georef_source, spatial_fit,
  curator, curation_remark 
)
ON institutes TO megx_team;


COMMENT ON TABLE institutes 
   IS 'Past and future registered institutes participating in OSD';
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


CREATE TRIGGER lat_lon_sync
  BEFORE INSERT OR UPDATE OF lat, lon
  ON osdregistry.institutes
  FOR EACH ROW
  WHEN (NEW.lat <> 'nan' AND NEW.lon <> 'nan')
  EXECUTE PROCEDURE osdregistry.lat_lon_sync_trg();
 
COMMENT ON COLUMN osdregistry.institutes.label_short
   IS 'The shorthand name of the institute';
COMMENT ON COLUMN osdregistry.institutes.max_uncertain 
   IS 'The upper limit of the distance IN METER from the given latitude and longitude
 describing a circle within which the whole of the described locality must lie';
COMMENT ON COLUMN osdregistry.institutes.lat_verb 
   IS 'The original (verbatim) coordinates of the raw data before any transformations were carried out';
COMMENT ON COLUMN osdregistry.institutes.lon_verb 
   IS 'The original (verbatim) coordinates of the raw data before any transformations were carried out';
COMMENT ON COLUMN osdregistry.institutes.coord_sys_verb 
   IS 'The coordinate system in which the raw data were recorded. 
If data are being entered into the database in Decimal Degrees. 
For example the geographic coordinates of the map or gazetteer used 
should be entered (e.g. decimal degrees degrees-minutes-seconds degrees-decimal minutes UTM coordinates)';
COMMENT ON COLUMN osdregistry.institutes.georef_verification 
   IS 'A categorical description of the extent to which the georeference and uncertainty have been verified 
to represent the location and uncertainty for where the specimen or observation was collected. 
See table cv.verification_codes';
COMMENT ON COLUMN osdregistry.institutes.georef_validation 
   IS 'Shows what validation procedures have been conducted on the georeferences for example various outlier
 detection procedures revisits to the location etc. Relates to Verification Status.';
COMMENT ON COLUMN osdregistry.institutes.georef_protocol 
  IS 'A reference to the method(s) used for determining the coordinates and uncertainty estimates 
(e.g. MaNIS Georeferencing Calculator).';
COMMENT ON COLUMN osdregistry.institutes.georef_source 
   IS 'A measure of how well the geometric representation matches the original spatial representation 
and is reported as the ratio of the area of the presented geometry to the area of 
the original spatial representation. A value of 1 is an exact match or 100% overlap. 
This is a new concept for use with biodiversity data but one that we are recommending here';

-- adding auditing
SELECT curation.add_audit_trg('osdregistry.institutes', true,true, '{country_verb}');


CREATE TABLE participants (
  email text PRIMARY KEY,
  first_name text NOT NULL,
  last_name text NOT NULL
);
SELECT curation.add_audit_trg('osdregistry.participants',true,true);

GRANT UPDATE,INSERT ON participants TO megx_team;


CREATE TABLE affiliated (
  email text REFERENCES participants(email) ON UPDATE CASCADE,
  institute text REFERENCES institutes(label) ON UPDATE CASCADE,
  PRIMARY KEY (email,institute)
);

SELECT curation.add_audit_trg('osdregistry.institutes', true,true);
GRANT INSERT, SELECT ON participants TO megx_team;


CREATE TABLE sites (
  id integer check (id > 0) PRIMARY KEY, 
  label text NOT NULL DEFAULT '',
  label_verb text NOT NULL,
  lat latitude NOT NULL,
  lat_verb text NOT NULL DEFAULT ''::text,
  lon longitude NOT NULL,
  lon_verb text NOT NULL DEFAULT ''::text,
  region text NOT NULL DEFAULT '',
  region_verb text NOT NULL DEFAULT '',
  geog geography(POINT,4326),

  georef_geodetic_datum text NOT NULL DEFAULT 'not recorded',
  max_uncertain numeric NOT NULL DEFAULT 'NaN'::numeric,
  coord_sys_verb text NOT NULL DEFAULT ''::text,
  georef_verification text NOT NULL DEFAULT ''::text,
  georef_validation text NOT NULL DEFAULT ''::text,
  georef_protocol text NOT NULL DEFAULT ''::text,
  georef_source text NOT NULL DEFAULT ''::text,
  spatial_fit numeric NOT NULL DEFAULT 'nan',

  curator text NOT NULL DEFAULT '',
  curation_remark text NOT NULL DEFAULT ''
);

SELECT AddGeometryColumn(
  'sites',
  'geom',
   4326,
  'POINT',
  2
);
SELECT curation.add_audit_trg('osdregistry.sites', true,true, '{geog,geom}');
GRANT UPDATE ( 
  label, lat, lon, 
  region, max_uncertain, georef_geodetic_datum, 
  georef_verification, georef_validation, georef_protocol, georef_source, spatial_fit,
  curator, curation_remark 
)
ON sites TO megx_team;

COMMENT ON TABLE sites 
   IS 'The registered OSD sites';
COMMENT ON COLUMN sites.id 
   IS 'the OSD id number missing the OSD prefix';
COMMENT ON COLUMN sites.label 
   IS 'Curated name of OSD site (mainly for display)';
COMMENT ON COLUMN osdregistry.sites.max_uncertain IS 'The upper limit of the distance IN METER from the given latitude and longitude describing a circle within which the whole of the described locality must lie';
COMMENT ON COLUMN osdregistry.sites.lat_verb IS 'The original (verbatim) coordinates of the raw data before any transformations were carried out';
COMMENT ON COLUMN osdregistry.sites.lon_verb IS 'The original (verbatim) coordinates of the raw data before any transformations were carried out';
COMMENT ON COLUMN osdregistry.sites.coord_sys_verb IS 'The coordinate system in which the raw data were recorded. If data are being entered into the database in Decimal Degrees. For example the geographic coordinates of the map or gazetteer used should be entered (e.g. decimal degrees degrees-minutes-seconds degrees-decimal minutes UTM coordinates)';
COMMENT ON COLUMN osdregistry.sites.georef_verification IS 'A categorical description of the extent to which the georeference and uncertainty have been verified to represent the location and uncertainty for where the specimen or observation was collected. See table cv.verification_codes';
COMMENT ON COLUMN osdregistry.sites.georef_validation IS 'Shows what validation procedures have been conducted on the georeferences for example various outlier detection procedures revisits to the location etc. Relates to Verification Status. NOt sure if useful for MegDb';
COMMENT ON COLUMN osdregistry.sites.georef_protocol IS 'A reference to the method(s) used for determining the coordinates and uncertainty estimates (e.g. MaNIS Georeferencing Calculator).';
COMMENT ON COLUMN osdregistry.sites.georef_source IS 'A measure of how well the geometric representation matches the original spatial representation and is reported as the ratio of the area of the presented geometry to the area of the original spatial representation. A value of 1 is an exact match or 100% overlap. This is a new concept for use with biodiversity data but one that we are recommending here';



CREATE TRIGGER sites_lat_lon_sync
  BEFORE INSERT OR UPDATE OF geom
  ON osdregistry.sites
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.lat_lon_sync_trg();
 
-- todo add date
CREATE TABLE osdregistry.samples (
  submission_id bigint  PRIMARY KEY,
  osd_id integer NOT NULL REFERENCES sites(id),
  label text,  -- todo maybe hanbook def of label
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
  max_uncertain numeric NOT NULL DEFAULT 'NaN'::numeric,
  water_depth numeric 
     NOT NULL DEFAULT 'nan' check ( water_depth >= 0 OR water_depth = 'nan'::numeric),
  local_date date NOT NULL DEFAULT 'infinity',
  local_date_verb text NOT NULL DEFAULT '',
  local_start time (0) with time zone,
  local_end time (0) with time zone,
  protocol text NOT NULL DEFAULT '',
  objective text NOT NULL DEFAULT '',
  platform text NOT NULL DEFAULT '',
  platform_verb text NOT NULL DEFAULT '',
  device  text NOT NULL DEFAULT '',
  description text NOT NULL DEFAULT '',
  water_temperature numeric 
     NOT NULL DEFAULT 'nan' check ( water_temperature > -273),
  salinity numeric 
     NOT NULL DEFAULT 'nan' check ( salinity >= 0),
  biome text NOT NULL DEFAULT '',
  feature text NOT NULL DEFAULT '',
  material text NOT NULL DEFAULT '',
  curator text NOT NULL DEFAULT '',
  curation_remark text NOT NULL DEFAULT '',
  ph numeric NOT NULL DEFAULT 'NaN' check ( (ph >= 0 AND ph <+12) OR ph = 'NaN' ), 
  ph_verb text NOT NULL DEFAULT '',
  phosphate numeric NOT NULL DEFAULT 'NaN' check (phosphate >= 0 OR phosphate = 'NaN'), 
  phosphate_verb text NOT NULL DEFAULT '',
  nitrate numeric NOT NULL DEFAULT 'NaN' check (nitrate >= 0 OR nitrate = 'NaN'), 
  nitrate_verb text NOT NULL DEFAULT '',
  carbon_organic_particulate numeric NOT NULL DEFAULT 'NaN' check (carbon_organic_particulate >= 0 OR carbon_organic_particulate = 'NaN'),
  carbon_organic_particulate_verb text NOT NULL DEFAULT '',
  nitrite numeric NOT NULL DEFAULT 'NaN' check (nitrite >= 0 OR nitrite = 'NaN'),
  nitrite_verb text NOT NULL DEFAULT '',
  carbon_organic_dissolved_doc numeric NOT NULL DEFAULT 'NaN' check (carbon_organic_dissolved_doc >= 0 OR carbon_organic_dissolved_doc = 'NaN'),
  carbon_organic_dissolved_doc_verb text NOT NULL DEFAULT '',
  nano_microplankton numeric NOT NULL DEFAULT 'NaN' check (nano_microplankton >= 0 OR nano_microplankton = 'NaN'),
  nano_microplankton_verb text NOT NULL DEFAULT '',
  downward_par numeric NOT NULL DEFAULT 'NaN' check (downward_par >= 0 OR downward_par = 'NaN'),
  downward_par_verb text NOT NULL DEFAULT '',
  conductivity numeric NOT NULL DEFAULT 'NaN' check (conductivity >= 0 OR conductivity = 'NaN'), 
  conductivity_verb text NOT NULL DEFAULT '',
  primary_production_isotope_uptake numeric NOT NULL DEFAULT 'NaN' check (primary_production_isotope_uptake >= 0 OR primary_production_isotope_uptake = 'NaN'),
  primary_production_isotope_uptake_verb text NOT NULL DEFAULT '',
  primary_production_oxygen numeric NOT NULL DEFAULT 'NaN' check (primary_production_oxygen >= 0 OR primary_production_oxygen = 'NaN'),
  primary_production_oxygen_verb text NOT NULL DEFAULT '',
  dissolved_oxygen_concentration numeric NOT NULL DEFAULT 'NaN' check (dissolved_oxygen_concentration >= 0 OR dissolved_oxygen_concentration = 'NaN'), 
  dissolved_oxygen_concentration_verb text NOT NULL DEFAULT '',
  nitrogen_organic_particulate_pon numeric NOT NULL DEFAULT 'NaN' check (nitrogen_organic_particulate_pon >= 0 OR nitrogen_organic_particulate_pon = 'NaN'), 
  nitrogen_organic_particulate_pon_verb text NOT NULL DEFAULT '',
  meso_macroplankton numeric NOT NULL DEFAULT 'NaN' check (meso_macroplankton >= 0 OR meso_macroplankton = 'NaN'), 
  meso_macroplankton_verb text NOT NULL DEFAULT '',
  bacterial_production_isotope_uptake numeric NOT NULL DEFAULT 'NaN' check (bacterial_production_isotope_uptake >= 0 OR bacterial_production_isotope_uptake = 'NaN'), 
  bacterial_production_isotope_uptake_verb text NOT NULL DEFAULT '',
  nitrogen_organic_dissolved_don numeric NOT NULL DEFAULT 'NaN' check (nitrogen_organic_dissolved_don >= 0 OR nitrogen_organic_dissolved_don = 'NaN'), 
  nitrogen_organic_dissolved_don_verb text NOT NULL DEFAULT '',
  ammonium numeric NOT NULL DEFAULT 'NaN' check (ammonium >= 0 OR ammonium = 'NaN'), 
  ammonium_verb text NOT NULL DEFAULT '',
  silicate numeric NOT NULL DEFAULT 'NaN' check (silicate >= 0 OR silicate = 'NaN'), 
  silicate_verb text NOT NULL DEFAULT '',
  bacterial_production_respiration numeric NOT NULL DEFAULT 'NaN' check (bacterial_production_respiration >= 0 OR bacterial_production_respiration = 'NaN'), 
  bacterial_production_respiration_verb text NOT NULL DEFAULT '',
  turbidity numeric NOT NULL DEFAULT 'NaN' check (turbidity >= 0 OR turbidity = 'NaN'), 
  turbidity_verb text NOT NULL DEFAULT '',
  fluorescence numeric NOT NULL DEFAULT 'NaN', 
  fluorescence_verb text NOT NULL DEFAULT '',
  pigment_concentration numeric NOT NULL DEFAULT 'NaN' check (pigment_concentration >= 0 OR pigment_concentration = 'NaN'), 
  pigment_concentration_verb text NOT NULL DEFAULT '',
  picoplankton_flow_cytometry numeric NOT NULL DEFAULT 'NaN' check (picoplankton_flow_cytometry >= 0 OR picoplankton_flow_cytometry = 'NaN'),
  picoplankton_flow_cytometry_verb text NOT NULL DEFAULT '',
  other_params json NOT NULL DEFAULT '{}',
  remarks json NOT NULL DEFAULT '{}',
  raw json
  -- TODO submitted, modified : check naming
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

GRANT UPDATE (
curation_remark,
curator,
start_lat,
start_lon,
stop_lat,
stop_lon,
local_date,
local_start,
max_uncertain,
local_end,
label,
protocol,
objective,
platform,
device,
water_depth,
water_temperature,
salinity,
ph,
phosphate,
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
) ON osdregistry.samples TO megdb_admin,megx_team;


SELECT curation.add_audit_trg('osdregistry.samples', true,true, '{raw,start_geom,start_geog,stop_geom,stop_geog}');


COMMENT ON TABLE samples IS 'Collected environmental samples';


CREATE UNIQUE INDEX 
    ON osdregistry.samples (start_lat,start_lon,water_depth,local_date,local_start,protocol) 
 WHERE start_lat <> 'nan' AND start_lon <> 'nan' ;


CREATE FUNCTION osdregistry.curation_samples_geom_trg()
  RETURNS trigger AS
$BODY$

DECLARE

BEGIN
   IF (NEW.start_lat IS DISTINCT FROM 'nan' 
          AND NEW.start_lon IS DISTINCT FROM 'nan') THEN
      NEW.start_geom 
         := st_geometryFromText(
               'POINT(' || NEW.start_lon || ' ' || NEW.start_lat ||')',
               4326 
            );
       RAISE DEBUG 'start geom=%', st_asText(NEW.start_geom);
      NEW.start_geog := NEW.start_geom::geography;
   END IF;
 
   IF ((NEW.stop_lat  IS DISTINCT FROM 'nan' 
            AND NEW.stop_lon  IS DISTINCT FROM 'nan')) THEN
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


CREATE TRIGGER start_geom_geog_sync
  BEFORE INSERT OR UPDATE OF start_lat,start_lon
  ON osdregistry.samples
  FOR EACH ROW
  WHEN (NEW.start_lat  IS DISTINCT FROM 'nan' AND NEW.start_lon  IS DISTINCT FROM 'nan')
  EXECUTE PROCEDURE osdregistry.curation_samples_geom_trg();
 

CREATE TRIGGER stop_geom_geog_sync
  BEFORE INSERT OR UPDATE OF stop_lat, stop_lon
  ON osdregistry.samples
  FOR EACH ROW
  WHEN (NEW.stop_lat  IS DISTINCT FROM 'nan' AND NEW.stop_lon  IS DISTINCT FROM 'nan')
  EXECUTE PROCEDURE osdregistry.curation_samples_geom_trg();


-- TODO maybe name submission_owned by or internal_owned_by
CREATE TABLE owned_by (
  sample_id integer REFERENCES samples(submission_id),
  email text REFERENCES participants(email) ON UPDATE CASCADE,
  PRIMARY KEY (sample_id, email),
  seq_author_order integer check(seq_author_order > 0),
  curator text NOT NULL DEFAULT '',
  curation_remark text NOT NULL DEFAULT ''
);
SELECT curation.add_audit_trg('osdregistry.owned_by', true,true);


-- only one institute per site
CREATE TABLE institute_sites (
  label text REFERENCES institutes(label) ON UPDATE CASCADE,
  osd_id integer UNIQUE REFERENCES sites(id)
);


CREATE TABLE filters (
  sample_id integer REFERENCES samples(submission_id),
  num integer check ( num > 0),
  filtration_time interval MINUTE NOT NULL DEFAULT '0',
  filtration_time_verb text,
  quantity numeric NOT NULL DEFAULT 'nan' check (quantity > 0::numeric),
  quantity_verb text NOT NULL DEFAULT '',
  container text NOT NULL DEFAULT '',
  container_verb text NOT NULL DEFAULT '',
  content text NOT NULL DEFAULT '',
  content_verb text NOT NULL DEFAULT '',
  size_fraction_lower_threshold numeric NOT NULL DEFAULT 'nan',
  size_fraction_lower_threshold_verb text NOT NULL DEFAULT '',
  size_fraction_upper_threshold numeric NOT NULL DEFAULT 'nan',
  size_fraction_upper_threshold_verb text NOT NULL DEFAULT '',
  treatment_chemicals text NOT NULL DEFAULT '',
  treatment_chemicals_verb text NOT NULL DEFAULT '',
  treatment_storage text NOT NULL DEFAULT '',
  treatment_storage_verb text NOT NULL DEFAULT '',
  curator text NOT NULL DEFAULT '',
  curation_remark text NOT NULL DEFAULT '',
  raw json NOT NULL DEFAULT '{}'::json,
  PRIMARY KEY(sample_id, num)
);
SELECT curation.add_audit_trg('osdregistry.owned_by', true,true, '{raw}');


--- Osd registry data insert patch
\echo inserting  institutes from site registry
INSERT 
  INTO institutes 
       (label, label_verb, lat, lon, lat_verb, lon_verb, 
        country_verb,country, country_iso_cd,
        curation_remark) 
SELECT DISTINCT ON ( cleantrimtab(lower(institution)) )
       cleantrimtab(institution),  
       institution,  
       institution_lat::double precision,
       institution_lon::double precision,
       institution_lat::double precision,
       institution_lon::double precision,
       COALESCE (b.terr_name, ''),
       b.terr_name,
       b.iso3_code,
       'derived country names from join against boundaries table'
  FROM web_r8.osd_samplingsites
       LEFT JOIN
       elayers.boundaries AS b
       ON ( ST_Within( ST_geomFromText('POINT(' || institution_lon::double precision 
                              || ' ' || institution_lat::double precision || ')', 4326 ),
                      b.geom )
       )
;

       
\echo inserting more institutes from participant list

-- todo insert country maybe even lat lon	 
INSERT 
  INTO institutes 
       (label, label_verb ) 
VALUES ('Max Planck Institute for Marine Microbiology','Max Planck Institute for Marine Microbiology'),
       ('Institute of Biomembrane and Bioenergetics -CNR, Bari','Institute of Biomembrane and Bioenergetics -CNR, Bari'),
       ('J. Craig Venter Institute','J. Craig Venter Institute'),
       ('Institute of Microbiology, University of Kiel','Institute of Microbiology, University of Kiel'),
       ('University of the Azores','University of the Azores'),
       ('Aix-Marseille University - MIO','Aix-Marseille University - MIO'),
       ('National Oceanic and Atmospheric Administration - AOML & SWFSC','National Oceanic and Atmospheric Administration - AOML & SWFSC'),
       ('Institute of Biology Department of Marine Biology University of Oslo','Institute of Biology Department of Marine Biology University of Oslo'),
       ('Woods Hole Oceanographic Institute','Woods Hole Oceanographic Institute'),
       ('Columbia University','Columbia University')

;


/*
INSERT 
  INTO institutes (label, label_verb) 
SELECT DISTINCT ON ( cleantrimtab(lower(institute)) ) 
           cleantrimtab(o.institute), o.institute
    FROM submission_participants o
   WHERE NOT EXISTS (SELECT institute 
                       FROM institutes i 
                      WHERE cleantrimtab(lower(i.label)) = cleantrimtab(lower(o.institute)));
--*/
-- select * from institutes order by id;



-- first inserting data from osd-registry g-doc
\echo inserting sites
INSERT 
  INTO sites 
       (id, label_verb, lat, lat_verb, lon, lon_verb)
SELECT substring(osd_id from 4)::integer,
       trim(os.site_name),
       os.site_lat::numeric,
       os.site_lat::numeric,
       os.site_lon::numeric,
       os.site_lon::numeric
  FROM web_r8.osd_samplingsites os
  --RETURNING st_x(geom), st_asText(geog)
; 


\echo inserting samples
-- insert directly into domain model table
INSERT 
  INTO osdregistry.samples (
       submission_id,
       osd_id,
       label,
       label_verb,

       start_lat_verb,
       start_lon_verb,
       stop_lat_verb,
       stop_lon_verb,

       water_depth,

       local_date,
       local_date_verb,
       local_start,
       local_end,

       protocol,
       objective,
       platform,
       device,
       description,

       water_temperature,
       salinity,
       biome,
       feature,
       material,

       ph, 
       ph_verb,
       phosphate,
       phosphate_verb,
       nitrate, 
       nitrate_verb,
       carbon_organic_particulate,
       carbon_organic_particulate_verb,
       nitrite,
       nitrite_verb,
       carbon_organic_dissolved_doc,
       carbon_organic_dissolved_doc_verb,
       nano_microplankton,
       nano_microplankton_verb,
       downward_par,
       downward_par_verb,
       conductivity , 
       conductivity_verb,
       primary_production_isotope_uptake,
       primary_production_isotope_uptake_verb,
       primary_production_oxygen,
       primary_production_oxygen_verb,
       dissolved_oxygen_concentration , 
       dissolved_oxygen_concentration_verb,
       nitrogen_organic_particulate_pon , 
       nitrogen_organic_particulate_pon_verb,
       meso_macroplankton , 
       meso_macroplankton_verb,
       bacterial_production_isotope_uptake , 
       bacterial_production_isotope_uptake_verb,
       nitrogen_organic_dissolved_don , 
       nitrogen_organic_dissolved_don_verb,
       ammonium, 
       ammonium_verb,
       silicate , 
       silicate_verb,
       bacterial_production_respiration , 
       bacterial_production_respiration_verb,
       turbidity , 
       turbidity_verb,
       fluorescence , 
       fluorescence_verb,
       pigment_concentration , 
       pigment_concentration_verb,
       picoplankton_flow_cytometry,
       picoplankton_flow_cytometry_verb,
       other_params



       )
SELECT submission_id::bigint,
       osd_id::integer,
       sample_label,
       sample_label,

       start_lat::text,
       start_lon::text,
       stop_lat::text,
       stop_lon::text,

       sample_depth::numeric,

       sample_date::date,
       sample_date::text,
       sample_start_time::time,
       sample_end_time::time,
       
       sample_protocol,
       objective,
       platform,
       device,
       sample_description,

       COALESCE (water_temperature::numeric, 'nan'::numeric),
       COALESCE ( salinity, 'nan'::numeric ),
       biome,
       feature,
       material,
       CASE WHEN ph IS NULL OR ph ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          ph::numeric
       END,
COALESCE(ph, ''),
       CASE WHEN phosphate IS NULL OR phosphate ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          phosphate::numeric
       END,
COALESCE(phosphate, ''),

       CASE WHEN nitrate IS NULL OR nitrate ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          nitrate::numeric
       END, 
COALESCE(nitrate, ''),
       CASE WHEN carbon_organic_particulate IS NULL OR carbon_organic_particulate ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          carbon_organic_particulate::numeric
       END,
COALESCE(carbon_organic_particulate, ''),
       CASE WHEN nitrite IS NULL OR nitrite ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          nitrite::numeric
       END,
COALESCE(nitrite, ''),
       CASE WHEN carbon_organic_dissolved_doc IS NULL OR carbon_organic_dissolved_doc ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          carbon_organic_dissolved_doc::numeric
       END,
COALESCE(carbon_organic_dissolved_doc, ''),
       CASE WHEN nano_microplankton IS NULL OR nano_microplankton ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          nano_microplankton::numeric
       END,
COALESCE(nano_microplankton, ''),
       CASE WHEN downward_par IS NULL OR downward_par ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          downward_par::numeric
       END,
COALESCE(downward_par, ''),

       CASE WHEN conductivity IS NULL OR conductivity ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          conductivity::numeric
       END,
COALESCE(conductivity, ''), 
       CASE WHEN primary_production_isotope_uptake IS NULL OR primary_production_isotope_uptake ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          primary_production_isotope_uptake::numeric
       END,
COALESCE(primary_production_isotope_uptake, ''),
       CASE WHEN primary_production_oxygen IS NULL OR primary_production_oxygen ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          primary_production_oxygen::numeric
       END,
COALESCE(primary_production_oxygen, ''),
       CASE WHEN dissolved_oxygen_concentration IS NULL OR dissolved_oxygen_concentration ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          dissolved_oxygen_concentration::numeric
       END, 
COALESCE(dissolved_oxygen_concentration, ''),
       CASE WHEN nitrogen_organic_particulate_pon IS NULL OR nitrogen_organic_particulate_pon ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          nitrogen_organic_particulate_pon::numeric
       END, 
COALESCE(nitrogen_organic_particulate_pon, ''),
       CASE WHEN meso_macroplankton IS NULL OR meso_macroplankton ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          meso_macroplankton::numeric
       END, 
COALESCE(meso_macroplankton, ''),
       CASE WHEN bacterial_production_isotope_uptake IS NULL OR bacterial_production_isotope_uptake ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          bacterial_production_isotope_uptake::numeric
       END, 
COALESCE(bacterial_production_isotope_uptake, ''),
       CASE WHEN nitrogen_organic_dissolved_don IS NULL OR nitrogen_organic_dissolved_don ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          nitrogen_organic_dissolved_don::numeric
       END, 
COALESCE(nitrogen_organic_dissolved_don, ''),
       CASE WHEN ammonium IS NULL OR ammonium ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          ammonium::numeric
       END, 
COALESCE(ammonium, ''),
       CASE WHEN silicate IS NULL OR silicate ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          silicate::numeric
       END, 
COALESCE(silicate, ''),
       CASE WHEN bacterial_production_respiration IS NULL OR bacterial_production_respiration ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          bacterial_production_respiration::numeric
       END, 
COALESCE(bacterial_production_respiration, ''),
       CASE WHEN turbidity IS NULL OR turbidity ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          turbidity::numeric
       END,
COALESCE(turbidity, ''),
       CASE WHEN fluorescence IS NULL OR fluorescence ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          fluorescence::numeric
       END,
COALESCE(fluorescence, ''),
       CASE WHEN pigment_concentration IS NULL OR pigment_concentration ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          pigment_concentration::numeric
       END,
COALESCE(pigment_concentration, ''),
       CASE WHEN picoplankton_flow_cytometry IS NULL OR picoplankton_flow_cytometry ~ E'^n|t|w' THEN 
         'nan'::numeric
       ELSE
          picoplankton_flow_cytometry::numeric
       END,
COALESCE(picoplankton_flow_cytometry, ''),
       other_params::json

  FROM osdregistry.submission_overview; 


--/*
select osd_id,submission_id,start_lat_verb from samples 
 where local_date = '2014-07-21'::date and local_start between '10:10:00' and '10:16:00';
--*/

UPDATE osdregistry.samples
   SET (start_lat,start_lon,stop_lat,stop_lon,curator,curation_remark) 
     = (trim(start_lat_verb, '+')::numeric, start_lon_verb::numeric,stop_lat_verb::numeric,stop_lon_verb::numeric,'rkottman', 'mass systematic update')
 WHERE start_lat_verb NOT IN ('32.7747','44.6936','66.00691','51.796139','33.55','51.434733','43.22639','59.8822','45.548833','27.02527','43.8604','53.225417','45.314350','-45.7442','54.8333','21.4934','44.6936','41.1416','33.32306','43.63871944444445', '59.6220', '59.89961', '59.81618')
       --AND start_lon_verb NOT IN ('24.99')
       AND local_start != '07:15:00'
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



\echo should be empty by know
select array_agg(submission_id) as ids, 
       array_agg(email) as emails, 
       array_agg(author_position), 
       array_agg(first_name) as first_names, 
        array_agg(last_name) as last_names
  from submission_participants 
group by submission_id, email having count(*) > 1;

\echo mapping institutes to osd sites

INSERT 
  INTO institute_sites (label, osd_id)
SELECT cleantrimtab(institution), substring( osd_id from E'(?i)[OSD ]{3,4}(\\d{1,3})')::integer
  FROM web_r8.osd_samplingsites;


\echo -- add particpants 
INSERT 
  INTO participants (email, first_name, last_name) 
SELECT DISTINCT ON (email)
       email, first_name, last_name
  FROM submission_participants;


--select osd_id,email, institute from submission_participants order by osd_id, author_position;



\echo count of submission participants 
select count(*) as num_participants from submission_participants;


SELECT count(*) as mapped_particpants
  FROM institute_sites i 
       INNER JOIN submission_participants p 
       ON (i.osd_id = p.osd_id);

\echo grouping


CREATE VIEW institute_samplers AS (
 SELECT cleantrimtab(i.label) as label, p.osd_id::integer as osd_id, 
        cleantrimtab(p.institute) as institute, email
   FROM institute_sites i 
        INNER JOIN submission_participants p 
        ON (i.osd_id = p.osd_id)
);


/*
with test AS (
 SELECT osd_id, array_agg(label) as labels, array_agg(email) as emails , array_agg(institute) AS institutes
 FROM institute_samplers 
 group by osd_id, institute
)
SELECT osd_id, 
       labels[1] as labels, 
       emails , array_remove(institutes, labels[1]) AS institutes
  FROM test 
 WHERE osd_id IN (3,4,22,43,51,72,97,105,157,187)
       AND 
       array_length ( array_remove(institutes, labels[1] ), 1) > 0
 order by osd_id
;
--*/

INSERT 
  INTO affiliated (email, institute) 
SELECT DISTINCT ON (email)
       email, label
  FROM institute_samplers
 WHERE osd_id NOT IN (3,4,22,43,72,97,105,157,187)
;


INSERT 
  INTO affiliated (email, institute) 
VALUES ('aklindwo@mpi-bremen.de','Max Planck Institute for Marine Microbiology'),
       ('antje.wichels@awi.de','Biologische Anstalt Helgoland (BAH) - Alfred Wegner Institute (AWI)'),
       ('maripa.tomasino@gmail.com','Institute of Biomembrane and Bioenergetics -CNR, Bari'),
       ('villar@igs.cnrs-mrs.fr','Mediterranean Institute of Oceanography – OSU Pytheas/Centre Nationale Recherche Scientific'),
       ('michel.lafont@univ-amu.fr', 'Aix-Marseille University - MIO'),
       ('gerald.gregori@mio.osupytheas.fr', 'Mediterranean Institute of Oceanography – OSU Pytheas/Centre Nationale Recherche Scientific'),
       ('bertaux@igs.cnrs-mrs.fr','Mediterranean Institute of Oceanography – OSU Pytheas/Centre Nationale Recherche Scientific'),
       ('bpalenik@ucsd.edu','Scripps Institute of Oceanography'),
       ('kelly.goodwin@noaa.gov','National Oceanic and Atmospheric Administration - AOML & SWFSC'),
       ('bbrahamsha@ucsd.edu','Scripps Institute of Oceanography'), 
       ('laluwihare@ucsd.edu','Scripps Institute of Oceanography'), 
       ('maitreyinagarkar@gmail.com','Scripps Institute of Oceanography'), 
       ('efdaniel@ucsd.edu','Scripps Institute of Oceanography'), 
       ('mhilbern@ucsd.edu','Scripps Institute of Oceanography'), 
       ('lzeigler@jcvi.org','J. Craig Venter Institute'),
       ('hbange@geomar.de','University of Kiel, GEOMAR Helmholtz Center for Ocean Research'),
       ('cloescher@ifam.uni-kiel.de','Institute of Microbiology, University of Kiel'),
       ('c.angela.m.loureiro@gmail.com','University of the Azores'),
       ('anamartins@uac.pt','University of the Azores'),
       ('catharina.pieper@gmail.com','University of the Azores'),
       ('bente.edvardsen@ibv.uio.no','Institute of Biology Department of Marine Biology University of Oslo'),
       ('jrcollins@whoi.edu','Woods Hole Oceanographic Institute'),
       ('amaral@mbl.edu','Josephine Bay Paul Center for Comparative Molecular Biology and Evolution Marine Biological Laboratory'),
       ('smv2116@columbia.edu', 'Columbia University'),
       ('hducklow@ldeo.columbia.edu','Columbia University')

;

\echo --inserting authors of samples
INSERT 
  INTO owned_by (
         sample_id,
         email,
         seq_author_order
       )
SELECT   submission_id,
         email,
         author_position
  FROM submission_participants 
;

\echo inserting filters
INSERT 
  INTO filters (
         sample_id,
         num,
         filtration_time_verb,
         quantity_verb,
         container_verb,
         content_verb,
         size_fraction_lower_threshold_verb,
         size_fraction_upper_threshold_verb,
         treatment_chemicals_verb,
         treatment_storage_verb,
         raw
       )
SELECT  submission_id,
        num,
        filtration_time,
        COALESCE ( quantity, '' ),
        COALESCE ( cleantrimtab( container ), '' ),
        COALESCE ( cleantrimtab( content ), '' ),
        COALESCE ( cleantrimtab( size_fraction_lower_threshold ), ''),
        COALESCE ( cleantrimtab( size_fraction_upper_threshold ), ''),
        COALESCE ( cleantrimtab( treatment_chemicals ), '' ),
        COALESCE ( cleantrimtab( treatment_storage ), '' ),
        raw
   FROM osdregistry.submission_filters;

-- select * from filters;

\echo number osd particpanats
-- select email,submission_id from submission_participants group by email,submission_id order by submission_id;

/*
SELECT
       submission_id, author_position  
  FROM submission_participants 
 --WHERE submission_id IN ( 187, 188, 198, 196, 221, 223)
order by submission_id, author_position;
--*/


-- not really needed now

CREATE TABLE site_registrations (
  institute text REFERENCES institutes(label) ON UPDATE CASCADE,
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
SELECT cleantrimtab(institution), substring(id from 4)::integer, 'OSD-Jun-2014', 'infinity' 
  FROM web_r8.osd_participants
--  RETURNING * 
; 


--select * from curation.logged_events;

-- select * from institutes order by label;

CREATE TABLE ena_center_names (
  label text REFERENCES institutes(label) ON UPDATE CASCADE,
  center_name text NOT NULL CHECK ( center_name ~ 'OSD_.*'),
  created timestamp with time zone NOT NULL DEFAULT now()
);

INSERT INTO ena_center_names (label,center_name)
   SELECT DISTINCT ON (label)
          label,
         'OSD_' || label AS center_name FROM osdregistry.institute_sites 
; 


CREATE FUNCTION ena_sample_attribute(k text, v text, unit text )
  RETURNS XML AS $$

  SELECT CASE WHEN v IS NOT NULL AND v <> '' AND lower(v) <> 'nan' THEN
            xmlelement(name "SAMPLE_ATTRIBUTE", 
            xmlelement(name "TAG", k),
            xmlelement(name "VALUE", v),
            CASE WHEN unit IS NOT NULL THEN 
               xmlelement(name "UNITS", unit)
            ELSE
               null
            END 
         )
         ELSE
           NULL
         END
$$ LANGUAGE SQL;


CREATE FUNCTION ena_sample_attribute(k text, v text	)
  RETURNS XML AS $$
  SELECT ena_sample_attribute(k,v,null);
$$ LANGUAGE SQL;



--select ena_sample_attribute('keyyy', 'valllll', 'm');


CREATE VIEW ena_m2b3_sample_xml AS 
   SELECT 
       sam.osd_id,
       xmlelement(name "SAMPLE", 
                    xmlattributes( sam.submission_id || sam.label as "alias",
                                   c.center_name as "center_name"
                                  ),
          xmlelement(name "TITLE", sam.label),
          xmlelement(name "SAMPLE_NAME", 
             xmlelement(name "TAXON_ID", '408172'),
             xmlelement(name "SCIENTIFIC_NAME",  'marine metagenome')
          ),
          xmlelement(name "DESCRIPTION", objective),
          xmlelement(name "SAMPLE_ATTRIBUTES", 
             ena_sample_attribute('ENA-CHECKLIST', 'ERC000027' ),
             ena_sample_attribute('Sampling Campaign', 'OSD-Jun-2014' ),
-- todo add site name 
             ena_sample_attribute('Sampling Site', sam.osd_id || ', TODO: add site name' ),
             ena_sample_attribute('Marine Region', 'TODO' ),
             ena_sample_attribute('Sampling Platform', platform ),
             ena_sample_attribute('Event Date/Time', local_date || 'T' || local_start ),
             ena_sample_attribute('Longitude Start', start_lon::text, 'DD' ),
             ena_sample_attribute('Latitude Start', start_lat::text, 'DD' ),
             ena_sample_attribute('Longitude End', stop_lon::text, 'DD' ),
             ena_sample_attribute('Latitude End', stop_lat::text, 'DD' ),

             ena_sample_attribute('Depth', water_depth::text, 'm' ),
             ena_sample_attribute('Protocol Label', protocol::text ),
             ena_sample_attribute('SAMPLE_Title', sam.label ),
             ena_sample_attribute('Environment (Biome)', biome ),
             ena_sample_attribute('Environment (Feature)', feature ),
             ena_sample_attribute('Environment (Material)', material ),
             ena_sample_attribute('Temperature'::text, water_temperature::text, '°C'::text ),
             ena_sample_attribute('Salinity', salinity::text, 'psu'),

             ena_sample_attribute('Project Name', 'Micro B3' ),
             ena_sample_attribute('Environmental Package', 'water' ),
             ena_sample_attribute('SAMPLING_Objective', objective ),
             ena_sample_attribute('EVENT_Device', device )
             
          )
        ) AS sample

FROM samples sam
     JOIN
     institute_sites i  ON (i.osd_id = sam.osd_id) 
     JOIN
     ena_center_names c ON (c.label =  i.label)

;



rollback;
