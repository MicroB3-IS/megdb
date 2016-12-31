

begin;

CREATE OR REPLACE FUNCTION osdregistry.check_date (
      val date
    )
  RETURNS boolean  AS
$BODY$
     select CASE WHEN ( val <= now()::date ) AND ( val > '2012-06-01' )
          THEN true
	  ELSE false END;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.check_date(date)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.check_date(date) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.check_date(date) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.check_date(date) IS 'Checks wether date is in range of possible OSD dates';

select osdregistry.check_date('infinity');

select osdregistry.check_date('-infinity');

select osdregistry.check_date('2014-06-21');

select osdregistry.check_date('2010-08-30');

select osdregistry.check_date( now()::date );

--select osdregistry.check_date('infinity');


rollback;
