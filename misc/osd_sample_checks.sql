


BEGIN;


/*
select
 from osdregistry.samples
where
--*/



--/*
select samples.osd_id, sites.label,
       samples.start_lat, st_y(samples.start_geog::geometry) as samples_lat_geog, sites.lat, st_y(sites.geog::geometry) as sites_lat_geog , 
       samples.start_lon, st_x(samples.start_geog::geometry) as samples_lon_geog, sites.lon, st_x(sites.geog::geometry) as sites_lon_geog
 from osdregistry.samples INNER JOIN osdregistry.sites on ( sites.id = samples.osd_id )
where NOT ST_DWITHIN(sites.geog, samples.start_geog, 100000); 
--*/



ROLLBACK;
