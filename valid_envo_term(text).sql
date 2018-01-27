-- Function: osdregistry.valid_envo_term(text)

-- DROP FUNCTION osdregistry.valid_envo_term(text);

CREATE OR REPLACE FUNCTION osdregistry.valid_envo_term(val text)
  RETURNS boolean AS
$BODY$
     -- currently allows all kind of text
     select true;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.valid_envo_term(text)
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.valid_envo_term(text) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.valid_envo_term(text) TO megx_team;
GRANT EXECUTE ON FUNCTION osdregistry.valid_envo_term(text) TO megxuser;
REVOKE ALL ON FUNCTION osdregistry.valid_envo_term(text) FROM public;
COMMENT ON FUNCTION osdregistry.valid_envo_term(text) IS 'Checks wether is in list of valid ENVO term';
