
BEGIN;
SELECT _v.register_patch('00129-mass-lifewatch-curation-update',
                          array['00128-osdregistry-sites-update-labels'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

\echo later need water_depth_verb


CREATE OR REPLACE FUNCTION osdregistry.parse_osd_id(
      id text
    )
  RETURNS integer  AS
$BODY$
   select substring( btrim(id), '(?i)[ROSD ]{0,4}(\d+)'::text)::integer;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.parse_osd_id(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_osd_id(text) FROM megxuser,megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.parse_osd_id(text) TO megxuser,megx_team;


CREATE OR REPLACE FUNCTION osdregistry.parse_numeric (
      val text
    )
  RETURNS numeric  AS
  $BODY$
       select trim(val, '+')::numeric;
  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.parse_numeric(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_numeric(text) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_numeric(text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_numeric(text) IS 'Returns a numeric value, throws exception if can not cast to numeric';



CREATE OR REPLACE FUNCTION osdregistry.parse_numeric (
      val text,
      def numeric
    )
  RETURNS numeric  AS
$BODY$
   DECLARE
	err_msg text := '';
   BEGIN
     BEGIN
       -- in case of null return default
       RETURN coalesce ( osdregistry.parse_numeric(val), def) ;
       
       EXCEPTION WHEN invalid_text_representation THEN
         GET STACKED DIAGNOSTICS err_msg = RETURNED_SQLSTATE;
         RAISE LOG 'wrong numeric % and sqlstate=%', val, err_msg;
	 
         RETURN def;
       END;
     RETURN res;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.parse_numeric(text,numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_numeric(text,numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_numeric(text,numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_numeric(text,numeric) IS 'Returns a numeric value, in case it can not cast returns not a number';


CREATE OR REPLACE FUNCTION osdregistry.parse_date (
      val text
    )
  RETURNS date  AS
  $BODY$
    select val::date;
  $BODY$
  LANGUAGE sql IMMUTABLE;
  
ALTER FUNCTION osdregistry.parse_date(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_date(text) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_date(text) IS 'Returns a date value, in case it can not cast throws error';


CREATE OR REPLACE FUNCTION osdregistry.parse_date (
      val text,
      def date
    )
  RETURNS date  AS
$BODY$
   DECLARE
      err_msg text := '';
   BEGIN
     BEGIN
       -- whitespace trimming done by cast method
       
       RETURN coalesce ( osdregistry.parse_date(val), def) ;	
       EXCEPTION WHEN OTHERS THEN
         GET STACKED DIAGNOSTICS err_msg = RETURNED_SQLSTATE;
         RAISE LOG 'wrong date % and sqlstate=%', val, err_msg;
         return res;
       END;
     return res;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE;
  
ALTER FUNCTION osdregistry.parse_date(text,date)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_date(text,date) FROM public;
 GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text,date) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_date(text,date)
     IS 'Returns a date value, in case it can not cast to date returns user suppied default value';


CREATE OR REPLACE FUNCTION osdregistry.parse_local_time (
      val text
    )
  RETURNS time(0)  AS
  $BODY$
    select val::time(0) without time zone;
  $BODY$
  LANGUAGE sql IMMUTABLE;
  
ALTER FUNCTION osdregistry.parse_local_time(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_local_time(text) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_local_time(text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_local_time(text) IS 'Returns a date value, in case it can not cast throws error';


CREATE OR REPLACE FUNCTION osdregistry.parse_local_time (
      val text,
      def time(0)
    )
  RETURNS time  AS
$BODY$
   DECLARE
      err_msg text := '';
   BEGIN
     BEGIN
       
       RETURN coalesce ( osdregistry.parse_local_time(val), def) ;	
       EXCEPTION WHEN OTHERS THEN
         GET STACKED DIAGNOSTICS err_msg = RETURNED_SQLSTATE;
         RAISE LOG 'wrong date % and sqlstate=%', val, err_msg;
         RETURN res;
       END;
     return res;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE;
  
ALTER FUNCTION osdregistry.parse_local_time(text,time)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_local_time(text,time) FROM public;
 GRANT EXECUTE ON FUNCTION osdregistry.parse_local_time(text,time) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_local_time(text,time)
     IS 'Returns a TIME value, in case it can not cast to date returns user suppied default value';





CREATE OR REPLACE FUNCTION osdregistry.parse_envo_term (
      val text
    )
  RETURNS text  AS
  $BODY$
    -- default just what we have later select either on id or name from lookup
    select val;
  $BODY$
  LANGUAGE sql IMMUTABLE;
  
ALTER FUNCTION osdregistry.parse_envo_term(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_envo_term(text) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_envo_term(text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_envo_term(text) IS 'Returns a date value, in case it can not cast throws error';


CREATE OR REPLACE FUNCTION osdregistry.parse_envo_term (
      val text,
      def text
    )
  RETURNS text  AS
$BODY$
   DECLARE
      err_msg text := '';
   BEGIN
     BEGIN
       
       RETURN coalesce ( osdregistry.parse_envo_term(val), def) ;	
       EXCEPTION WHEN OTHERS THEN
         GET STACKED DIAGNOSTICS err_msg = RETURNED_SQLSTATE;
         RAISE LOG 'wrong date % and sqlstate=%', val, err_msg;
         RETURN res;
       END;
     return res;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE;
  
ALTER FUNCTION osdregistry.parse_envo_term(text,text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_envo_term(text,text) FROM public;
 GRANT EXECUTE ON FUNCTION osdregistry.parse_envo_term(text,text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_envo_term(text,text)
     IS 'Returns a TIME value, in case it can not cast to date returns user suppied default value';







CREATE OR REPLACE FUNCTION osdregistry.is_in_range (
      val numeric,
      min numeric,
      max numeric
    )
  RETURNS boolean  AS
$BODY$
     select CASE WHEN val between min AND max
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.is_in_range(numeric,numeric,numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.is_in_range(numeric,numeric,numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.is_in_range(numeric,numeric,numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.is_in_range(numeric,numeric,numeric) IS 'Checks wether latitude and longitude values are within range of WGS84 coordinates';


CREATE OR REPLACE FUNCTION osdregistry.valid_lat_lon (
      lat numeric,
      lon numeric
    )
  RETURNS boolean  AS
$BODY$
     select CASE WHEN (lat between -90 AND 90) AND (lon between -180 AND 180)
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.valid_lat_lon(numeric,numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.valid_lat_lon(numeric,numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.valid_lat_lon(numeric,numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.valid_lat_lon(numeric,numeric) IS 'Checks wether latitude and longitude values are within range of WGS84 coordinates';


CREATE OR REPLACE FUNCTION osdregistry.valid_date (
      val date
    )
  RETURNS boolean  AS
$BODY$
     select CASE WHEN ( val <= now()::date ) AND ( val > '2012-06-01' )
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql volatile
  COST 100;
  ALTER FUNCTION osdregistry.valid_date(date)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.valid_date(date) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.valid_date(date) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.valid_date(date) IS 'Checks wether date is in range of possible OSD dates';


CREATE or REPLACE FUNCTION osdregistry.valid_platform (
  val text
)
  RETURNS boolean  AS
$BODY$
     -- currently allows all kind of text
     select true;
$BODY$
  LANGUAGE sql volatile
  COST 100;
  ALTER FUNCTION osdregistry.valid_platform(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.valid_platform(text) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.valid_platform(text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.valid_platform(text) IS 'Checks wether is in list of valid platforms';


CREATE or REPLACE FUNCTION osdregistry.valid_phosphate (
  val numeric
)
  RETURNS boolean  AS
$BODY$
     -- currently allows all kind of text
     select true;
$BODY$
  LANGUAGE sql volatile
  COST 100;
  ALTER FUNCTION osdregistry.valid_phosphate(numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.valid_phosphate(numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.valid_phosphate(numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.valid_phosphate(numeric) IS 'Checks wether PHOSPHATE is in valid range';


CREATE OR REPLACE FUNCTION osdregistry.valid_ph(
      val numeric
)
  RETURNS boolean  AS
$BODY$
     select CASE WHEN ( val >= 0::numeric ) AND ( val <= 14::numeric )
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql volatile
  COST 100;
  ALTER FUNCTION osdregistry.valid_ph(numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.valid_ph(numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.valid_ph(numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.valid_ph(numeric)
     IS 'Checks wether PH is in acceptable range';


CREATE OR REPLACE FUNCTION osdregistry.valid_water_temperature(
      val numeric
    )
  RETURNS boolean  AS
$BODY$
     select CASE WHEN ( val > -100 ) AND ( val < 1000 )
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql volatile
  COST 100;
  ALTER FUNCTION osdregistry.valid_water_temperature(numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.valid_water_temperature(numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.valid_water_temperature(numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.valid_water_temperature(numeric)
     IS 'Checks wether water TEMPERATURE is in acceptable range';

CREATE OR REPLACE FUNCTION osdregistry.valid_salinity (
      val numeric
    )
  RETURNS boolean  AS
$BODY$
     select CASE WHEN ( val >= 0::numeric ) AND ( val < 80::numeric )
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
  ALTER FUNCTION osdregistry.valid_salinity(numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.valid_salinity(numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.valid_salinity(numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.valid_salinity(numeric)
     IS 'Checks wether SALINITY is in acceptable range';

-- osdregistry.valid_envo_term( term )
CREATE or REPLACE FUNCTION osdregistry.valid_envo_term (
  val text
)
  RETURNS boolean  AS
$BODY$
     -- currently allows all kind of text
     select true;
$BODY$
  LANGUAGE sql volatile
  COST 100;
  ALTER FUNCTION osdregistry.valid_envo_term(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.valid_envo_term(text) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.valid_envo_term(text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.valid_envo_term(text) IS 'Checks wether is in list of valid ENVO term';


-- DROP VIEW osdregistry.submission_overview;

CREATE OR REPLACE VIEW osdregistry.submission_overview AS
 SELECT osd_raw_samples.id AS submission_id,
     osd_raw_samples.submitted,
     osdregistry.parse_osd_id( osd_raw_samples.raw_json #>> '{sampling_site,site_id}'::text[] ) AS osd_id,
     osdregistry.cleantrimtab(osd_raw_samples.raw_json #>> '{sampling_site,site_name}'::text[]) AS site_name,
     osd_raw_samples.version,
     osd_raw_samples.raw_json #>> '{sampling_site,marine_region}'::text[] AS marine_region,
     CASE WHEN osd_raw_samples.version in (6,7) THEN ltrim(osd_raw_samples.raw_json #>> '{sampling_site,start_coordinates,latitude}'::text[], '+0'::text)
          ELSE ltrim(osd_raw_samples.raw_json #>> '{sampling_site,latitude}'::text[], '+0'::text)
     END AS start_lat,
     CASE WHEN osd_raw_samples.version in (6,7) THEN ltrim(osd_raw_samples.raw_json #>> '{sampling_site,start_coordinates,longitude}'::text[], '+0'::text)
          ELSE ltrim(osd_raw_samples.raw_json #>> '{sampling_site,longitude}'::text[], '+0'::text)
     END AS start_lon,
     CASE WHEN osd_raw_samples.version in (6,7) THEN ltrim(osd_raw_samples.raw_json #>> '{sampling_site,stop_coordinates,latitude}'::text[], '+0'::text)
          ELSE ltrim(osd_raw_samples.raw_json #>> '{sampling_site,latitude}'::text[], '+0'::text)
     END AS stop_lat,
     CASE WHEN osd_raw_samples.version in (6,7) THEN ltrim(osd_raw_samples.raw_json #>> '{sampling_site,stop_coordinates,longitude}'::text[], '+0'::text)
          ELSE ltrim(osd_raw_samples.raw_json #>> '{sampling_site,longitude}'::text[], '+0'::text)
     END AS stop_lon,
     osd_raw_samples.raw_json #>> '{sample,start_time}'::text[] AS sample_start_time,
     osd_raw_samples.raw_json #>> '{sample,end_time}'::text[] AS sample_end_time,
     osdregistry.cleantrimtab(osd_raw_samples.raw_json #>> '{sample,label}'::text[]) AS sample_label,
     btrim(osd_raw_samples.raw_json #>> '{sample,protocol_label}'::text[]) AS sample_protocol,
     osdregistry.cleantrimtab(osd_raw_samples.raw_json #>> '{sampling_site,objective}'::text[]) AS objective,
     osdregistry.cleantrimtab(osd_raw_samples.raw_json #>> '{sampling_site,platform}'::text[]) AS platform,
     osdregistry.cleantrimtab(osd_raw_samples.raw_json #>> '{sampling_site,device}'::text[]) AS device,
     COALESCE(osd_raw_samples.raw_json #>> '{sample,depth}'::text[], 'nan'::text) AS sample_depth,
     osd_raw_samples.raw_json #>> '{sample,date}'::text[] AS sample_date,
     osd_raw_samples.raw_json #>> '{sample,description}'::text[] AS sample_description,
     btrim(osd_raw_samples.raw_json #>> '{contact,first_name}'::text[]) AS first_name,
     btrim(osd_raw_samples.raw_json #>> '{contact,last_name}'::text[]) AS last_name,
     btrim(osd_raw_samples.raw_json #>> '{contact,institute}'::text[]) AS institute,
     osd_raw_samples.raw_json #>> '{contact,email}'::text[] AS email,
     (osd_raw_samples.raw_json #>> '{investigators}'::text[])::json AS investigators,
     (osd_raw_samples.raw_json -> 'environment'::text) ->> 'water_temperature'::text AS water_temperature,
     ((osd_raw_samples.raw_json -> 'environment'::text) ->> 'salinity'::text)::numeric AS salinity,
     (osd_raw_samples.raw_json -> 'environment'::text) ->> 'biome'::text AS biome,
     (osd_raw_samples.raw_json -> 'environment'::text) ->> 'feature'::text AS feature,
     (osd_raw_samples.raw_json -> 'environment'::text) ->> 'material'::text AS material,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,ph,choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,ph,measurement,value}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,ph,choice}'::text[]
         END AS ph,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,phosphate,choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,phosphate,measurement,value}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,phosphate,choice}'::text[]
         END AS phosphate,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,nitrate,nitrate-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,nitrate,nitrate-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,nitrate,nitrate-choice}'::text[]
         END AS nitrate,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-choice}'::text[]
         END AS carbon_organic_particulate,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,nitrite,nitrite-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,nitrite,nitrite-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,nitrite,nitrite-choice}'::text[]
         END AS nitrite,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-choice}'::text[]
         END AS carbon_organic_dissolved_doc,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,nano_microplankton,nano_microplankton-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,nano_microplankton,nano_microplankton-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,nano_microplankton,nano_microplankton-choice}'::text[]
         END AS nano_microplankton,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,downward_par,downward_par-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,downward_par,downward_par-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,downward_par,downward_par-choice}'::text[]
         END AS downward_par,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,conductivity,conductivity-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,conductivity,conductivity-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,conductivity,conductivity-choice}'::text[]
         END AS conductivity,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-choice}'::text[]
         END AS primary_production_isotope_uptake,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,primary_production_oxygen,primary_production_oxygen-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,primary_production_oxygen,primary_production_oxygen-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,primary_production_oxygen,primary_production_oxygen-choice}'::text[]
         END AS primary_production_oxygen,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-choice}'::text[]
         END AS dissolved_oxygen_concentration,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-choice}'::text[]
         END AS nitrogen_organic_particulate_pon,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,meso_macroplankton,meso_macroplankton-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,meso_macroplankton,meso_macroplankton-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,meso_macroplankton,meso_macroplankton-choice}'::text[]
         END AS meso_macroplankton,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-choice}'::text[]
         END AS bacterial_production_isotope_uptake,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-choice}'::text[]
         END AS nitrogen_organic_dissolved_don,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,ammonium,ammonium-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,ammonium,ammonium-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,ammonium,ammonium-choice}'::text[]
         END AS ammonium,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,silicate,silicate-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,silicate,silicate-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,silicate,silicate-choice}'::text[]
         END AS silicate,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-choice}'::text[]
         END AS bacterial_production_respiration,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,turbidity,turbidity-choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,turbidity,turbidity-measurement}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,turbidity,turbidity-choice}'::text[]
         END AS turbidity,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,fluorescence,choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,fluorescence,measurement,value}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,fluorescence,choice}'::text[]
         END AS fluorescence,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,pigment_concentration,choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,pigment_concentration,measurement,value}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,pigment_concentration,choice}'::text[]
         END AS pigment_concentration,
         CASE
             WHEN (osd_raw_samples.raw_json #>> '{environment,picoplankton_flow_cytometry,choice}'::text[]) = 'measured'::text THEN osd_raw_samples.raw_json #>> '{environment,picoplankton_flow_cytometry,measurement,value}'::text[]
                 ELSE osd_raw_samples.raw_json #>> '{environment,picoplankton_flow_cytometry,choice}'::text[]
         END AS picoplankton_flow_cytometry,
     COALESCE((osd_raw_samples.raw_json -> 'environment'::text) ->> 'other_parameters'::text, '{"param":"not determined"}'::text)::json AS other_params,
         osd_raw_samples.raw_json -> 'comment'::text AS remarks,
     (osd_raw_samples.raw_json #>> '{sample,filters}'::text[])::json AS filters,
         osd_raw_samples.raw_json
    FROM osdregistry.osd_raw_samples
      WHERE (osd_raw_samples.raw_json ->> 'version'::text) in ('5','6','7')
        ORDER BY osdregistry.parse_osd_id( osd_raw_samples.raw_json #>> '{sampling_site,site_id}'::text[] ) DESC;

ALTER TABLE osdregistry.submission_overview
  OWNER TO megdb_admin;
  REVOKE ALL ON TABLE osdregistry.submission_overview FROM public;
  GRANT ALL ON TABLE osdregistry.submission_overview TO megdb_admin;
  GRANT SELECT ON TABLE osdregistry.submission_overview TO megx_team WITH GRANT OPTION;
  GRANT SELECT ON TABLE osdregistry.submission_overview TO abryan;
  

ALTER TABLE osdregistry.samples ADD COLUMN water_depth_verb text NOT NULL DEFAULT ''::text;
UPDATE osdregistry.samples SET water_depth_verb = water_depth;

ALTER TABLE osdregistry.samples ADD COLUMN salinity_verb text NOT NULL DEFAULT ''::text;
UPDATE osdregistry.samples SET salinity_verb = salinity;

ALTER TABLE osdregistry.samples ADD COLUMN water_temperature_verb text NOT NULL DEFAULT ''::text;
UPDATE osdregistry.samples SET water_temperature_verb = water_temperature;

ALTER TABLE osdregistry.samples ADD COLUMN biome_verb text NOT NULL DEFAULT ''::text;
UPDATE osdregistry.samples SET biome_verb = biome;

ALTER TABLE osdregistry.samples ADD COLUMN feature_verb text NOT NULL DEFAULT ''::text;
UPDATE osdregistry.samples SET feature_verb = feature;

ALTER TABLE osdregistry.samples ADD COLUMN material_verb text NOT NULL DEFAULT ''::text;
UPDATE osdregistry.samples SET material_verb = material;

CREATE TYPE osdregistry.sample_submission AS (

  submission_id integer,
  submitted timestamp with time zone,
  osd_id integer, 
  site_name text, 
  version integer, 
  marine_region text, 
  start_lat text, 
  start_lon text, 
  stop_lat text, 
  stop_lon text, 
  sample_start_time text, 
  sample_end_time text, 
  sample_label text,
  sample_protocol text,
  objective text,
  platform TEXT,
  device TEXT,
  sample_depth TEXT,
  sample_date TEXT,
  sample_description TEXT,
  first_name TEXT,
  last_name TEXT,
  institute TEXT,
  email TEXT,
  investigators json,  
  water_temperature TEXT,
  salinity numeric,
  biome TEXT,
  feature TEXT,
  material TEXT,
  ph TEXT,
  phosphate TEXT,
  nitrate TEXT,
  carbon_organic_particulate TEXT,
  nitrite TEXT,
  carbon_organic_dissolved_doc TEXT,
  nano_microplankton TEXT,
  downward_par TEXT,
  conductivity TEXT,
  primary_production_isotope_uptake TEXT,
  primary_production_oxygen TEXT,
  dissolved_oxygen_concentration TEXT,
  nitrogen_organic_particulate_pon TEXT,
  meso_macroplankton TEXT,
  bacterial_production_isotope_uptake TEXT,
  nitrogen_organic_dissolved_don TEXT,
  ammonium TEXT,
  silicate TEXT,
  bacterial_production_respiration TEXT,
  turbidity TEXT,
  fluorescence TEXT,
  pigment_concentration TEXT,
  picoplankton_flow_cytometry TEXT,
  other_params json, 
  remarks json,
  filters json, 
  json json
);



CREATE OR REPLACE FUNCTION osdregistry.parse_sample_submission(
    sample json, 
    id integer,
    vers integer,
    submitted timestamp with time zone default 'infinity', 
    modified timestamp with time zone default 'infinity')
  RETURNS osdregistry.sample_submission AS
$BODY$
  DECLARE   
    sub osdregistry.sample_submission;

  BEGIN
    sub :=
    (id, 
    submitted,
    osdregistry.parse_osd_id( sample #>> '{sampling_site,site_id}'::text[] ),
    osdregistry.cleantrimtab(sample #>> '{sampling_site,site_name}') , 
    vers, 
    sample #>> '{sampling_site,marine_region}' , 
        CASE
            WHEN vers  in (6,7) THEN ltrim(sample #>> '{sampling_site,start_coordinates,latitude}', '+0'::text)
            ELSE ltrim(sample #>> '{sampling_site,latitude}', '+0'::text)
        END , 
        CASE
            WHEN vers  in (6,7) THEN ltrim(sample #>> '{sampling_site,start_coordinates,longitude}', '+0'::text)
            ELSE ltrim(sample #>> '{sampling_site,longitude}', '+0'::text)
        END , 
        CASE
            WHEN vers  in (6,7) THEN ltrim(sample #>> '{sampling_site,stop_coordinates,latitude}', '+0'::text)
            ELSE ltrim(sample #>> '{sampling_site,latitude}', '+0'::text)
        END , 
        CASE
            WHEN vers  in (6,7) THEN ltrim(sample #>> '{sampling_site,stop_coordinates,longitude}', '+0'::text)
            ELSE ltrim(sample #>> '{sampling_site,longitude}', '+0'::text)
        END , 
    sample #>> '{sample,start_time}' , 
    sample #>> '{sample,end_time}' , 
    osdregistry.cleantrimtab(sample #>> '{sample,label}') , 
    btrim(sample #>> '{sample,protocol_label}') , 
    osdregistry.cleantrimtab(sample #>> '{sampling_site,objective}') , 
    osdregistry.cleantrimtab(sample #>> '{sampling_site,platform}') , 
    osdregistry.cleantrimtab(sample #>> '{sampling_site,device}') , 
    COALESCE(sample #>> '{sample,depth}', 'nan'::text) , 
    sample #>> '{sample,date}' , 
    sample #>> '{sample,description}' , 
    btrim(sample #>> '{contact,first_name}') , 
    btrim(sample #>> '{contact,last_name}') , 
    btrim(sample #>> '{contact,institute}') , 
    sample #>> '{contact,email}' , 
    (sample #>> '{investigators}')::json , 
    (sample -> 'environment'::text) ->> 'water_temperature'::text , 
    ((sample -> 'environment'::text) ->> 'salinity'::text)::numeric , 
    (sample -> 'environment'::text) ->> 'biome'::text , 
    (sample -> 'environment'::text) ->> 'feature'::text , 
    (sample -> 'environment'::text) ->> 'material'::text , 
        CASE
            WHEN (sample #>> '{environment,ph,choice}') = 'measured'::text THEN sample #>> '{environment,ph,measurement,value}'
            ELSE sample #>> '{environment,ph,choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,phosphate,choice}') = 'measured'::text THEN sample #>> '{environment,phosphate,measurement,value}'
            ELSE sample #>> '{environment,phosphate,choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrate,nitrate-choice}') = 'measured'::text THEN sample #>> '{environment,nitrate,nitrate-measurement}'
            ELSE sample #>> '{environment,nitrate,nitrate-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-choice}') = 'measured'::text THEN sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-measurement}'
            ELSE sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrite,nitrite-choice}') = 'measured'::text THEN sample #>> '{environment,nitrite,nitrite-measurement}'
            ELSE sample #>> '{environment,nitrite,nitrite-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-choice}') = 'measured'::text THEN sample #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-measurement}'
            ELSE sample #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nano_microplankton,nano_microplankton-choice}') = 'measured'::text THEN sample #>> '{environment,nano_microplankton,nano_microplankton-measurement}'
            ELSE sample #>> '{environment,nano_microplankton,nano_microplankton-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,downward_par,downward_par-choice}') = 'measured'::text THEN sample #>> '{environment,downward_par,downward_par-measurement}'
            ELSE sample #>> '{environment,downward_par,downward_par-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,conductivity,conductivity-choice}') = 'measured'::text THEN sample #>> '{environment,conductivity,conductivity-measurement}'
            ELSE sample #>> '{environment,conductivity,conductivity-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-choice}') = 'measured'::text THEN sample #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-measurement}'
            ELSE sample #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,primary_production_oxygen,primary_production_oxygen-choice}') = 'measured'::text THEN sample #>> '{environment,primary_production_oxygen,primary_production_oxygen-measurement}'
            ELSE sample #>> '{environment,primary_production_oxygen,primary_production_oxygen-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-choice}') = 'measured'::text THEN sample #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-measurement}'
            ELSE sample #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-choice}') = 'measured'::text THEN sample #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-measurement}'
            ELSE sample #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,meso_macroplankton,meso_macroplankton-choice}') = 'measured'::text THEN sample #>> '{environment,meso_macroplankton,meso_macroplankton-measurement}'
            ELSE sample #>> '{environment,meso_macroplankton,meso_macroplankton-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-choice}') = 'measured'::text THEN sample #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-measurement}'
            ELSE sample #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-choice}') = 'measured'::text THEN sample #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-measurement}'
            ELSE sample #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,ammonium,ammonium-choice}') = 'measured'::text THEN sample #>> '{environment,ammonium,ammonium-measurement}'
            ELSE sample #>> '{environment,ammonium,ammonium-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,silicate,silicate-choice}') = 'measured'::text THEN sample #>> '{environment,silicate,silicate-measurement}'
            ELSE sample #>> '{environment,silicate,silicate-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-choice}') = 'measured'::text THEN sample #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-measurement}'
            ELSE sample #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,turbidity,turbidity-choice}') = 'measured'::text THEN sample #>> '{environment,turbidity,turbidity-measurement}'
            ELSE sample #>> '{environment,turbidity,turbidity-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,fluorescence,choice}') = 'measured'::text THEN sample #>> '{environment,fluorescence,measurement,value}'
            ELSE sample #>> '{environment,fluorescence,choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,pigment_concentration,choice}') = 'measured'::text THEN sample #>> '{environment,pigment_concentration,measurement,value}'
            ELSE sample #>> '{environment,pigment_concentration,choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,picoplankton_flow_cytometry,choice}') = 'measured'::text THEN sample #>> '{environment,picoplankton_flow_cytometry,measurement,value}'
            ELSE sample #>> '{environment,picoplankton_flow_cytometry,choice}'
        END , 
    COALESCE((sample -> 'environment'::text) ->> 'other_parameters'::text, '{"param":"not determined"}')::json , 
    sample -> 'comment', 
    (sample #>> '{sample,filters}')::json , 
    sample);

     return sub;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.parse_sample_submission(json, integer,integer, timestamp with time zone, timestamp with time zone)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer,integer, timestamp with time zone, timestamp with time zone) TO megxuser,megx_team;



CREATE OR REPLACE FUNCTION osdregistry.parse_sample_submission(sample osdregistry.osd_raw_samples)
  RETURNS osdregistry.sample_submission AS
$BODY$
   select osdregistry.parse_sample_submission(sample.raw_json, sample.id, sample.version, sample.submitted, sample.modified);
  
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.parse_sample_submission(sample osdregistry.osd_raw_samples)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(sample osdregistry.osd_raw_samples) TO megxuser,megx_team;



--/* just testing the parse function
select (osdregistry.parse_sample_submission( s.* )).* from osdregistry.osd_raw_samples s 
  where s.id = 200 
  union all

  select * from osdregistry.submission_overview where submission_id = 200;
--*/


create view osdregistry.submissions_new AS 
  select r.* 
    from osdregistry.osd_raw_samples r
    LEFT JOIN osdregistry.samples s on (s.submission_id = r.id) 
   where s.submission_id is null;

select id as submitted_since_osd2015 from osdregistry.osd_raw_samples where submitted > '2015-06-21';


select count(*) as new_samples_since_2014 from osdregistry.submissions_new sub where sub.id > (select max(submission_id) from osdregistry.samples);


select count(*) as non_integrated_samples from osdregistry.submissions_new sub where sub.id < (select max(submission_id) from osdregistry.samples);

select count(*) as non_integrated_samples from osdregistry.submissions_new sub;


select 'prepare new structure to keep dleted raw submission but remove from main submission table';


CREATE TABLE osdregistry.osd_raw_removed_samples
(
  removed timestamp with time zone NOT NULL DEFAULT now(),
  by_user text NOT NUll,
  id serial primary key,
  submitted timestamp with time zone NOT NULL,
  modified timestamp with time zone NOT NULL,
  raw_json json NOT NULL,
  version integer CHECK (version > 0)
);

ALTER TABLE osdregistry.osd_raw_removed_samples
  OWNER TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.osd_raw_samples TO megx_team;


CREATE OR REPLACE FUNCTION osdregistry.remove_raw_sample() RETURNS TRIGGER AS $emp_audit$
    BEGIN
        --
        -- Create a row in emp_audit to reflect the operation performed on emp,
        -- make use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO osdregistry.osd_raw_removed_samples SELECT now(), USER, OLD.*;
            RETURN OLD;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$emp_audit$ LANGUAGE plpgsql;

select 'hello';


CREATE TRIGGER remove_raw_sample_trigger_row
  AFTER DELETE
  ON osdregistry.osd_raw_samples
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.remove_raw_sample();


select 'now wanna delete all non-integrated submissions';


DELETE FROM osdregistry.osd_raw_samples as sam
 USING osdregistry.submissions_new as sub
 WHERE sam.id = sub.id and sub.id < (select max(submission_id) from osdregistry.samples);

DELETE FROM osdregistry.osd_raw_samples as sam where sam.id in ( 270, 271, 275, 278 );


SELECT count(*) as non_integrated_samples from osdregistry.submissions_new sub
 WHERE sub.id < (select max(submission_id) from osdregistry.samples);


SELECT * FROM osdregistry.osd_raw_removed_samples limit 1;

SELECT count(*) from osdregistry.osd_raw_removed_samples;
   

SELECT count(*) as non_integrated_samples from osdregistry.submissions_new sub;

/*
with parsed as (
 select  (osdregistry.parse_sample_submission(sub.raw_json, sub.id, sub.version, sub.submitted, sub.modified)).* 
   from osdregistry.submissions_new sub
)
select * from parsed where parsed.sample_protocol = 'NE08';
--*/
DROP FUNCTION IF EXISTS osdregistry.integrate_sample_submission(text);
DROP FUNCTION IF EXISTS osdregistry.integrate_sample_submission(json);


set local client_min_messages to debug;


-- start geos

CREATE OR REPLACE FUNCTION osdregistry.attempt_georef() RETURNS TRIGGER AS $trg$
       DECLARE
	lat numeric;
	lon numeric;
	water_depth numeric;
	local_date date;
	local_start time(0);
	local_end time(0);
	tz text;
       BEGIN
       --
       -- Attempt to insert value into curated column from verbatim column.
       -- Hence this trigger is only defined to work on insert
       --
       RAISE NOTICE 'start lat lon trigger fired';
       IF (TG_OP != 'INSERT') THEN
       	  -- just doing nothing
           RETURN NEW;
       END IF;
       -- now depth parsed from verbatim or simply the current unchanged defaults
       water_depth := osdregistry.parse_numeric( NEW.water_depth_verb, NEW.water_depth );
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.is_in_range(water_depth, 0::numeric, 12000::numeric  ) THEN
       	  NEW.water_depth := water_depth;
       END IF;

       -- now local date parsed from verbatim or simply the current unchanged defaults
       local_date :=  osdregistry.parse_date( NEW.local_date_verb, NEW.local_date ) ;
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_date( local_date ) THEN
       	  NEW.local_date := local_date;
       END IF;

       RAISE NOTICE 'verb times: % and % ', NEW.local_start_verb, NEw.local_end_verb;
       
       local_start :=  osdregistry.parse_local_time( NEW.local_start_verb, NEW.local_start::time without time zone ) ;
       local_end :=  osdregistry.parse_local_time( NEW.local_end_verb, NEW.local_end::time without time zone) ;



       -- now lat/lon are either parsed from verbatim or simply the current unchanged defaults
       lat := osdregistry.parse_numeric( NEW.start_lat_verb, NEW.start_lat );
       lon := osdregistry.parse_numeric( NEW.start_lon_verb, NEW.start_lon );
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_lat_lon( lat, lon ) THEN
       	  NEW.start_lat := lat;
       	  NEW.start_lon := lon;
	  SELECT CASE WHEN time_zone = 'UTC±00:00'
                      THEN '+00:00'
                      ELSE substring(time_zone from 4)
		 END
  	    INTO STRICT tz
	    FROM elayers.world_time_zones tz
  	   WHERE ( ST_intersects (
	             ST_geometryFromText('POINT(' || NEW.start_lon || ' ' || NEW.start_lat ||')', 4326 ),
		     tz.geom)
		 );
           NEW.local_start := (local_start || tz)::time(0) with time zone;
           NEW.local_end := (local_end || tz)::time(0) with time zone;

       END IF;

       RETURN NEW; 
    END;
$trg$ LANGUAGE plpgsql;

CREATE TRIGGER attempt_georef_on_insert
  BEFORE INSERT
  ON osdregistry.samples
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.attempt_georef();

-- stop geo

CREATE OR REPLACE FUNCTION osdregistry.attempt_stop_lat_lon() RETURNS TRIGGER AS $trg$
       DECLARE
	lat numeric;
	lon numeric;
       BEGIN
       --
       -- Attempt to insert value into curated column from verbatim column.
       -- Hence this trigger is only defined to work on insert
       --
       IF (TG_OP != 'INSERT') THEN
       	  -- just doing nothing
           RETURN NEW;
       END IF;
       -- now lat/lon are either parsed from verbatim or simply the current unchanged defaults
       lat := osdregistry.parse_numeric( NEW.stop_lat_verb, NEW.stop_lat );
       lon := osdregistry.parse_numeric( NEW.stop_lon_verb, NEW.stop_lon );
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_lat_lon( lat, lon ) THEN
       	  NEW.stop_lat := lat;
       	  NEW.stop_lon := lon;
       END IF;

       RETURN NEW; 
    END;
$trg$ LANGUAGE plpgsql;

CREATE TRIGGER attempt_stop_lat_lon_on_insert
  BEFORE INSERT
  ON osdregistry.samples
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.attempt_stop_lat_lon();

-- attempt platform


CREATE OR REPLACE FUNCTION osdregistry.attempt_platform() RETURNS TRIGGER AS $trg$
       DECLARE
	platform text;
       BEGIN
       --
       -- Attempt to insert value into curated column from verbatim column.
       -- Hence this trigger is only defined to work on insert
       --
       IF (TG_OP != 'INSERT') THEN
       	  -- just doing nothing
           RETURN NEW;
       END IF;
       -- now local date parsed from verbatim or simply the current unchanged defaults
       platform :=  osdregistry.cleantrimtab( NEW.platform_verb ) ;
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_platform( platform ) THEN
       	  NEW.platform := platform;
       END IF;

       RETURN NEW; 
    END;
$trg$ LANGUAGE plpgsql;

CREATE TRIGGER attempt_platform
  BEFORE INSERT
  ON osdregistry.samples
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.attempt_platform();
 
CREATE OR REPLACE FUNCTION osdregistry.attempt_mandatory_parameters() RETURNS TRIGGER AS $trg$
       DECLARE
	param numeric;
	term text;
       BEGIN
       --
       -- Attempt to insert value into curated column from verbatim column.
       -- Hence this trigger is only defined to work on insert
       --
       IF (TG_OP != 'INSERT') THEN
       	  -- just doing nothing
           RETURN NEW;
       END IF;
       -- WATER TEMPERATURE date parsed from verbatim or simply the current unchanged defaults
       param :=  osdregistry.parse_numeric( NEW.water_temperature_verb, NEW.water_temperature );

       IF osdregistry.valid_water_temperature( param ) THEN
       	  NEW.water_temperature := param;
       END IF;
       -- SALINITY
       param :=  osdregistry.parse_numeric( NEW.salinity_verb, NEW.salinity );
       IF osdregistry.valid_salinity( param ) THEN
       	  NEW.salinity := param;
       END IF;

       -- BIOME
       term :=  osdregistry.parse_envo_term( NEW.biome_verb, NEW.biome );
       IF osdregistry.valid_envo_term( term ) THEN
       	  NEW.biome := term;
       END IF;

       -- FEATURE
       term :=  osdregistry.parse_envo_term( NEW.feature_verb, NEW.feature );
       IF osdregistry.valid_envo_term( term ) THEN
       	  NEW.feature := term;
       END IF;
       -- MATERIAL
       term :=  osdregistry.parse_envo_term( NEW.material_verb, NEW.material );
       IF osdregistry.valid_envo_term( term ) THEN
       	  NEW.material := term;
       END IF;


       RETURN NEW; 
    END;
$trg$ LANGUAGE plpgsql;

CREATE TRIGGER attempt_mandatory_parameters
  BEFORE INSERT
  ON osdregistry.samples
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.attempt_mandatory_parameters();


CREATE OR REPLACE FUNCTION osdregistry.attempt_optional_parameters() RETURNS TRIGGER AS $trg$
       DECLARE
	param numeric;
       BEGIN
       --
       -- Attempt to insert value into curated column from verbatim column.
       -- Hence this trigger is only defined to work on insert
       --
       IF (TG_OP != 'INSERT') THEN
       	  -- just doing nothing
           RETURN NEW;
       END IF;
       -- PH now local date parsed from verbatim or simply the current unchanged defaults
       param :=  osdregistry.parse_numeric( NEW.ph_verb, NEW.ph);
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_ph( param ) THEN
       	  NEW.ph := param;
       END IF;

       -- PHOSPHATE
       param :=  osdregistry.parse_numeric( NEW.phosphate_verb, NEW.phosphate);
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_phosphate( param ) THEN
       	  NEW.phosphate := param;
       END IF;

       RETURN NEW; 
    END;
$trg$ LANGUAGE plpgsql;

CREATE TRIGGER attempt_optional_parameters
  BEFORE INSERT
  ON osdregistry.samples
  FOR EACH ROW
  EXECUTE PROCEDURE osdregistry.attempt_optional_parameters();




-- attempt local start time



CREATE OR REPLACE FUNCTION osdregistry.integrate_sample_submission(sample osdregistry.sample_submission)
  RETURNS integer AS
$BODY$
  DECLARE   
    f_curation_remark text := 'integration update';
    f_curator text := 'rkottman';
    i record;
  BEGIN
   INSERT INTO osdregistry.samples (
       submission_id,
       osd_id,
       label_verb,

       start_lat_verb, start_lon_verb,
       stop_lat_verb, stop_lon_verb,

       water_depth_verb,

       local_date_verb, local_start_verb, local_end_verb,

       protocol, objective, platform, device, description,

       water_temperature_verb, salinity_verb, biome_verb, feature_verb, material_verb,

       ph_verb,
       phosphate_verb,
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
       picoplankton_flow_cytometry_verb,
       remarks,
       other_params,
       raw
   ) VALUES (
     sample.submission_id,
     sample.osd_id,
     sample.sample_label,
  
     sample.start_lat, sample.start_lon,
     sample.stop_lat,  sample.stop_lon,

     sample.sample_depth,

     sample.sample_date,sample.sample_start_time, sample.sample_end_time,
  
     sample.sample_protocol, sample.objective, sample.platform, sample.device, sample.sample_description,
     COALESCE (sample.water_temperature::numeric, 'nan'::numeric),
     COALESCE (sample.salinity, 'nan'::numeric ),
     
     sample.biome,  sample.feature,  sample.material,
     sample.ph,
     sample.phosphate,
     sample.nitrate,
     sample.carbon_organic_particulate,
     sample.nitrite,
     sample.carbon_organic_dissolved_doc,
     sample.nano_microplankton,
     sample.downward_par,
     sample.conductivity,
     sample.primary_production_isotope_uptake,
     sample.primary_production_oxygen,
     sample.dissolved_oxygen_concentration,
     sample.nitrogen_organic_particulate_pon,
     sample.meso_macroplankton,
     sample.bacterial_production_isotope_uptake,
     sample.nitrogen_organic_dissolved_don,
     sample.ammonium,
     sample.silicate,
     sample.bacterial_production_respiration,
     sample.turbidity,
     sample.fluorescence,
     sample.pigment_concentration,
     coalesce( sample.picoplankton_flow_cytometry, '' ),
     coalesce( sample.json -> 'comment'::text, '{}'::json), 
     sample.other_params, 
     sample.json
   );
   
   INSERT INTO osdregistry.filters (
          sample_id,
          num,
	  filtration_time, filtration_time_verb,
	  quantity,quantity_verb,
	  container, container_verb,
	  content, content_verb,
	  size_fraction_lower_threshold, size_fraction_lower_threshold_verb,
	  size_fraction_upper_threshold, size_fraction_upper_threshold_verb,
	  treatment_chemicals, treatment_chemicals_verb,
	  treatment_storage, treatment_storage_verb,
	  curator, curation_remark, "raw")
   SELECT sample.submission_id,
          row_number() OVER()  AS num,
	  (s.filter ->> 'filtration_time')::interval minute AS filtration_time,
	  s.filter ->> 'filtration_time' AS filtration_time_verb,
	  (s.filter ->> 'quantity')::numeric AS quantity,
          s.filter ->> 'quantity' AS quantity_verb,
	  s.filter ->> 'container' AS container,
  	  s.filter ->> 'container' AS container_verb,
	  s.filter ->> 'content' AS content,
  	  s.filter ->> 'content' AS content_verb,
	  (s.filter ->> 'size-fraction_lower-threshold')::numeric AS s_frac_low_thres,
  	  s.filter ->> 'size-fraction_lower-threshold' AS s_frac_low_thres_verb,
	  (s.filter ->> 'size-fraction_upper-threshold')::numeric AS s_frac_up_thres,
          s.filter ->> 'size-fraction_upper-threshold' AS s_frac_up_thres_verb,
	  s.filter ->> 'treatment_chemicals' AS treatment_chemicals,
  	  s.filter ->> 'treatment_chemicals' AS treatment_chemicals_verb,
	  s.filter ->> 'treatment_storage' AS treatment_storage,
  	  s.filter ->> 'treatment_storage' AS treatment_storage_verb,
          f_curator,
          f_curation_remark, 
	  s.filter AS raw
     FROM json_array_elements( sample.json #> '{sample,filters}' ) as  s(filter);
   
    return sample.submission_id;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.integrate_sample_submission(sample osdregistry.sample_submission)
  OWNER TO megdb_admin;
REVOKE EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(sample osdregistry.sample_submission) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(sample osdregistry.sample_submission) TO megdb_admin;

\echo testing integrate submission func


set local client_min_messages to notice;


select (osdregistry.parse_sample_submission(
                  sub.raw_json, 
                  sub.id, 
                  sub.version, 
                  sub.submitted, 
                  sub.modified
            )).*
         from osdregistry.submissions_new sub where id in (288,289);



select osdregistry.integrate_sample_submission( 
            osdregistry.parse_sample_submission(
                  sub.raw_json, 
                  sub.id, 
                  sub.version, 
                  sub.submitted, 
                  sub.modified
            )
        ) from osdregistry.submissions_new sub where sub.raw_json #>> '{sample,protocol_label}' = 'NE08';




update osdregistry.samples
   set water_depth = 0,
       curator = 'rkottman',
       curation_remark = 'inferred from log sheet and comments'
 where submission_id in (292,276,288,289);

SELECT s.osd_id, submission_id
/*,
       water_depth, water_depth_verb,
       osdregistry.osd_sample_label ( osd_id::text, local_date::text, water_depth::text, protocol ) as label,
       start_lat, start_lat_verb,
       start_lon, start_lon_verb,

       stop_lat,stop_lat_verb,
       stop_lon,stop_lon_verb,
       local_date, local_date_verb,
       local_start, local_start_verb,
       local_end, local_end_verb,
       platform, platform_verb,
       water_temperature, water_temperature_verb,
       salinity, salinity_verb,
       biome, biome_verb,feature, feature_verb, material, material_verb,
       ph, ph_verb,
       phosphate, phosphate_verb
--*/
  FROM osdregistry.samples s
       inner join
       osdregistry.osd_raw_samples n
       on (s.submission_id = n.id AND n.submitted > '2015-06-04')
 WHERE protocol = 'NE08' and local_date > '2014-06-01' order by osd_id;

SELECT s.osd_id,f.sample_id 
  FROM osdregistry.samples s
       inner join
       osdregistry.filters f
       ON (s.submission_id = f.sample_id)
 WHERE protocol = 'NE08' and local_date > '2014-06-01' order by osd_id;


commit;       


