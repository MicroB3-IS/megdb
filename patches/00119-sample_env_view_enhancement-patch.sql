
BEGIN;
SELECT _v.register_patch('00119-sample_env_view_enhancement',
                          array['00118-osdregistry-fix-utc-time-patch'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

DROP VIEW IF EXISTS osdregistry.sample_environmental_data;

CREATE OR REPLACE VIEW osdregistry.sample_environmental_data AS 
 SELECT sam.osd_id, 
    osdregistry.osd_sample_label(sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol) AS label, 
    COALESCE(sam.bioarchive_code, 'na'::text) AS bioarchive_code, 
    sam.ena_acc, 
    COALESCE(sam.biosample_acc, 'na'::text) AS biosample_acc, 
    sam.start_lat, 
    sam.start_lon, 
    sam.stop_lat, 
    sam.stop_lon, 
    sam.water_depth, 
    sam.local_date, 
    local_start, 
    local_end,
    local_date::text || 'T' || timezone( 'UTC', sam.local_start ) AS start_date_time_utc,
    local_date::text || 'T' || timezone( 'UTC', sam.local_end ) AS end_date_time_utc,
    CASE WHEN sites.label = '' 
         THEN sites.label_verb 
         ELSE sites.label
    END as site_name,
    iho.iho_label, 
    iho.mrgid, 
    sam.protocol, 
    regexp_replace(sam.objective, E'[\\n\\r\\u2028]+', ' ', 'g' ) as objective, 
    sam.platform, 
    sam.device, 
    regexp_replace(sam.description, E'[\\n\\r\\u2028]+', ' ', 'g' ) as description, 
    sam.water_temperature, 
    sam.salinity, 
    sam.biome, 
    sam.feature, 
    sam.material, 
    sam.ph, 
    sam.phosphate, 
    sam.nitrate, 
    sam.carbon_organic_particulate, 
    sam.nitrite, 
    sam.carbon_organic_dissolved_doc, 
    sam.nano_microplankton, 
    sam.downward_par, 
    sam.conductivity, 
    sam.primary_production_isotope_uptake, 
    sam.primary_production_oxygen, 
    sam.dissolved_oxygen_concentration, 
    sam.nitrogen_organic_particulate_pon, 
    sam.meso_macroplankton, 
    sam.bacterial_production_isotope_uptake, 
    sam.nitrogen_organic_dissolved_don, 
    sam.ammonium, 
    sam.silicate, 
    sam.bacterial_production_respiration, 
    sam.turbidity, 
    sam.fluorescence, 
    sam.pigment_concentration, 
    sam.picoplankton_flow_cytometry
   FROM osdregistry.samples sam
   LEFT JOIN osdregistry.iho_tagging iho ON (sam.submission_id = iho.submission_id)
   INNER JOIN osdregistry.sites ON (sam.osd_id = sites.id )
;

ALTER TABLE osdregistry.sample_environmental_data
  OWNER TO megdb_admin;

REVOKE ALL ON TABLE osdregistry.sample_environmental_data from public;

GRANT SELECT ON TABLE osdregistry.sample_environmental_data TO megx_team,megxuser WITH GRANT OPTION;

-- for some test queries as user megxuser
SET ROLE megxuser;

select * from osdregistry.sample_environmental_data where osd_id in (156,50);

commit;


