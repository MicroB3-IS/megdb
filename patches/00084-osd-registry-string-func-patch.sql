
BEGIN;
SELECT _v.register_patch('00084-osd-registry-string-func',
                          array['00083-osd-registry-test-table'] );


set search_path to osdregistry;

CREATE OR REPLACE function integrate_sample_submission(sub text) RETURNS void AS $$
  DECLARE   
  

  BEGIN
  PERFORM osdregistry.integrate_sample_submission(sub::json);

  END;
$$ LANGUAGE plpgsql;

GRANT execute on function integrate_sample_submission(text) to megxuser;

select integrate_sample_submission ( '{"contact":{},"sampling_site":{},"sample":{"filtration_time":-1},"environment":{"temperature":-1,"salinity":-1,"phosphate":{"phosphate-choice":"not determined"},"ph":{"ph-choice":"not determined"},"nitrate":{"nitrate-choice":"not determined"},"carbon_organic_particulate_poc":{"carbon_organic_particulate_poc-choice":"not determined"},"nitrite":{"nitrite-choice":"not determined"},"carbon_organic_dissolved_doc":{"carbon_organic_dissolved_doc-choice":"not determined"},"nano_microplankton":{"nano_microplankton-choice":"not determined"},"downward_par":{"downward_par-choice":"not determined"},"conductivity":{"conductivity-choice":"not determined"},"primary_production_isotope_uptake":{"primary_production_isotope_uptake-choice":"not determined"},"primary_production_oxygen":{"primary_production_oxygen-choice":"not determined"},"dissolved_oxygen_concentration":{"dissolved_oxygen_concentration-choice":"not determined"},"nitrogen_organic_particulate_pon":{"nitrogen_organic_particulate_pon-choice":"not determined"},"meso_macroplankton":{"meso_macroplankton-choice":"not determined"},"bacterial_production_isotope_uptake":{"bacterial_production_isotope_uptake-choice":"not determined"},"nitrogen_organic_dissolved_don":{"nitrogen_organic_dissolved_don-choice":"not determined"},"ammonium":{"ammonium-choice":"not determined"},"silicate":{"silicate-choice":"not determined"},"bacterial_production_respiration":{"bacterial_production_respiration-choice":"not determined"},"turbidity":{"turbidity-choice":"not determined"},"fluorescence":{"fluorescence-choice":"not determined"},"pigment_concentrations":{"pigment_concentrations-choice":"not determined"},"picoplankton_flow_cytometry":{"picoplankton_flow_cytometry-choice":"not determined"}}}'::text);



commit;


