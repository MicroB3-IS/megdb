

select osd_id,label,label_verb,start_lat,start_lon, scalerank, featurecla, "name", map_color6, map_color8, 
       note, "zone", utc_format, time_zone, iso_8601, places, dst_places, 
       tz_name1st, tz_namesum

  from
    osdregistry.samples 
  left join 
    tz_world.world_time_zones tz
  ON ( ST_intersects(samples.start_geom,  tz.geom) )
  where  scalerank is not null;
