
BEGIN;
SELECT _v.register_patch('00176-international-myosd2016-integration',
                          array['00174-sub-overview-osd2015'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


ALTER TABLE myosd.filters
  DROP CONSTRAINT filters_num_check,
  ADD CONSTRAINT filters_num_check CHECK (num between 1 and 10);


CREATE OR REPLACE FUNCTION osdregistry.parse_osd_id(
      id text
    )
  RETURNS integer  AS
$BODY$
   select substring( btrim(id), '(?i)[MYROSD ]{0,5}(\d+)'::text)::integer;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.parse_osd_id(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_osd_id(text) FROM megxuser,megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.parse_osd_id(text) TO megxuser,megx_team;


 
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
    site_id text;
  BEGIN

   site_id := coalesce (
      osdregistry.parse_osd_id( sample #>> '{sampling_site,site_id}'),
      osdregistry.parse_osd_id( sample #>> '{sample,label}' )
   );
   
   Raise Notice 'parsed site_id=%',  site_id ;


   sub :=
    (id, 
    submitted,
    site_id,
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




SET ROLE megx_team;


select osdregistry.integrate_myosd_sample_submission(
          osdregistry.parse_myosd_sample_submission (
            r.raw_json,
	    r.id,
	    r.version,
	    r.submitted,
	    r.modified
        ),'MyOSD-Jun-2016')
  FROM osdregistry.osd_raw_samples r
  INNER JOIN  osdregistry_stage.int_myosd_2016 m
    ON (r.id = m.submission_id AND m.submission_id > 0)
  LEFT JOIN myosd.samples s
    ON (s.myosd_id = m.myosd_id)
  WHERE s.myosd_id is null
 ;

select s.myosd_id,local_date,local_start, c.*
  from myosd.samples s
       inner join
       osdregistry_stage.int_myosd_2016 c
       ON (c.myosd_id = s.myosd_id)
order by c.myosd_id;


-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


