
BEGIN;
SELECT _v.register_patch('00118-osdregistry-fix-utc-time-patch',
                          array['00117-world_time_zones'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

grant usage on schema elayers to megx_team;


ALTER TABLE osdregistry.samples
  ADD COLUMN local_start_verb text NOT NULL DEFAULT '';

ALTER TABLE osdregistry.samples
  ADD COLUMN local_end_verb text NOT NULL DEFAULT '';


UPDATE osdregistry.samples 
   SET local_start_verb = local_start::time without time zone,
       local_end_verb = local_end::time without time zone 
RETURNING local_start_verb,local_start,local_end_verb,local_end;

UPDATE osdregistry.samples
   SET local_start = ( local_start_verb  
          || CASE WHEN time_zone = 'UTC±00:00' 
                  THEN '+00:00' 
                  ELSE substring(time_zone from 4) 
             END)::time with time zone,
      local_end = ( local_start_verb  
          || CASE WHEN time_zone = 'UTC±00:00' 
                  THEN '+00:00' 
                  ELSE substring(time_zone from 4) 
             END)::time with time zone
  from
    elayers.world_time_zones tz
  where ( ST_intersects(samples.start_geom,  tz.geom) )

RETURNING osd_id,label,label_verb,start_lat,start_lon, local_start, local_start_verb, local_end, local_end_verb, tz.name,tz.zone, utc_format, time_zone, iso_8601, places, dst_places

;


-- for some test queries as user megxuser
SET ROLE megx_team;


commit;


