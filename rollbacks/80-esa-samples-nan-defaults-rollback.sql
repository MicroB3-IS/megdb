
BEGIN;
SELECT _v.unregister_patch('80-esa-samples-nan-defaults.sql');



ALTER TABLE esa.samples
   ALTER COLUMN elevation SET DEFAULT 0,
   ALTER COLUMN sampling_depth SET DEFAULT 0,
   ALTER COLUMN water_depth SET DEFAULT 0,
   ALTER COLUMN air_temperature SET DEFAULT 0,
   ALTER COLUMN water_temperature SET DEFAULT 0,
   ALTER COLUMN wind_speed SET DEFAULT 0,
   ALTER COLUMN salinity  SET DEFAULT 0,
   ALTER COLUMN accuracy SET DEFAULT 0,
   ALTER COLUMN boat_length SET DEFAULT 0,
   ALTER COLUMN phosphate drop DEFAULT ,
   ALTER COLUMN nitrate drop DEFAULT ,
   ALTER COLUMN nitrite drop DEFAULT ,
   ALTER COLUMN ph drop DEFAULT ,
   ALTER COLUMN secchi_depth drop DEFAULT ,

   ALTER COLUMN barcode DROP NOT NULL,
   ALTER COLUMN barcode SET DEFAULT '',

   ALTER COLUMN project_id DROP NOT NULL,
   ALTER COLUMN project_id DROP DEFAULT,

   ALTER COLUMN user_name DROP NOT NULL,
   ALTER COLUMN user_name DROP DEFAULT,

   ALTER COLUMN ship_name  DROP NOT NULL,
   ALTER COLUMN ship_name DROP DEFAULT,

   ALTER COLUMN nationality  DROP NOT NULL,
   ALTER COLUMN nationality DROP DEFAULT,

   ALTER COLUMN biome   DROP NOT NULL,
   ALTER COLUMN biome  DROP DEFAULT,

   ALTER COLUMN feature DROP NOT NULL,
   ALTER COLUMN feature DROP DEFAULT,


   ALTER COLUMN collection DROP NOT NULL,
   ALTER COLUMN collection  DROP DEFAULT,


   ALTER COLUMN permit DROP NOT NULL,
   ALTER COLUMN permit DROP DEFAULT,

   ALTER COLUMN weather_condition DROP NOT NULL,
   ALTER COLUMN weather_condition DROP DEFAULT,

   ALTER COLUMN conductivity DROP NOT NULL,
   ALTER COLUMN conductivity DROP DEFAULT,

   ALTER COLUMN comment DROP NOT NULL,
   ALTER COLUMN comment DROP DEFAULT,

   ALTER COLUMN homeport DROP NOT NULL,
   ALTER COLUMN homeport DROP DEFAULT,

   ALTER COLUMN material DROP NOT NULL,
   ALTER COLUMN material DROP DEFAULT,

   ALTER COLUMN boat_manufacturer DROP NOT NULL,
   ALTER COLUMN boat_manufacturer DROP DEFAULT,

   ALTER COLUMN boat_model DROP NOT NULL,
   ALTER COLUMN boat_model DROP DEFAULT;

commit;
