-- Function: osdregistry.integrate_sample_submission(osdregistry.sample_submission)

-- DROP FUNCTION osdregistry.integrate_sample_submission(osdregistry.sample_submission);

CREATE OR REPLACE FUNCTION osdregistry.integrate_sample_submission(sample osdregistry.sample_submission)
  RETURNS integer AS
$BODY$
  DECLARE   
    f_curation_remark text := 'integration update';
    f_curator text := 'rkottman';
    i record;
  BEGIN
   INSERT INTO osdregistry.samples (
       submission_id,
       osd_id,
       label_verb,

       start_lat_verb, start_lon_verb,
       stop_lat_verb, stop_lon_verb,

       water_depth_verb,

       local_date_verb, local_start_verb, local_end_verb,

       protocol, objective, platform, device, description,

       water_temperature_verb, salinity_verb, biome_verb, feature_verb, material_verb,

       ph_verb,
       phosphate_verb,
       nitrate_verb,
       carbon_organic_particulate_verb,
       nitrite_verb,
       carbon_organic_dissolved_doc_verb,
       nano_microplankton_verb,
       downward_par_verb,
       conductivity_verb,
       primary_production_isotope_uptake_verb,
       primary_production_oxygen_verb,
       dissolved_oxygen_concentration_verb,
       nitrogen_organic_particulate_pon_verb,
       meso_macroplankton_verb,
       bacterial_production_isotope_uptake_verb,   
       nitrogen_organic_dissolved_don_verb,
       ammonium_verb,
       silicate_verb,
       bacterial_production_respiration_verb,
       turbidity_verb, 
       fluorescence_verb,
       pigment_concentration_verb,      
       picoplankton_flow_cytometry_verb,
       remarks,
       other_params,
       raw
   ) VALUES (
     sample.submission_id,
     sample.osd_id,
     sample.sample_label,
  
     sample.start_lat, sample.start_lon,
     sample.stop_lat,  sample.stop_lon,

     sample.sample_depth,

     sample.sample_date,sample.sample_start_time, sample.sample_end_time,
  
     sample.sample_protocol, sample.objective, sample.platform, sample.device, sample.sample_description,
     COALESCE (sample.water_temperature::numeric, 'nan'::numeric),
     COALESCE (sample.salinity, 'nan'::numeric ),
     
     sample.biome,  sample.feature,  sample.material,
     sample.ph,
     sample.phosphate,
     sample.nitrate,
     sample.carbon_organic_particulate,
     sample.nitrite,
     sample.carbon_organic_dissolved_doc,
     sample.nano_microplankton,
     sample.downward_par,
     sample.conductivity,
     sample.primary_production_isotope_uptake,
     sample.primary_production_oxygen,
     sample.dissolved_oxygen_concentration,
     sample.nitrogen_organic_particulate_pon,
     sample.meso_macroplankton,
     sample.bacterial_production_isotope_uptake,
     sample.nitrogen_organic_dissolved_don,
     sample.ammonium,
     sample.silicate,
     sample.bacterial_production_respiration,
     sample.turbidity,
     sample.fluorescence,
     sample.pigment_concentration,
     coalesce( sample.picoplankton_flow_cytometry, '' ),
     coalesce( sample.json -> 'comment'::text, '{}'::json), 
     sample.other_params, 
     sample.json
   );
   
   INSERT INTO osdregistry.filters (
          sample_id,
          num,
	  filtration_time, filtration_time_verb,
	  quantity,quantity_verb,
	  container, container_verb,
	  content, content_verb,
	  size_fraction_lower_threshold, size_fraction_lower_threshold_verb,
	  size_fraction_upper_threshold, size_fraction_upper_threshold_verb,
	  treatment_chemicals, treatment_chemicals_verb,
	  treatment_storage, treatment_storage_verb,
	  curator, curation_remark, "raw")
   SELECT sample.submission_id,
          row_number() OVER()  AS num,
	  (s.filter ->> 'filtration_time')::interval minute AS filtration_time,
	  s.filter ->> 'filtration_time' AS filtration_time_verb,
	  (s.filter ->> 'quantity')::numeric AS quantity,
          s.filter ->> 'quantity' AS quantity_verb,
	  s.filter ->> 'container' AS container,
  	  s.filter ->> 'container' AS container_verb,
	  s.filter ->> 'content' AS content,
  	  s.filter ->> 'content' AS content_verb,
	  (s.filter ->> 'size-fraction_lower-threshold')::numeric AS s_frac_low_thres,
  	  s.filter ->> 'size-fraction_lower-threshold' AS s_frac_low_thres_verb,
	  (s.filter ->> 'size-fraction_upper-threshold')::numeric AS s_frac_up_thres,
          s.filter ->> 'size-fraction_upper-threshold' AS s_frac_up_thres_verb,
	  s.filter ->> 'treatment_chemicals' AS treatment_chemicals,
  	  s.filter ->> 'treatment_chemicals' AS treatment_chemicals_verb,
	  s.filter ->> 'treatment_storage' AS treatment_storage,
  	  s.filter ->> 'treatment_storage' AS treatment_storage_verb,
          f_curator,
          f_curation_remark, 
	  s.filter AS raw
     FROM json_array_elements( sample.json #> '{sample,filters}' ) as  s(filter);
   
    return sample.submission_id;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.integrate_sample_submission(osdregistry.sample_submission)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(osdregistry.sample_submission) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(osdregistry.sample_submission) TO megx_team;
REVOKE ALL ON FUNCTION osdregistry.integrate_sample_submission(osdregistry.sample_submission) FROM public;
