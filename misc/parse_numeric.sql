


begin;

set client_min_messages to log;

CREATE OR REPLACE FUNCTION osdregistry.parse_numeric (
      val text
    )
  RETURNS numeric  AS
$BODY$
   DECLARE
      res numeric := 'nan';
      err_msg text := '';
   BEGIN
     BEGIN
       -- whitespace trimming done by cast method
       res := trim(val, '+')::numeric;
       EXCEPTION WHEN invalid_text_representation THEN
         GET STACKED DIAGNOSTICS err_msg = RETURNED_SQLSTATE;
         RAISE LOG 'wrong numeric % and sqlstae=%', val, err_msg;
         return res;
       END;
     return res;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.parse_numeric(text)
  OWNER TO megdb_admin;

REVOKE ALL ON FUNCTION osdregistry.parse_numeric(text) FROM public;
GRANT EXECUTE ON FUNCTION osdregistry.parse_numeric(text) TO megxuser,megx_team;

COMMENT ON FUNCTION osdregistry.parse_numeric(text) IS 'Returns a numeric value, in case it can not cast returns not a number';

select osdregistry.parse_numeric ('');

select osdregistry.parse_numeric ('++2');


select osdregistry.parse_numeric ('222');

select osdregistry.parse_numeric ('222.1111111111111111111');


select osdregistry.parse_numeric ('2ttd5egeg');

select osdregistry.parse_numeric ('3 ff');



rollback;
