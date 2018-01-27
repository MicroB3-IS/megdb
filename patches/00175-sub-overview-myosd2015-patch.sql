
BEGIN;
SELECT _v.register_patch('00175-sub-overview-myosd2015',
                          array['00174-sub-overview-osd2015'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;



CREATE OR REPLACE VIEW osdregistry.submission_overview_myosd2015 AS 
 SELECT so.raw_json #>> '{sampling_site,campaign}'::text[] AS campaign, 
    so.submission_id, 
    so.submitted, 
    so.osd_id, 
    so.site_name, 
    so.version, 
    so.marine_region, 
    so.start_lat, 
    so.start_lon, 
    so.stop_lat, 
    so.stop_lon, 
    so.sample_start_time, 
    so.sample_end_time, 
    so.sample_label, 
    so.sample_protocol, 
    so.objective, 
    so.platform, 
    so.device, 
    so.sample_depth, 
    so.sample_date, 
    so.sample_description, 
    so.first_name, 
    so.last_name, 
    so.institute, 
    so.email, 
    so.investigators, 
    so.water_temperature, 
    so.salinity, 
    so.biome, 
    so.feature, 
    so.material, 
    so.ph, 
    so.phosphate, 
    so.nitrate, 
    so.carbon_organic_particulate, 
    so.nitrite, 
    so.carbon_organic_dissolved_doc, 
    so.nano_microplankton, 
    so.downward_par, 
    so.conductivity, 
    so.primary_production_isotope_uptake, 
    so.primary_production_oxygen, 
    so.dissolved_oxygen_concentration, 
    so.nitrogen_organic_particulate_pon, 
    so.meso_macroplankton, 
    so.bacterial_production_isotope_uptake, 
    so.nitrogen_organic_dissolved_don, 
    so.ammonium, 
    so.silicate, 
    so.bacterial_production_respiration, 
    so.turbidity, 
    so.fluorescence, 
    so.pigment_concentration, 
    so.picoplankton_flow_cytometry, 
    so.other_params, 
    so.remarks, 
    so.filters, 
    so.raw_json
   FROM osdregistry.submission_overview so
  WHERE submission_id in (445,541,682,684,685,686,687,688,689,690,691,693,694,695)
        OR (
	  so.submission_id NOT IN (451,472,503,505,683,796)
	  AND
	  (so.raw_json #>> '{sampling_site,campaign}') IN ('MyOSD-June-2015', 'MYOSD-June-2015')
          AND
	  so.submitted > '2015-06-01'::date
	  AND
	  so.submission_id > 295
        )
	;
	
ALTER TABLE osdregistry.submission_overview_myosd2015
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.submission_overview_myosd2015 TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.submission_overview_myosd2015 TO megx_team WITH GRANT OPTION;



-- View: osdregistry.submission_overview_osd2015_new



CREATE OR REPLACE VIEW osdregistry.submission_overview_myosd2015_new AS 
 SELECT o.*
   FROM osdregistry.submission_overview_myosd2015 o
   LEFT JOIN myosd.samples s ON s.submission_id = o.submission_id
  WHERE s.submission_id IS NULL;

ALTER TABLE osdregistry.submission_overview_myosd2015_new
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.submission_overview_myosd2015_new
  TO megdb_admin;
GRANT SELECT
  ON TABLE osdregistry.submission_overview_myosd2015_new
  TO megx_team
  WITH GRANT OPTION;



-- for some test queries as user megxuser
SET ROLE megx_team;

SELECT campaign, osd_id, sample_label, sample_date, sample_protocol,
       start_lat, start_lon,
       submission_id, submitted, version
  FROM osdregistry.submission_overview_myosd2015
  order BY submission_id;


select * from osdregistry.submission_overview_myosd2015_new

rollback;


