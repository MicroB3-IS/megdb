
BEGIN;
SELECT _v.register_patch('00123-osdregistry-sites-fix-lat-lon-sync-trigger',
                          array['00122-osdregistry-controlled-vocab-fix'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


DROP TRIGGER sites_lat_lon_sync ON osdregistry.sites;

CREATE TRIGGER sites_lat_lon_sync
BEFORE INSERT OR UPDATE OF lat,lon
    ON osdregistry.sites
   FOR EACH ROW EXECUTE PROCEDURE osdregistry.lat_lon_sync_trg();
	


-- should return no row
WITH trg_check AS (
  UPDATE osdregistry.sites set lat = lat, lon = lon
  returning label, lat, st_y(geog::geometry), st_y(geom) as geom_lat,
                   lon , st_x(geog::geometry), st_x(geom) as geom_lon
)

select *
  from trg_check
 where NOT (lat = st_y AND lat = geom_lat) AND NOT (lon = st_x AND lon = geom_lon) ;

-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


