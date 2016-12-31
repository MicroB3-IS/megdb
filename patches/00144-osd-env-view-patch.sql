
BEGIN;
SELECT _v.register_patch('00144-osd-env-view',
                          array['00143-osd-lme-longhurst-tagging'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

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
    sam.local_start, 
    sam.local_end, 
    CASE WHEN sam.submission_id in (96,292)
         THEN '2014-06-20T' || timezone('UTC'::text, sam.local_start)
	 ELSE (sam.local_date::text || 'T'::text) || timezone('UTC'::text, sam.local_start) 
    END AS start_date_time_utc,
    CASE WHEN sam.submission_id in (96,292)
         THEN '2014-06-20T' || timezone('UTC'::text, sam.local_end)
          ELSE (sam.local_date::text || 'T'::text) || timezone('UTC'::text, sam.local_end)
    END AS end_date_time_utc, 
    CASE
      WHEN sites.label = ''::text THEN sites.label_verb
      ELSE sites.label
    END AS site_name, 
    iho.iho_label, 
    iho.mrgid, 
    sam.protocol, 
    regexp_replace(sam.objective, '[\n\r\u2028]+'::text, ' '::text, 'g'::text) AS objective, 
    sam.platform, 
    sam.device, 
    regexp_replace(sam.description, '[\n\r\u2028]+'::text, ' '::text, 'g'::text) AS description, 
    sam.water_temperature, 
    sam.salinity, 
    sam.biome, 
    envo_biome.id AS biome_id, 
    sam.feature, 
    envo_feature.id AS feature_id, 
    sam.material, 
    envo_material.id AS material_id, 
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
    sam.picoplankton_flow_cytometry,
    round(bt.dist_m) as dist_coast_m,
    bt.iso3_code as dist_coast_iso3_code,
    lh.prov_code as longhurst_code,
    lh.prov_descr as longhurst_descr,
    lh.dist_degrees as longhurst_dist_degrees,
    lme.lme_name as lme_name,
    round(lme.dist_m) as lme_dist_m

   FROM osdregistry.samples sam
        LEFT JOIN osdregistry.iho_tagging iho
	  ON sam.submission_id = iho.submission_id
	LEFT JOIN osdregistry.sample_boundaries_tagging bt
          ON sam.submission_id = bt.submission_id
        LEFT JOIN osdregistry.sample_longhurst_tagging lh
          ON sam.submission_id = lh.submission_id
	LEFT JOIN osdregistry.sample_lme_tagging lme
	  ON sam.submission_id = lme.submission_id
   JOIN envo.terms envo_biome ON sam.biome = envo_biome.term
   JOIN envo.terms envo_feature ON sam.feature = envo_feature.term
   JOIN envo.terms envo_material ON sam.material = envo_material.term
   JOIN osdregistry.sites ON sam.osd_id = sites.id;

ALTER TABLE osdregistry.sample_environmental_data
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.sample_environmental_data TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.sample_environmental_data TO megx_team WITH GRANT OPTION;
GRANT SELECT ON TABLE osdregistry.sample_environmental_data TO megxuser WITH GRANT OPTION;


commit;


