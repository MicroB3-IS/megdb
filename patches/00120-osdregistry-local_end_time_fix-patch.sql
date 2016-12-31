
BEGIN;
SELECT _v.register_patch('00120-osdregistry-local_end_time_fix',
                          array['00119-sample_env_view_enhancement'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

UPDATE osdregistry.samples
   SET local_end = ( local_end_verb  
          || CASE WHEN time_zone = 'UTC±00:00' 
                  THEN '+00:00' 
                  ELSE substring(time_zone from 4) 
             END)::time with time zone
  from
    elayers.world_time_zones tz
  where ( ST_intersects(samples.start_geom,  tz.geom) )

RETURNING osd_id,label, local_start, local_end

;
commit;


