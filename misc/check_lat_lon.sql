

begin;


CREATE OR REPLACE FUNCTION osdregistry.check_lat_lon (
      lat numeric,
      lon numeric
    )
  RETURNS boolean  AS
$BODY$
     select CASE WHEN (lat between -90 AND 90) AND (lon between -180 AND 180)
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.check_lat_lon(numeric,numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.check_lat_lon(numeric,numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.check_lat_lon(numeric,numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.check_lat_lon(numeric,numeric) IS 'Checks wether latitude and longitude values are within range of WGS84 coordinates';




rollback;
