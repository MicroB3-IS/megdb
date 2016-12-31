


begin;

set client_min_messages to log;

CREATE OR REPLACE FUNCTION osdregistry.parse_date (
      val text
    )
  RETURNS date  AS
$BODY$
   DECLARE
      res date := 'infinity';
      err_msg text := '';
   BEGIN
     BEGIN
       -- whitespace trimming done by cast method
       res := val::date;
       EXCEPTION WHEN OTHERS THEN
         GET STACKED DIAGNOSTICS err_msg = RETURNED_SQLSTATE;
         RAISE LOG 'wrong date % and sqlstae=%', val, err_msg;
         return res;
       END;
     return res;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.parse_date(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_date(text) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_date(text) IS 'Returns a date value, in case it can not cast to date returns +infinity';

select osdregistry.parse_date ('2014-06-21');

select osdregistry.parse_date ('222');

select osdregistry.parse_date ('2014-08-111');


select osdregistry.parse_date ('-infinity');

select osdregistry.parse_date ('infinity');



rollback;
