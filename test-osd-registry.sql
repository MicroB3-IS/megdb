
BEGIN;

set search_path to osdregistry;

CREATE TABLE institutes (
  label text PRIMARY KEY,
  country text,
  homepage text
  -- geom
  -- accuracy
);


CREATE TABLE partners (
  email text PRIMARY KEY,
  first_name text,
  last_name text
);

CREATE TABLE works_for (
  email text REFERENCES partners(email),
  institute text REFERENCES institutes(label)
);

CREATE TABLE sites (
  id integer , 
  label text
  -- geom
  -- accuracy
);

-- not sure about this one, basically about wether OSD1014 or other...
CREATE TABLE campaign ();

CREATE TABLE samples (
  id SERIAL UNIQUE,
  label text PRIMARY KEY,  -- totdo maybe hanbokk def of label
  
  --geom
  -- accuracy
  raw json
  -- submitted, modified : check naming

);

CREATE TABLE owned_by (
  label text REFERENCES samples(label),
  email text REFERENCES partners(email),
  seq_author_order integer check(seq_author_order > 0)
);


CREATE OR REPLACE function integrate_sample_submission(sub json) RETURNS void AS $$
  DECLARE   
    test text;

  BEGIN
   test := sub #>>  '{environment,ph}';
   RAISE NOTICE 'test=%', test;

  END;
$$ LANGUAGE plpgsql;






select integrate_sample_submission ( '{"contact":{},"sampling_site":{},"sample":{"filtration_time":-1},"environment":{"temperature":-1,"salinity":-1,"phosphate":{"phosphate-choice":"not determined"},"ph":{"ph-choice":"not determined"},"nitrate":{"nitrate-choice":"not determined"},"carbon_organic_particulate_poc":{"carbon_organic_particulate_poc-choice":"not determined"},"nitrite":{"nitrite-choice":"not determined"},"carbon_organic_dissolved_doc":{"carbon_organic_dissolved_doc-choice":"not determined"},"nano_microplankton":{"nano_microplankton-choice":"not determined"},"downward_par":{"downward_par-choice":"not determined"},"conductivity":{"conductivity-choice":"not determined"},"primary_production_isotope_uptake":{"primary_production_isotope_uptake-choice":"not determined"},"primary_production_oxygen":{"primary_production_oxygen-choice":"not determined"},"dissolved_oxygen_concentration":{"dissolved_oxygen_concentration-choice":"not determined"},"nitrogen_organic_particulate_pon":{"nitrogen_organic_particulate_pon-choice":"not determined"},"meso_macroplankton":{"meso_macroplankton-choice":"not determined"},"bacterial_production_isotope_uptake":{"bacterial_production_isotope_uptake-choice":"not determined"},"nitrogen_organic_dissolved_don":{"nitrogen_organic_dissolved_don-choice":"not determined"},"ammonium":{"ammonium-choice":"not determined"},"silicate":{"silicate-choice":"not determined"},"bacterial_production_respiration":{"bacterial_production_respiration-choice":"not determined"},"turbidity":{"turbidity-choice":"not determined"},"fluorescence":{"fluorescence-choice":"not determined"},"pigment_concentrations":{"pigment_concentrations-choice":"not determined"},"picoplankton_flow_cytometry":{"picoplankton_flow_cytometry-choice":"not determined"}}}'::json);


ROLLBACK;
