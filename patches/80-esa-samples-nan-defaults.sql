
BEGIN;
SELECT _v.register_patch('80-esa-samples-nan-defaults.sql',
                          array['79-megx-blast-id-fk-fix'] );


ALTER TABLE esa.samples
   ALTER COLUMN elevation SET DEFAULT 'nan',
   ALTER COLUMN sampling_depth SET DEFAULT 'nan',
   ALTER COLUMN water_depth SET DEFAULT 'nan',
   ALTER COLUMN air_temperature SET DEFAULT 'nan',
   ALTER COLUMN water_temperature SET DEFAULT 'nan',
   ALTER COLUMN wind_speed SET DEFAULT 'nan',
   ALTER COLUMN salinity  SET DEFAULT 'nan',
   ALTER COLUMN accuracy SET DEFAULT 'nan',
   ALTER COLUMN boat_length SET DEFAULT 'nan',
   ALTER COLUMN phosphate SET DEFAULT 'nan',
   ALTER COLUMN nitrate SET DEFAULT 'nan',
   ALTER COLUMN nitrite SET DEFAULT 'nan',
   ALTER COLUMN ph SET DEFAULT 'nan',
   ALTER COLUMN secchi_depth SET DEFAULT 'nan',

   ALTER COLUMN barcode SET NOT null,
   ALTER COLUMN barcode SET DEFAULT '',

   ALTER COLUMN project_id SET NOT null,
   ALTER COLUMN project_id SET DEFAULT '',

   ALTER COLUMN user_name SET NOT null,
   ALTER COLUMN user_name SET DEFAULT '',

   ALTER COLUMN ship_name  SET NOT null,
   ALTER COLUMN ship_name SET DEFAULT '',

   ALTER COLUMN nationality  SET NOT null,
   ALTER COLUMN nationality SET DEFAULT '',

   ALTER COLUMN biome   SET NOT null,
   ALTER COLUMN biome  SET DEFAULT '',

   ALTER COLUMN feature SET NOT null,
   ALTER COLUMN feature SET DEFAULT '',


   ALTER COLUMN collection SET NOT null,
   ALTER COLUMN collection  SET DEFAULT '',


   ALTER COLUMN permit SET NOT null,
   ALTER COLUMN permit SET DEFAULT '',

   ALTER COLUMN weather_condition SET NOT null,
   ALTER COLUMN weather_condition SET DEFAULT '',

   ALTER COLUMN conductivity SET NOT null,
   ALTER COLUMN conductivity SET DEFAULT '',

   ALTER COLUMN comment SET NOT null,
   ALTER COLUMN comment SET DEFAULT '',

   ALTER COLUMN homeport SET NOT null,
   ALTER COLUMN homeport SET DEFAULT '',

   ALTER COLUMN material SET NOT null,
   ALTER COLUMN material SET DEFAULT '',

   ALTER COLUMN boat_manufacturer SET NOT null,
   ALTER COLUMN boat_manufacturer SET DEFAULT '',

   ALTER COLUMN boat_model SET NOT null,
   ALTER COLUMN boat_model SET DEFAULT '';

commit;
