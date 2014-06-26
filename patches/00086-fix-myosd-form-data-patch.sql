
BEGIN;
SELECT _v.register_patch('00086-fix-myosd-form-data',
                          array['00085-better-osd-registry-sample-registration'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser

update esa.samples SET accuracy =  
  CASE WHEN (raw_data::json ->> 'gps_accuracy') = '-1' 
       THEN 'nan' ELSE (raw_data::json ->> 'gps_accuracy')::numeric 
  END, 
  nitrite = 'nan',
  ph =
  CASE WHEN raw_data::json ->> 'ph' = '-1' 
       THEN 'nan' ELSE (raw_data::json ->> 'ph')::numeric 
  END,
  phosphate = 'nan',
  secchi_depth =
  CASE WHEN raw_data::json ->> 'secchi_depth' = '-1'
       THEN 'nan' ELSE (raw_data::json ->> 'secchi_depth')::numeric
  END,
  water_temperature =
  CASE WHEN raw_data::json ->> 'water_temperature' = '-1'
       THEN 'nan' ELSE (raw_data::json ->> 'water_temperature')::numeric
  END,
  wind_speed =  
  CASE WHEN raw_data::json ->> 'wind_speed' = '-1' 
       THEN 'nan' ELSE (raw_data::json ->> 'wind_speed')::numeric
  END

WHERE (raw_data::json ->> 'origin') = 'esa-web-form' 
  AND  raw_data::json ->> 'version' = '0.2'
RETURNING *;

commit;


