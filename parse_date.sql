-- Function: osdregistry.parse_date(text, date)

-- DROP FUNCTION osdregistry.parse_date(text, date);

CREATE OR REPLACE FUNCTION osdregistry.parse_date(val text, def date)
  RETURNS date AS
$BODY$
   DECLARE
      err_msg text := '';
   BEGIN
     BEGIN
       -- whitespace trimming done by cast method
       
       RETURN coalesce ( osdregistry.parse_date(val), def) ; 
       EXCEPTION WHEN OTHERS THEN
         GET STACKED DIAGNOSTICS err_msg = RETURNED_SQLSTATE;
         RAISE LOG 'wrong date % and sqlstate=%', val, err_msg;
         return res;
       END;
     return res;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION osdregistry.parse_date(text, date)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text, date) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text, date) TO megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.parse_date(text, date) TO megxuser;
REVOKE ALL ON FUNCTION osdregistry.parse_date(text, date) FROM public;
COMMENT ON FUNCTION osdregistry.parse_date(text, date) IS 'Returns a date value, in case it can not cast to date returns user suppied default value';
