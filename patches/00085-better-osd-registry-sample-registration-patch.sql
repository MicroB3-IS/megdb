
BEGIN;
SELECT _v.register_patch('00085-better-osd-registry-sample-registration',
                          array['00084-osd-registry-string-func'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path to osdregistry;

CREATE TABLE osd_raw_samples (

  id SERIAL PRIMARY KEY,
  submitted timestamptz NOT NULL DEFAULT NOW(),
  modified  timestamptz NOT NULL DEFAULT NOW(),
  raw_json  json NOT NULL DEFAULT '{}',
  version integer check (version > 0)		   
);

GRANT INSERT ON TABLE osd_raw_samples TO megxuser;
GRANT SELECT, USAGE ON TABLE osdregistry.osd_raw_samples_id_seq TO megxuser;



CREATE OR REPLACE function integrate_sample_submission(sub json) RETURNS void AS $$
  DECLARE   
    version integer;

  BEGIN
   -- sub = submission
   version := sub #>>  '{version}';
   RAISE NOTICE 'version=%', version;

   IF version is null OR version < 1 THEN
     RAISE Exception 'Wrong json schema version: %. Expecting version as single number (integer) >0', version;
   END IF;
   INSERT INTO osdregistry.osd_raw_samples (version, raw_json) VALUES (version,sub); 


  END;
$$ LANGUAGE plpgsql;

GRANT execute on function integrate_sample_submission(json) to megxuser;



SET ROLE megxuser;

select integrate_sample_submission ( '{"version":"1","contact":{},"sampling_site":{},"sample":{"filtration_time":-1},"environment":{"temperature":-1,"salinity":-1,"phosphate":{"phosphate-choice":"not determined"},"ph":{"ph-choice":"not determined"},"nitrate":{"nitrate-choice":"not determined"},"carbon_organic_particulate_poc":{"carbon_organic_particulate_poc-choice":"not determined"},"nitrite":{"nitrite-choice":"not determined"},"carbon_organic_dissolved_doc":{"carbon_organic_dissolved_doc-choice":"not determined"},"nano_microplankton":{"nano_microplankton-choice":"not determined"},"downward_par":{"downward_par-choice":"not determined"},"conductivity":{"conductivity-choice":"not determined"},"primary_production_isotope_uptake":{"primary_production_isotope_uptake-choice":"not determined"},"primary_production_oxygen":{"primary_production_oxygen-choice":"not determined"},"dissolved_oxygen_concentration":{"dissolved_oxygen_concentration-choice":"not determined"},"nitrogen_organic_particulate_pon":{"nitrogen_organic_particulate_pon-choice":"not determined"},"meso_macroplankton":{"meso_macroplankton-choice":"not determined"},"bacterial_production_isotope_uptake":{"bacterial_production_isotope_uptake-choice":"not determined"},"nitrogen_organic_dissolved_don":{"nitrogen_organic_dissolved_don-choice":"not determined"},"ammonium":{"ammonium-choice":"not determined"},"silicate":{"silicate-choice":"not determined"},"bacterial_production_respiration":{"bacterial_production_respiration-choice":"not determined"},"turbidity":{"turbidity-choice":"not determined"},"fluorescence":{"fluorescence-choice":"not determined"},"pigment_concentrations":{"pigment_concentrations-choice":"not determined"},"picoplankton_flow_cytometry":{"picoplankton_flow_cytometry-choice":"not determined"}}}'::json);


select integrate_sample_submission( '{
    "version":"1",
    "contact":{
        "first_name":"Renzo",
        "last_name":"Kottmann",
        "institute":"MPI for marine Microbiology",
        "email":"test@megx.net"
    },
    "investigators":[
        {
            "first_name":"Ju",
            "last_name":"Schnitzel",
            "institute":"MPI for marine Microbiology",
            "email":"js@megx.net"
        }
    ],
    "sampling_site":{
        "site_id":"OSD0",
        "campaign":"OSD-June-2014",
        "objective":"test this form",
        "platform":"my boat",
        "device":"bucket",
        "method":"hands",
        "site_name":"MPI",
        "marine_region":"at home",
        "date_time":"2014-06-01"
    },
    "sample":{
        "label":"test",
        "protocol_label":"test",
        "container":"[",
        "filtration_time":5,
        "content":"water",
        "size-fraction_lower-threshold":"22",
        "size-fraction_upper-threshold":"22",
        "treatment_chemicals":"harsh",
        "treatment_storage":"minus 80",
        "description":"dd"
    },
    "environment":{
        "temperature":20,
        "salinity":30,
        "biome":"water",
        "feature":"water",
        "material":"water",
        "phosphate":{
            "phosphate-choice":"measured",
            "phosphate-measurement":4
        },
        "ph":{
            "ph-choice":"not determined"
        },
        "nitrate":{
            "nitrate-choice":"measured",
            "nitrate-measurement":5
        },
        "carbon_organic_particulate_poc":{
            "carbon_organic_particulate_poc-choice":"not determined"
        },
        "nitrite":{
            "nitrite-choice":"not determined"
        },
        "carbon_organic_dissolved_doc":{
            "carbon_organic_dissolved_doc-choice":"not determined"
        },
        "nano_microplankton":{
            "nano_microplankton-choice":"not determined"
        },
        "downward_par":{
            "downward_par-choice":"not determined"
        },
        "conductivity":{
            "conductivity-choice":"not determined"
        },
        "primary_production_isotope_uptake":{
            "primary_production_isotope_uptake-choice":"not determined"
        },
        "primary_production_oxygen":{
            "primary_production_oxygen-choice":"not determined"
        },
        "dissolved_oxygen_concentration":{
            "dissolved_oxygen_concentration-choice":"not determined"
        },
        "nitrogen_organic_particulate_pon":{
            "nitrogen_organic_particulate_pon-choice":"not determined"
        },
        "meso_macroplankton":{
            "meso_macroplankton-choice":"not determined"
        },
        "bacterial_production_isotope_uptake":{
            "bacterial_production_isotope_uptake-choice":"not determined"
        },
        "nitrogen_organic_dissolved_don":{
            "nitrogen_organic_dissolved_don-choice":"not determined"
        },
        "ammonium":{
            "ammonium-choice":"not determined"
        },
        "silicate":{
            "silicate-choice":"not determined"
        },
        "bacterial_production_respiration":{
            "bacterial_production_respiration-choice":"not determined"
        },
        "turbidity":{
            "turbidity-choice":"not determined"
        },
        "fluorescence":{
            "fluorescence-choice":"not determined"
        },
        "pigment_concentrations":{
            "pigment_concentrations-choice":"not determined"
        },
        "picoplankton_flow_cytometry":{
            "picoplankton_flow_cytometry-choice":"not determined"
        },
        "other_parameters":[
            {
                "param_name":"test_param",
                "param_value":"value",
                "uom":"m"
            }
        ]
    },
    "comment":"my comment"
}'::json);


set role megdb_admin;
select raw_json #> '{contact, first_name}'  from osd_raw_samples;
select (raw_json #> '{version}')::text  from osd_raw_samples;
select * from osd_raw_samples;
select count(*) from osd_raw_samples;

commit;


