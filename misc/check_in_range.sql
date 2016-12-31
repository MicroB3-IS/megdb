

begin;



CREATE OR REPLACE FUNCTION osdregistry.check_in_range (
      val numeric,
      min numeric,
      max numeric
    )
  RETURNS boolean  AS
$BODY$
     select CASE WHEN val between min AND max
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.check_in_range(numeric,numeric,numeric)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.check_in_range(numeric,numeric,numeric) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.check_in_range(numeric,numeric,numeric) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.check_in_range(numeric,numeric,numeric) IS 'Checks wether latitude and longitude values are within range of WGS84 coordinates';

select osdregistry.check_in_range(90,-180, 90);

select osdregistry.check_in_range(91,91,91);


select osdregistry.check_in_range(90,1, 89.9999999999999999999999999999999999999999);


select osdregistry.check_in_range(90.00000000000,-0,1000);


select osdregistry.check_in_range(90, 0, 90.000000000000000000000000000000000000000000000000000000000000000001);

select osdregistry.check_in_range(90, 'nan'::numeric, 100);



rollback;
