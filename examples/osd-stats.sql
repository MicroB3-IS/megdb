﻿--WITH env_data AS (
   select
        raw_json #>> '{sampling_site, site_id}' as osd_id,
        raw_json #>> '{sampling_site, site_name}' as site_name,
        version,
        raw_json #>> '{sampling_site, marine_region}' as marine_region,
        raw_json #>> '{sampling_site, start_coordinates,latitude}' as start_lat,
        raw_json #>> '{sampling_site, start_coordinates,longitude}' as start_lon,
        raw_json #>> '{sampling_site, stop_coordinates,latitude}' as stop_lat,
        raw_json #>> '{sampling_site, stop_coordinates,longitude}' as stop_lon,
        raw_json #>> '{sample, depth}' as sample_depth,
        raw_json #>> '{sample, date}' as sample_date,
        
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
        
        COALESCE ( (raw_json -> 'environment' ->> 'other_parameters'), 'not determinded') as other_params,

        raw_json -> 'comment' as remarks 
         
   from osdregistry.osd_raw_samples 
   WHERE (raw_json ->> 'version' = '6' OR raw_json ->> 'version' = '5') order by osd_id  desc
;

--)
