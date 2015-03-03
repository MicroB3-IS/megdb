
BEGIN;
SELECT _v.register_patch('00116-osdregistry-sample-env-view',
                          array['00115-osdregistry-ena-management'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;

CREATE VIEW sample_environmental_data AS 
SELECT sam.osd_id,
       osdregistry.osd_sample_label(
           sam.osd_id::text, 
           sam.local_date::text,
           sam.water_depth::text, sam.protocol::text 
       ) as label,
       bioarchive_code,
       ena_acc, 
       biosample_acc,
       start_lat, 
       start_lon, 
       stop_lat, 
       stop_lon, 
       water_depth, 
       local_date, 
       local_start:: time without time zone,
       local_end:: time without time zone, 
       iho.iho_label,
       iho.mrgid,
       protocol, 
       objective, 
       platform,
       device,
       description,
       water_temperature, 
       salinity,
       biome,
       feature,
       material,
       ph,
       phosphate,
       nitrate, 
       carbon_organic_particulate,
       nitrite,
       carbon_organic_dissolved_doc,
       nano_microplankton,
       downward_par,
       conductivity,
       primary_production_isotope_uptake, 
       primary_production_oxygen, 
       dissolved_oxygen_concentration, 
       nitrogen_organic_particulate_pon, 
       meso_macroplankton,
       bacterial_production_isotope_uptake,
       nitrogen_organic_dissolved_don,
       ammonium, 
       silicate,
       bacterial_production_respiration, 
       turbidity,
       fluorescence,
       pigment_concentration,
       picoplankton_flow_cytometry, 
       remarks 
      
  FROM osdregistry.samples sam
  LEFT JOIN osdregistry.iho_tagging iho ON (sam.submission_id = iho.submission_id);

commit;


