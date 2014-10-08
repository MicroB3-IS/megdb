--WITH env_data AS (
   select
        raw_json #>> '{sampling_site, site_id}' as osd_id,
        raw_json #>> '{sampling_site, site_name}' as site_name,
        raw_json #>> '{sampling_site, marine_region}' as marine_region,
        raw_json #>> '{sampling_site, start_coordinates,latitude}' as start_lat,
        raw_json #>> '{sampling_site, start_coordinates,longitude}' as start_lon,
        raw_json #>> '{sampling_site, stop_coordinates,latitude}' as stop_lat,
        raw_json #>> '{sampling_site, stop_coordinates,longitude}' as stop_lon,
        raw_json #>> '{sample, depth}' as sample_depth,
        raw_json #>> '{sample, date}' as sample_date,
        
        raw_json -> 'environment' ->> 'water_temperature' as water_temperature,
        raw_json -> 'environment' ->> 'salinity' as salinity,
        raw_json -> 'environment' -> 'ph' as env --from which institute 
   from osdregistry.osd_raw_samples 
   WHERE raw_json ->> 'version' = '6' order by submitted  desc
;--)
