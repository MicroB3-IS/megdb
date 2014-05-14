
-- this is just an interims thing for production at time 2015-05
BEGIN;

update esa.samples set elevation = null WHERE elevation = 'nan';
update esa.samples set sampling_depth = null WHERE sampling_depth = 'nan';
update esa.samples set water_depth = null WHERE water_depth = 'nan';
update esa.samples set air_temperature = null WHERE air_temperature = 'nan';
update esa.samples set water_temperature = null WHERE water_temperature = 'nan'; 
update esa.samples set wind_speed = null WHERE wind_speed = 'nan';
update esa.samples set salinity = null WHERE salinity = 'nan'; 
update esa.samples set accuracy = null WHERE accuracy = 'nan'; 
update esa.samples set phosphate = null WHERE phosphate = 'nan';
update esa.samples set nitrate = null WHERE nitrate = 'nan';
update esa.samples set nitrite = null WHERE nitrite = 'nan';
update esa.samples set ph = null WHERE ph = 'nan';
update esa.samples set boat_length = null WHERE boat_length = 'nan';
update esa.samples set secchi_depth = null WHERE secchi_depth = 'nan';

-- now all text columns
update esa.samples set collection = null WHERE collection = '';
update esa.samples set permit = null WHERE permit = '';
update esa.samples set weather_condition = null WHERE weather_condition = '';
update esa.samples set conductivity = null WHERE conductivity = '';
update esa.samples set comment = null WHERE comment = '';
update esa.samples set homeport = null WHERE homeport = '';
update esa.samples set material = null WHERE material = '';
update esa.samples set boat_manufacturer = null WHERE boat_manufacturer = '';
update esa.samples set boat_model = null WHERE boat_model = '';

update esa.samples set barcode = null WHERE barcode = '';
update esa.samples set project_id = null WHERE project_id = '';
update esa.samples set user_name = null WHERE user_name = '';
update esa.samples set ship_name = null WHERE ship_name = '';
update esa.samples set nationality = null WHERE nationality = '';
update esa.samples set biome = null WHERE biome = '';
update esa.samples set feature = null WHERE feature = '';

\x 
select * from esa.samples;

commit;
