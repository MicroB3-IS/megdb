WITH osd_sites as ( 
   SELECT id, 
          CASE WHEN raw_json #>> '{sampling_site, site_id}' = 'OSDFamagusta' 
               THEN 'OSD19' 
               ELSE raw_json #>> '{sampling_site, site_id}' 
          END as osd_id, 
          CASE WHEN version = 6
                 THEN raw_json #>> '{sampling_site, start_coordinates,latitude}' 
               WHEN version = 5
                 THEN raw_json #>> '{sampling_site, latitude}'
               ELSE '' 
          END
          as latitude, 
          CASE WHEN version = 6 THEN 
                 raw_json #>> '{sampling_site, start_coordinates,longitude}' 
               WHEN version = 5 THEN
                 raw_json #>> '{sampling_site, longitude}'
               ELSE ''
          END                 
          as longitude,
          raw_json #>> '{sampling_site, site_name}' as site_name
     FROM osdregistry.osd_raw_samples 
) 
SELECT DISTINCT ON (latitude,longitude)
       --id, 
       'OSD' ||  substring (osd_id from E'(?i)[OSD ]{3,4}(\\d{1,3})'   ) AS osd_id,
       site_name,
       latitude,longitude 
  FROM osd_sites ;

