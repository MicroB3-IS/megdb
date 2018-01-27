-- Function: osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone)

-- DROP FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone);

CREATE OR REPLACE FUNCTION osdregistry.parse_sample_submission(sample json, id integer, vers integer, submitted timestamp with time zone DEFAULT 'infinity'::timestamp with time zone, modified timestamp with time zone DEFAULT 'infinity'::timestamp with time zone)
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
ALTER FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megxuser;
