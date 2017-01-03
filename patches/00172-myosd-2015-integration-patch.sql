
BEGIN;
SELECT _v.register_patch('00172-myosd-2015-integration-patch',
                          array['00171-myosd-enhance-sample-table-patch'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

ALTER TABLE myosd.filters DROP CONSTRAINT filters_num_check;

ALTER TABLE myosd.filters
  ADD CONSTRAINT filters_num_check CHECK (num = ANY (ARRAY[1, 2,3,4]));

CREATE OR REPLACE FUNCTION osdregistry.parse_numeric(val text, def numeric)
  RETURNS numeric AS
$BODY$
   DECLARE
	err_msg text := '';
   BEGIN
     BEGIN
       -- in case of null return default
       IF val in ('not determined') THEN
         return def;
       END IF;
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
ALTER FUNCTION osdregistry.parse_numeric(text, numeric)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_numeric(text, numeric) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_numeric(text, numeric) TO megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.parse_numeric(text, numeric) TO megxuser;
REVOKE ALL ON FUNCTION osdregistry.parse_numeric(text, numeric) FROM public;
COMMENT ON FUNCTION osdregistry.parse_numeric(text, numeric) IS 'Returns a numeric value, in case it can not cast returns not a number';



-- Type: osdregistry.sample_submission

-- DROP TYPE osdregistry.sample_submission;

CREATE TYPE osdregistry.myosd_sample_submission AS
   (submission_id integer,
    submitted timestamp with time zone,
    myosd_id integer,
    campaign text,	
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
    platform text,
    device text,
    sample_depth text,
    sample_date text,
    sample_description text,
    first_name text,
    last_name text,
    institute text,
    email text,
    investigators json,
    water_temperature text,
    salinity text,
    biome text,
    feature text,
    material text,
    ph text,
    phosphate text,
    nitrate text,
    carbon_organic_particulate text,
    nitrite text,
    carbon_organic_dissolved_doc text,
    nano_microplankton text,
    downward_par text,
    conductivity text,
    primary_production_isotope_uptake text,
    primary_production_oxygen text,
    dissolved_oxygen_concentration text,
    nitrogen_organic_particulate_pon text,
    meso_macroplankton text,
    bacterial_production_isotope_uptake text,
    nitrogen_organic_dissolved_don text,
    ammonium text,
    silicate text,
    bacterial_production_respiration text,
    turbidity text,
    fluorescence text,
    pigment_concentration text,
    picoplankton_flow_cytometry text,
    other_params json,
    remarks json,
    filters json,
    json json);
ALTER TYPE osdregistry.myosd_sample_submission
  OWNER TO megdb_admin;



-- DROP FUNCTION
--   osdregistry.parse_myosd_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone);

CREATE OR REPLACE FUNCTION osdregistry.parse_myosd_sample_submission(
  sample json,
  id integer,
  vers integer,
  submitted timestamptz DEFAULT 'infinity',
  modified timestamptz DEFAULT 'infinity')
  RETURNS osdregistry.myosd_sample_submission AS
$BODY$
  DECLARE   
    sub osdregistry.myosd_sample_submission;
    lat_q text array := '{sampling_site,start_coordinates,latitude}';
    lon_q text array := '{sampling_site,start_coordinates,longitude}';
  BEGIN

   sub :=
    (id, 
    submitted,
    osdregistry.parse_osd_id( sample #>> '{sampling_site,site_id}'::text[] ),
    sample #>> '{sampling_site,campaign}',
    osdregistry.cleantrimtab(sample #>> '{sampling_site,site_name}') ,
    
    vers, 
    sample #>> '{sampling_site,marine_region}' , 
        CASE
            WHEN vers  in (6,7)
	      THEN ltrim(sample #>> lat_q, '+0'::text)
	    WHEN vers IN (8) AND (sample #>> ( lat_q || '{direction}')) = 'South'
	      THEN '-'::text || (sample #>> ( lat_q || '{value}' ))
	    WHEN vers IN (8) AND (sample #>> ( lat_q || '{direction}')) = 'North'
	      THEN sample #>> ( lat_q || '{value}' ) 
            ELSE ltrim(sample #>> '{sampling_site,latitude}', '+0'::text)
        END, 
        CASE
            WHEN vers  in (6,7)
	      THEN ltrim(sample #>> lon_q, '+0'::text)
	    WHEN vers IN (8) AND (sample #>> ( lon_q || '{direction}')) = 'East'
	      THEN '-'::text || (sample #>> ( lon_q || '{value}' ))
	    WHEN vers IN (8) AND (sample #>> ( lon_q || '{direction}')) = 'West'
	      THEN sample #>> ( lon_q || '{value}' ) 
            ELSE ltrim(sample #>> '{sampling_site,longitude}', '+0'::text)
        END , 
        CASE
            WHEN vers  in (6,7,8) THEN ltrim(sample #>> '{sampling_site,stop_coordinates,latitude}', '+0'::text)
            ELSE ltrim(sample #>> '{sampling_site,latitude}', '+0'::text)
        END , 
        CASE
            WHEN vers  in (6,7,8) THEN ltrim(sample #>> '{sampling_site,stop_coordinates,longitude}', '+0'::text)
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
            ELSE osdregistry.parse_numeric(
	           sample #>> '{environment,ph,choice}', 'nan'
		 )::text
        END , 
        CASE
            WHEN (sample #>> '{environment,phosphate,choice}') = 'measured'::text THEN sample #>> '{environment,phosphate,measurement,value}'
            ELSE osdregistry.parse_numeric(
	           sample #>> '{environment,phosphate,choice}', 'nan'
		 )::text
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrate,nitrate-choice}') = 'measured'::text THEN sample #>> '{environment,nitrate,nitrate-measurement}'
            ELSE osdregistry.parse_numeric(
	           sample #>> '{environment,nitrate,nitrate-choice}', 'nan'
		 )::text
        END , 
        CASE
            WHEN (sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-choice}') = 'measured'::text THEN sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-measurement}'
            ELSE sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrite,nitrite-choice}') = 'measured'::text THEN sample #>> '{environment,nitrite,nitrite-measurement}'
            ELSE osdregistry.parse_numeric(
	            sample #>> '{environment,nitrite,nitrite-choice}', 'nan'
		 )::text
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
ALTER FUNCTION osdregistry.parse_myosd_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone)
  OWNER TO megdb_admin;
  
REVOKE EXECUTE ON FUNCTION osdregistry.parse_myosd_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) FROM public;

GRANT EXECUTE ON FUNCTION osdregistry.parse_myosd_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_myosd_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.parse_myosd_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megxuser;



-- need filter insert permission
GRANT INSERT ON table myosd.filters to megx_team;

-- DROP FUNCTION
--   osdregistry.integrate_myosd_sample_submission(osdregistry.sample_submission);

CREATE OR REPLACE FUNCTION
  osdregistry.integrate_myosd_sample_submission(
    sample osdregistry.myosd_sample_submission,
    campaign text
  )  
  RETURNS integer AS
  
$BODY$
  DECLARE   
    f_curation_remark text := 'integration update';
    f_curator text := 'rkottman';
    i record;
  BEGIN

raise notice 'submission_id=%', sample.submission_id;

INSERT INTO myosd.samples (
       submission_id,
       myosd_id,
       campaign,
       label, label_verb,
       place_name, place_name_verb,
       start_lat,  start_lon,
       start_lat_verb, start_lon_verb,
       max_uncertain,
       sample_depth, sample_depth_verb,
       local_date, local_date_verb,
       local_start, local_start_verb,
       local_end, local_end_verb,
       water_temperature, water_temperature_verb,
       salinity, salinity_verb,
       biome, biome_verb,
       ph, ph_verb,
       phosphate, phosphate_verb,
       nitrite, nitrite_verb,
       nitrate, nitrate_verb,
       weather_condition, weather_condition_verb,
       air_temperature, air_temperature_verb,
       wind_speed, wind_speed_verb,
       water_depth, water_depth_verb,
       kit_arrival_date,
       kit_arrival_date_verb,
       other_params, remarks,
       raw_json,
       curator,
       curation_remark)
     VALUES (
     sample.submission_id,
     sample.myosd_id,
     campaign,
     'MYOSD' || sample.myosd_id || '_2016-06_1', sample.sample_label,
     sample.site_name, sample.site_name,
     sample.start_lat::numeric, sample.start_lon::numeric,
     sample.stop_lat,  sample.stop_lon,
     'nan'::numeric,
     sample.sample_depth::numeric,sample.sample_depth,
     sample.sample_date::date,sample.sample_date,
     sample.sample_start_time::time with time zone,sample.sample_start_time,
     sample.sample_end_time::time with time zone,sample.sample_end_time,
     COALESCE (sample.water_temperature::numeric, 'nan'::numeric),
       COALESCE (sample.water_temperature, ''),
     CASE WHEN sample.salinity IS NULL or sample.salinity = '' THEN
       'nan'::numeric
     ELSE sample.salinity::numeric END,  
       COALESCE ( sample.salinity, ''),
     CASE WHEN sample.biome NOT IN ('biome'::text, 'Intertidal area'::text, 'Inland sea'::text, 'Estuary'::text, 'Coastal sea area'::text, 'Open sea'::text, 'Lake'::text, 'River'::text, 'brackish pond'::text) THEN
     'biome' ELSE sample.biome END , sample.biome,
     
     COALESCE( sample.ph::numeric, 'nan'::numeric ),
     COALESCE( sample.ph, ''),
     
     COALESCE( sample.phosphate::numeric, 'nan'::numeric ),
     COALESCE( sample.phosphate, ''),
     
     COALESCE( sample.nitrite::numeric, 'nan'::numeric ),
     COALESCE( sample.nitrite, ''),
     
     COALESCE( sample.nitrate::numeric, 'nan'::numeric ),
     COALESCE( sample.nitrate, '' ),
     '', 'unknown', --weather condition
     'nan', '', --air temp.
     'nan', '', --wind speed
     'nan', '', --water depth
     'infinity','', -- kit arrival date 
     coalesce (sample.other_params, '{}'::json),
     coalesce( sample.json -> 'comment'::text, '{}'::json), 
     sample.json,
     f_curator,
     f_curation_remark
   );
   
   INSERT INTO myosd.filters (
          myosd_id,
          num,
	  filtration_time,
	  quantity
	  )
   SELECT sample.myosd_id,
          row_number() OVER()  AS num,
	  ceil( (s.filter ->> 'filtration_time')::numeric )::integer AS filtration_time,
	  
	  (s.filter ->> 'quantity')::numeric AS quantity
	  
     FROM json_array_elements( sample.json #> '{sample,filters}' ) as  s(filter);

    INSERT INTO myosd.collectors
        (myosd_id,num,first_name,last_name,email)
    VALUES (
      sample.myosd_id,
      1,
      sample.json #>> '{contact,first_name}',
      sample.json #>> '{contact,last_name}',
      sample.json #>> '{contact,email}'
    );


    INSERT INTO myosd.collectors
        (myosd_id,num,first_name,last_name,email)
    SELECT sample.myosd_id,
           row_number()  Over() + 1 as num,
	   s.col ->> 'first_name',
	   s.col ->> 'last_name',
	   s.col ->> 'email'
     FROM json_array_elements( sample.json #> '{investigators}' ) as  s(col);


--/*
    UPDATE myosd.samples s
       SET local_start = ('now'::date::text || ' ' || s.local_start::time::text || ' ' || tz.tz_name1st)::time with time zone,
        local_end = ('now'::date::text || ' ' || s.local_end::time::text || ' ' || tz.tz_name1st)::time with time zone
      FROM elayers.world_time_zones tz
     WHERE tz_namesum > 0
           AND
	   st_intersects ( s.start_geom, tz.geom) 
          ;
  --*/ 
    return sample.submission_id;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
ALTER FUNCTION osdregistry.integrate_myosd_sample_submission(osdregistry.myosd_sample_submission, text)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.integrate_myosd_sample_submission(osdregistry.myosd_sample_submission, text) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.integrate_myosd_sample_submission(osdregistry.myosd_sample_submission, text) TO megx_team;
REVOKE ALL ON FUNCTION osdregistry.integrate_myosd_sample_submission(osdregistry.myosd_sample_submission, text) FROM public;


/*
select raw_json #>> '{sampling_site,campaign}' as g ,
       raw_json ->> 'version' as ver
  from osdregistry.osd_raw_samples
 where raw_json #>> '{sampling_site,campaign}'
       IN ( 'MYOSD-June-2015', 'MyOSD-June-2015') AND id = 7;
--*/

 -- for some test queries as user megxuser
SET ROLE megx_team;


select osdregistry.integrate_myosd_sample_submission(
          osdregistry.parse_myosd_sample_submission (
            r.raw_json,
	    r.id,
	    r.version,
	    r.submitted,
	    r.modified
        ),'MyOSD-Jun-2015')
  from osdregistry.osd_raw_samples r
 where r.id NOT IN (451,472,503,505,683,796)
       AND
       r.raw_json #>> '{sampling_site,campaign}' ilike 'myosd%'
 --order by random()
 --limit 1
 ;

select s.myosd_id,local_date,local_start, c.*
  from myosd.samples s
       inner join
       myosd.collectors c
       ON (c.myosd_id = s.myosd_id)
 where campaign = 'MyOSD-Jun-2015'
order by c.myosd_id,c.num;

commit;



