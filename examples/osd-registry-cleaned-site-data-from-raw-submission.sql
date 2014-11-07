WITH osd_sites as ( 
   SELECT id, 
          CASE WHEN raw_json #>> '{sampling_site, site_id}' = 'OSDFamagusta' 
               THEN 'OSD19' 
               ELSE raw_json #>> '{sampling_site, site_id}' 
          END as osd_id, 
          raw_json, raw_json #>> '{sampling_site, start_coordinates,latitude}' as latitude, 
          raw_json #>> '{sampling_site, start_coordinates,longitude}' as longitude
     FROM osdregistry.osd_raw_samples 
) 
SELECT id, 'OSD' ||  substring (osd_id from E'(?i)[OSD ]{3,4}(\\d{1,3})'   ), latitude,longitude 
  FROM osd_sites ;
