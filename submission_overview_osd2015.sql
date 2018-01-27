-- View: osdregistry.submission_overview_osd2015

begin;

DROP VIEW osdregistry.submission_overview_osd2015_new;
DROP VIEW osdregistry.submission_overview_osd2015;

CREATE OR REPLACE VIEW osdregistry.submission_overview_osd2015 AS 
 SELECT so.raw_json #>> '{sampling_site,campaign}'::text[] AS campaign, 
    so.submission_id, 
    so.submitted, 
    so.osd_id, 
    so.site_name, 
    so.version, 
    so.marine_region, 
        CASE
            WHEN so.version = ANY (ARRAY[6, 7]) THEN ltrim(so.raw_json #>> '{sampling_site,start_coordinates,latitude}'::text[], '+0'::text)
            WHEN so.version = 8 AND (so.raw_json #>> ('{sampling_site,start_coordinates,latitude}'::text[] || '{direction}'::text[])) = 'South'::text THEN '-'::text || (so.raw_json #>> ('{sampling_site,start_coordinates,latitude}'::text[] || '{value}'::text[]))
            WHEN so.version = 8 AND (so.raw_json #>> ('{sampling_site,start_coordinates,latitude}'::text[] || '{direction}'::text[])) = 'North'::text THEN so.raw_json #>> ('{sampling_site,start_coordinates,latitude}'::text[] || '{value}'::text[])
            ELSE ltrim(so.raw_json #>> '{sampling_site,latitude}'::text[], '+0'::text)
        END AS start_lat, 
        CASE
            WHEN so.version = ANY (ARRAY[6, 7]) THEN ltrim(so.raw_json #>> '{sampling_site,start_coordinates,longitude}'::text[], '+0'::text)
            WHEN so.version = 8 AND (so.raw_json #>> ('{sampling_site,start_coordinates,longitude}'::text[] || '{direction}'::text[])) = 'East'::text THEN '-'::text || (so.raw_json #>> ('{sampling_site,start_coordinates,longitude}'::text[] || '{value}'::text[]))
            WHEN so.version = 8 AND (so.raw_json #>> ('{sampling_site,start_coordinates,longitude}'::text[] || '{direction}'::text[])) = 'West'::text THEN so.raw_json #>> ('{sampling_site,start_coordinates,longitude}'::text[] || '{value}'::text[])
            ELSE ltrim(so.raw_json #>> '{sampling_site,longitude}'::text[], '+0'::text)
        END AS start_lon, 
        CASE
            WHEN so.version = ANY (ARRAY[6, 7]) THEN ltrim(so.raw_json #>> '{sampling_site,stop_coordinates,latitude}'::text[], '+0'::text)
            WHEN so.version = 8 AND (so.raw_json #>> ('{sampling_site,stop_coordinates,latitude}'::text[] || '{direction}'::text[])) = 'South'::text THEN '-'::text || (so.raw_json #>> ('{sampling_site,stop_coordinates,latitude}'::text[] || '{value}'::text[]))
            WHEN so.version = 8 AND (so.raw_json #>> ('{sampling_site,stop_coordinates,latitude}'::text[] || '{direction}'::text[])) = 'North'::text THEN so.raw_json #>> ('{sampling_site,stop_coordinates,latitude}'::text[] || '{value}'::text[])
            ELSE ltrim(so.raw_json #>> '{sampling_site,latitude}'::text[], '+0'::text)
        END AS stop_lat, 
        CASE
            WHEN so.version = ANY (ARRAY[6, 7]) THEN ltrim(so.raw_json #>> '{sampling_site,stop_coordinates,longitude}'::text[], '+0'::text)
            WHEN so.version = 8 AND (so.raw_json #>> ('{sampling_site,stop_coordinates,longitude}'::text[] || '{direction}'::text[])) = 'East'::text THEN '-'::text || (so.raw_json #>> ('{sampling_site,stop_coordinates,longitude}'::text[] || '{value}'::text[]))
            WHEN so.version = 8 AND (so.raw_json #>> ('{sampling_site,stop_coordinates,longitude}'::text[] || '{direction}'::text[])) = 'West'::text THEN so.raw_json #>> ('{sampling_site,stop_coordinates,longitude}'::text[] || '{value}'::text[])
            ELSE ltrim(so.raw_json #>> '{sampling_site,longitude}'::text[], '+0'::text)
        END AS stop_lon, 
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
  WHERE so.submission_id = 557 
  OR (so.submission_id <> 
       ALL (ARRAY[379,537, 538, 539, 541, 542, 543, 682, 683, 684, 685, 686, 687, 688, 689, 690, 691, 692,693, 694, 695])) AND ((so.raw_json #>> '{sampling_site,campaign}'::text[]) = ANY (ARRAY['OSD-June-2015'::text, 'MicroB3-OSD2015'::text, 'MICROB3-OSD15, SOMLIT'::text])) AND so.submitted > '2015-06-01'::date AND so.submission_id > 295 AND so.osd_id < 210;

ALTER TABLE osdregistry.submission_overview_osd2015
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.submission_overview_osd2015 TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.submission_overview_osd2015 TO megx_team WITH GRANT OPTION;




CREATE OR REPLACE VIEW osdregistry.submission_overview_osd2015_new AS 
 SELECT o.campaign, 
    o.submission_id, 
    o.submitted, 
    o.osd_id, 
    o.site_name, 
    o.version, 
    o.marine_region, 
    o.start_lat, 
    o.start_lon, 
    o.stop_lat, 
    o.stop_lon, 
    o.sample_start_time, 
    o.sample_end_time, 
    o.sample_label, 
    o.sample_protocol, 
    o.objective, 
    o.platform, 
    o.device, 
    o.sample_depth, 
    o.sample_date, 
    o.sample_description, 
    o.first_name, 
    o.last_name, 
    o.institute, 
    o.email, 
    o.investigators, 
    o.water_temperature, 
    o.salinity, 
    o.biome, 
    o.feature, 
    o.material, 
    o.ph, 
    o.phosphate, 
    o.nitrate, 
    o.carbon_organic_particulate, 
    o.nitrite, 
    o.carbon_organic_dissolved_doc, 
    o.nano_microplankton, 
    o.downward_par, 
    o.conductivity, 
    o.primary_production_isotope_uptake, 
    o.primary_production_oxygen, 
    o.dissolved_oxygen_concentration, 
    o.nitrogen_organic_particulate_pon, 
    o.meso_macroplankton, 
    o.bacterial_production_isotope_uptake, 
    o.nitrogen_organic_dissolved_don, 
    o.ammonium, 
    o.silicate, 
    o.bacterial_production_respiration, 
    o.turbidity, 
    o.fluorescence, 
    o.pigment_concentration, 
    o.picoplankton_flow_cytometry, 
    o.other_params, 
    o.remarks, 
    o.filters, 
    o.raw_json
   FROM osdregistry.submission_overview_osd2015 o
   LEFT JOIN osdregistry.samples s ON s.submission_id = o.submission_id
  WHERE s.submission_id IS NULL;

ALTER TABLE osdregistry.submission_overview_osd2015_new
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.submission_overview_osd2015_new TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.submission_overview_osd2015_new TO megx_team WITH GRANT OPTION;



rollback;


