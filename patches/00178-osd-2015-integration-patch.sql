
BEGIN;
SELECT _v.register_patch('00178-osd-2015-integration',
                          array['00177-myosd-biome-correction'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

DELETE FROM osdregistry.filters WHERE sample_id = 379;
DELETE FROM osdregistry.samples WHERE submission_id = 379;


CREATE OR REPLACE FUNCTION osdregistry.parse_date(val text, def date)
  RETURNS date AS
$BODY$
   DECLARE
      err_msg text := '';
   BEGIN
     BEGIN
       -- whitespace trimming done by cast method
       
       RETURN coalesce ( osdregistry.parse_date(val), def) ; 
       EXCEPTION WHEN OTHERS THEN
         GET STACKED DIAGNOSTICS err_msg = RETURNED_SQLSTATE;
         RAISE LOG 'wrong date % and sqlstate=%', val, err_msg;
         return def;
       END;
     return def;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.parse_date(text, date)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text, date) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text, date) TO megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text, date) TO megxuser;
REVOKE ALL ON FUNCTION osdregistry.parse_date(text, date) FROM public;
COMMENT ON FUNCTION osdregistry.parse_date(text, date) IS 'Returns a date value, in case it can not cast to date returns user suppied default value';



-- Function: osdregistry.valid_envo_term(text)

-- DROP FUNCTION osdregistry.valid_envo_term(text);

CREATE OR REPLACE FUNCTION osdregistry.valid_envo_term(val text)
  RETURNS boolean AS
$BODY$
     -- currently allows all kind of text
     SELECT EXISTS( select 1 from envo.terms WHERE term = val );
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.valid_envo_term(text)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.valid_envo_term(text) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.valid_envo_term(text) TO megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.valid_envo_term(text) TO megxuser;
REVOKE ALL ON FUNCTION osdregistry.valid_envo_term(text) FROM public;
COMMENT ON FUNCTION osdregistry.valid_envo_term(text) IS 'Checks wether is in list of valid ENVO term';



-- Function: osdregistry.attempt_georef()

-- DROP FUNCTION osdregistry.attempt_georef();

CREATE OR REPLACE FUNCTION osdregistry.attempt_georef()
  RETURNS trigger AS
$BODY$
       DECLARE
	lat numeric;
	lon numeric;
	water_depth numeric;
	local_date date;
	local_start time(0);
	local_end time(0);
	tz text;
       BEGIN
       --
       -- Attempt to insert value into curated column from verbatim column.
       -- Hence this trigger is only defined to work on insert
       --
       RAISE NOTICE 'start lat lon trigger fired';
       IF (TG_OP != 'INSERT') THEN
       	  -- just doing nothing
           RETURN NEW;
       END IF;
       -- now depth parsed from verbatim or simply the current unchanged defaults
       water_depth := osdregistry.parse_numeric( NEW.water_depth_verb, NEW.water_depth );
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.is_in_range(water_depth, 0::numeric, 12000::numeric  ) THEN
       	  NEW.water_depth := water_depth;
       END IF;

       -- now local date parsed from verbatim or simply the current unchanged defaults
       local_date :=  osdregistry.parse_date( NEW.local_date_verb, 'infinity' ) ;
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_date( local_date ) THEN
       	  NEW.local_date := local_date;
       END IF;

       RAISE NOTICE 'verb times: % and % ', NEW.local_start_verb, NEw.local_end_verb;
       
       local_start :=  osdregistry.parse_local_time( NEW.local_start_verb, NEW.local_start::time without time zone ) ;
       local_end :=  osdregistry.parse_local_time( NEW.local_end_verb, NEW.local_end::time without time zone) ;



       -- now lat/lon are either parsed from verbatim or simply the current unchanged defaults
       lat := osdregistry.parse_numeric( NEW.start_lat_verb, NEW.start_lat );
       lon := osdregistry.parse_numeric( NEW.start_lon_verb, NEW.start_lon );
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_lat_lon( lat, lon ) THEN
       	  NEW.start_lat := lat;
       	  NEW.start_lon := lon;
	  SELECT CASE WHEN time_zone = 'UTC±00:00'
                      THEN '+00:00'
                      ELSE substring(time_zone from 4)
		 END
  	    INTO STRICT tz
	    FROM elayers.world_time_zones tz
  	   WHERE ( ST_intersects (
	             ST_geometryFromText('POINT(' || NEW.start_lon || ' ' || NEW.start_lat ||')', 4326 ),
		     tz.geom)
		 );
           NEW.local_start := (local_start || tz)::time(0) with time zone;
           NEW.local_end := (local_end || tz)::time(0) with time zone;

       END IF;

       RETURN NEW; 
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.attempt_georef()
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.attempt_georef() TO public;
GRANT EXECUTE ON FUNCTION osdregistry.attempt_georef() TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.attempt_georef() TO megx_team;





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
     COALESCE ( sample.water_temperature::numeric, 'NaN'::numeric ),
     COALESCE ( sample.salinity, 'NaN'::numeric ),
     
     sample.biome,  sample.feature,  sample.material,
     COALESCE ( sample.ph, '' ),
     COALESCE ( sample.phosphate, '' ),
     COALESCE ( sample.nitrate, '' ),
     COALESCE ( sample.carbon_organic_particulate, ''),
     COALESCE ( sample.nitrite, '' ),
     COALESCE ( sample.carbon_organic_dissolved_doc, ''),
     COALESCE ( sample.nano_microplankton, ''),
     COALESCE ( sample.downward_par, ''),
     COALESCE ( sample.conductivity, ''),
     COALESCE ( sample.primary_production_isotope_uptake, ''),
     COALESCE ( sample.primary_production_oxygen, ''),
     COALESCE ( sample.dissolved_oxygen_concentration, ''),
     COALESCE ( sample.nitrogen_organic_particulate_pon, ''),
     COALESCE ( sample.meso_macroplankton, ''),
     COALESCE ( sample.bacterial_production_isotope_uptake, ''),
     COALESCE ( sample.nitrogen_organic_dissolved_don, ''),
     COALESCE ( sample.ammonium, ''),
     COALESCE ( sample.silicate, ''),
     COALESCE ( sample.bacterial_production_respiration, ''),
     COALESCE ( sample.turbidity, ''),
     COALESCE ( sample.fluorescence, ''),
     COALESCE ( sample.pigment_concentration, ''),
     COALESCE( sample.picoplankton_flow_cytometry, '' ),
     COALESCE( sample.json -> 'comment'::text, '{}'::json), 
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
	  COALESCE ( s.filter ->> 'container', '' ) AS container,
  	  COALESCE ( s.filter ->> 'container', '' )  AS container_verb,
	  COALESCE ( s.filter ->> 'content', '' ) AS content,
  	  COALESCE ( s.filter ->> 'content', '' ) AS content_verb,
	  COALESCE ( (s.filter ->> 'size-fraction_lower-threshold')::numeric, 'NaN' ) AS s_frac_low_thres,
  	  COALESCE ( s.filter ->> 'size-fraction_lower-threshold', '' ) AS s_frac_low_thres_verb,
	  COALESCE ( (s.filter ->> 'size-fraction_upper-threshold')::numeric, 'NaN' ) AS s_frac_up_thres,
          COALESCE ( s.filter ->> 'size-fraction_upper-threshold', '' )  AS s_frac_up_thres_verb,
	  COALESCE ( s.filter ->> 'treatment_chemicals', '' ) AS treatment_chemicals,
  	  COALESCE ( s.filter ->> 'treatment_chemicals', '' ) AS treatment_chemicals_verb,
	  COALESCE ( s.filter ->> 'treatment_storage', '' )  AS treatment_storage,
  	  COALESCE ( s.filter ->> 'treatment_storage', '' )  AS treatment_storage_verb,
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


CREATE OR REPLACE FUNCTION osdregistry.parse_sample_submission(sample json, id integer, vers integer, submitted timestamp with time zone DEFAULT 'infinity'::timestamp with time zone, modified timestamp with time zone DEFAULT 'infinity'::timestamp with time zone)
  RETURNS osdregistry.sample_submission AS
$BODY$
  DECLARE   
    sub osdregistry.sample_submission;

  BEGIN
    sub :=
    (id, 
    submitted,
    osdregistry.parse_osd_id( sample #>> '{sampling_site,site_id}'::text[] ),
    osdregistry.cleantrimtab(sample #>> '{sampling_site,site_name}') , 
    vers, 
    sample #>> '{sampling_site,marine_region}' , 
    CASE
        WHEN vers = ANY (ARRAY[6, 7]) THEN ltrim(sample #>> '{sampling_site,start_coordinates,latitude}'::text[], '+0'::text)
        WHEN vers = 8 AND (sample #>> ('{sampling_site,start_coordinates,latitude}'::text[] || '{direction}'::text[])) = 'South'::text THEN '-'::text || (sample #>> ('{sampling_site,start_coordinates,latitude}'::text[] || '{value}'::text[]))
        WHEN vers = 8 AND (sample #>> ('{sampling_site,start_coordinates,latitude}'::text[] || '{direction}'::text[])) = 'North'::text THEN sample #>> ('{sampling_site,start_coordinates,latitude}'::text[] || '{value}'::text[])
        ELSE ltrim(sample #>> '{sampling_site,latitude}'::text[], '+0'::text)
    END, 
    CASE
        WHEN vers = ANY (ARRAY[6, 7]) THEN ltrim(sample #>> '{sampling_site,start_coordinates,longitude}'::text[], '+0'::text)
        WHEN vers = 8 AND (sample #>> ('{sampling_site,start_coordinates,longitude}'::text[] || '{direction}'::text[])) = 'East'::text THEN '-'::text || (sample #>> ('{sampling_site,start_coordinates,longitude}'::text[] || '{value}'::text[]))
        WHEN vers = 8 AND (sample #>> ('{sampling_site,start_coordinates,longitude}'::text[] || '{direction}'::text[])) = 'West'::text THEN sample #>> ('{sampling_site,start_coordinates,longitude}'::text[] || '{value}'::text[])
        ELSE ltrim(sample #>> '{sampling_site,longitude}'::text[], '+0'::text)
    END, 
    CASE
        WHEN vers = ANY (ARRAY[6, 7]) THEN ltrim(sample #>> '{sampling_site,stop_coordinates,latitude}'::text[], '+0'::text)
        WHEN vers = 8 AND (sample #>> ('{sampling_site,stop_coordinates,latitude}'::text[] || '{direction}'::text[])) = 'South'::text THEN '-'::text || (sample #>> ('{sampling_site,stop_coordinates,latitude}'::text[] || '{value}'::text[]))
        WHEN vers = 8 AND (sample #>> ('{sampling_site,stop_coordinates,latitude}'::text[] || '{direction}'::text[])) = 'North'::text THEN sample #>> ('{sampling_site,stop_coordinates,latitude}'::text[] || '{value}'::text[])
        ELSE ltrim(sample #>> '{sampling_site,latitude}'::text[], '+0'::text)
    END, 
    CASE
        WHEN vers = ANY (ARRAY[6, 7]) THEN ltrim(sample #>> '{sampling_site,stop_coordinates,longitude}'::text[], '+0'::text)
        WHEN vers = 8 AND (sample #>> ('{sampling_site,stop_coordinates,longitude}'::text[] || '{direction}'::text[])) = 'East'::text THEN '-'::text || (sample #>> ('{sampling_site,stop_coordinates,longitude}'::text[] || '{value}'::text[]))
        WHEN vers = 8 AND (sample #>> ('{sampling_site,stop_coordinates,longitude}'::text[] || '{direction}'::text[])) = 'West'::text THEN sample #>> ('{sampling_site,stop_coordinates,longitude}'::text[] || '{value}'::text[])
        ELSE ltrim(sample #>> '{sampling_site,longitude}'::text[], '+0'::text)
    END, 

    sample #>> '{sample,start_time}' , 
    sample #>> '{sample,end_time}' , 
    osdregistry.cleantrimtab(sample #>> '{sample,label}') , 
    btrim(sample #>> '{sample,protocol_label}') , 
    COALESCE( osdregistry.cleantrimtab(sample #>> '{sampling_site,objective}'), '' ) , 
    COALESCE( osdregistry.cleantrimtab(sample #>> '{sampling_site,platform}'), ''), 
    COALESCE( osdregistry.cleantrimtab(sample #>> '{sampling_site,device}'), '') , 
    COALESCE(sample #>> '{sample,depth}', 'nan'::text) , 
    sample #>> '{sample,date}' , 
    COALESCE( sample #>> '{sample,description}', '' ), 
    btrim(sample #>> '{contact,first_name}') , 
    btrim(sample #>> '{contact,last_name}') , 
    btrim(sample #>> '{contact,institute}') , 
    sample #>> '{contact,email}' , 
    (sample #>> '{investigators}')::json , 
    (sample -> 'environment'::text) ->> 'water_temperature'::text , 
    ((sample -> 'environment'::text) ->> 'salinity'::text)::numeric , 
    (sample -> 'environment'::text) ->> 'biome'::text , 
    (sample -> 'environment'::text) ->> 'feature'::text , 
    (sample -> 'environment'::text) ->> 'material'::text , 
        CASE
            WHEN (sample #>> '{environment,ph,choice}') = 'measured'::text THEN sample #>> '{environment,ph,measurement,value}'
            ELSE sample #>> '{environment,ph,choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,phosphate,choice}') = 'measured'::text THEN sample #>> '{environment,phosphate,measurement,value}'
            ELSE sample #>> '{environment,phosphate,choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrate,nitrate-choice}') = 'measured'::text THEN sample #>> '{environment,nitrate,nitrate-measurement}'
            ELSE sample #>> '{environment,nitrate,nitrate-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-choice}') = 'measured'::text THEN sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-measurement}'
            ELSE sample #>> '{environment,carbon_organic_particulate_poc,carbon_organic_particulate_poc-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrite,nitrite-choice}') = 'measured'::text THEN sample #>> '{environment,nitrite,nitrite-measurement}'
            ELSE sample #>> '{environment,nitrite,nitrite-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-choice}') = 'measured'::text THEN sample #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-measurement}'
            ELSE sample #>> '{environment,carbon_organic_dissolved_doc,carbon_organic_dissolved_doc-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nano_microplankton,nano_microplankton-choice}') = 'measured'::text THEN sample #>> '{environment,nano_microplankton,nano_microplankton-measurement}'
            ELSE sample #>> '{environment,nano_microplankton,nano_microplankton-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,downward_par,downward_par-choice}') = 'measured'::text THEN sample #>> '{environment,downward_par,downward_par-measurement}'
            ELSE sample #>> '{environment,downward_par,downward_par-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,conductivity,conductivity-choice}') = 'measured'::text THEN sample #>> '{environment,conductivity,conductivity-measurement}'
            ELSE sample #>> '{environment,conductivity,conductivity-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-choice}') = 'measured'::text THEN sample #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-measurement}'
            ELSE sample #>> '{environment,primary_production_isotope_uptake,primary_production_isotope_uptake-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,primary_production_oxygen,primary_production_oxygen-choice}') = 'measured'::text THEN sample #>> '{environment,primary_production_oxygen,primary_production_oxygen-measurement}'
            ELSE sample #>> '{environment,primary_production_oxygen,primary_production_oxygen-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-choice}') = 'measured'::text THEN sample #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-measurement}'
            ELSE sample #>> '{environment,dissolved_oxygen_concentration,dissolved_oxygen_concentration-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-choice}') = 'measured'::text THEN sample #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-measurement}'
            ELSE sample #>> '{environment,nitrogen_organic_particulate_pon,nitrogen_organic_particulate_pon-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,meso_macroplankton,meso_macroplankton-choice}') = 'measured'::text THEN sample #>> '{environment,meso_macroplankton,meso_macroplankton-measurement}'
            ELSE sample #>> '{environment,meso_macroplankton,meso_macroplankton-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-choice}') = 'measured'::text THEN sample #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-measurement}'
            ELSE sample #>> '{environment,bacterial_production_isotope_uptake,bacterial_production_isotope_uptake-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-choice}') = 'measured'::text THEN sample #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-measurement}'
            ELSE sample #>> '{environment,nitrogen_organic_dissolved_don,nitrogen_organic_dissolved_don-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,ammonium,ammonium-choice}') = 'measured'::text THEN sample #>> '{environment,ammonium,ammonium-measurement}'
            ELSE sample #>> '{environment,ammonium,ammonium-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,silicate,silicate-choice}') = 'measured'::text THEN sample #>> '{environment,silicate,silicate-measurement}'
            ELSE sample #>> '{environment,silicate,silicate-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-choice}') = 'measured'::text THEN sample #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-measurement}'
            ELSE sample #>> '{environment,bacterial_production_respiration,bacterial_production_respiration-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,turbidity,turbidity-choice}') = 'measured'::text THEN sample #>> '{environment,turbidity,turbidity-measurement}'
            ELSE sample #>> '{environment,turbidity,turbidity-choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,fluorescence,choice}') = 'measured'::text THEN sample #>> '{environment,fluorescence,measurement,value}'
            ELSE sample #>> '{environment,fluorescence,choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,pigment_concentration,choice}') = 'measured'::text THEN sample #>> '{environment,pigment_concentration,measurement,value}'
            ELSE sample #>> '{environment,pigment_concentration,choice}'
        END , 
        CASE
            WHEN (sample #>> '{environment,picoplankton_flow_cytometry,choice}') = 'measured'::text THEN sample #>> '{environment,picoplankton_flow_cytometry,measurement,value}'
            ELSE sample #>> '{environment,picoplankton_flow_cytometry,choice}'
        END , 
    COALESCE((sample -> 'environment'::text) ->> 'other_parameters'::text, '{"param":"not determined"}')::json , 
    sample -> 'comment', 
    (sample #>> '{sample,filters}')::json , 
    sample);

     return sub;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.parse_sample_submission(json, integer, integer, timestamp with time zone, timestamp with time zone) TO megxuser;




SELECT osdregistry.integrate_sample_submission( 
            osdregistry.parse_sample_submission(
                  sub.raw_json, 
                  sub.submission_id, 
                  sub.version, 
                  sub.submitted,
		  null
            )
        )
  FROM osdregistry.submission_overview_osd2015 sub
 WHERE sub.submission_id NOT IN (337,395,399,544,555,559,574,840) ;


commit;

