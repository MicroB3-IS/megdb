
begin;
select s.osd_id, s.start_lat, c.start_lat as new_lat, s.start_lon , c.start_lon as new_lon, s.stop_lat, s.stop_lon
  From osdregistry.samples s
       INNER JOIN
       osdregistry_stage.osd_2014_corrections c
         on (s.osd_id = c.osd_id AND s.water_depth = c.water_depth::numeric)
  where ( round(s.start_lat, 6) is distinct from round(c.start_lat::numeric,6)
          or 
          round(s.start_lon, 6) is distinct from round(c.start_lon::numeric,6)
        )
  and s.osd_id = 20;

-- updating start lat/lon according to Antonio's and Kelly's manual curation, 
-- in case start and stop are equal also updating stop
UPDATE osdregistry.samples as s 
   set start_lat = c.start_lat::numeric,
       start_lon = c.start_lon::numeric,
       stop_lat = CASE when s.start_lat = s.stop_lat 
                        Then c.start_lat::numeric
                        ELSE s.stop_lat
                  end,
       stop_lon = CASE WHEN s.start_lon = s.stop_lon
                       THEN c.start_lon::numeric
                       ELSE s.stop_lon
                  END
  FROM osdregistry_stage.osd_2014_corrections c
 where s.osd_id = c.osd_id AND s.water_depth = c.water_depth::numeric 
       and (
            round(s.start_lat, 6) is distinct from round(c.start_lat::numeric,6)
            or 
            round(s.start_lon, 6) is distinct from round(c.start_lon::numeric,6)
           )
returning s.osd_id, s.start_lat, s.start_lon , s.stop_lat, s.stop_lon
  ;


commit;