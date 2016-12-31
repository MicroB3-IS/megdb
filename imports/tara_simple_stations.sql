
Begin;

CREATE TABLE tara_simple_stations (
  station text,
  sampling_time_start timestamp with time zone,
  sampling_time_end  timestamp with time zone,
  lat double precision,
  lon double precision,
  geog geography(POINT, 4326)

);


\copy tara_simple_stations(station, sampling_time_start,sampling_time_end, lat, lon) from '/home/renzo/src/megdb/imports/tara_simple_stations.csv' CSV HEADER; 

update tara_simple_stations set geog = ST_GeogFromText('SRID=4326;POINT(' || lon || ' ' || lat || ')');



 SELECT 
        sam.osd_id, 
        sam.label_verb,
        sam.protocol,
        tara.station,
        ST_Distance(tara.geog,sam.start_geog) 
   FROM osdregistry.samples As sam
        inner join
        tara_simple_stations As tara   
        ON ST_DWithin(tara.geog, sam.start_geog, 200000)   
        ORDER BY sam.osd_id,ST_Distance(tara.geog,sam.start_geog) 
;

rollback;



