
BEGIN;
SELECT _v.register_patch('00130-osdregistry-fix-deleted-insert-funcs',
                          array['00129-mass-lifewatch-curation-update'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


CREATE OR REPLACE FUNCTION osdregistry.integrate_sample_submission(sub text)
  RETURNS void AS
  $BODY$
    DECLARE


  BEGIN
    PERFORM osdregistry.integrate_sample_submission(sub::json);

  END;
  $BODY$
    LANGUAGE plpgsql VOLATILE
      COST 100;
      ALTER FUNCTION osdregistry.integrate_sample_submission(text)
        OWNER TO megdb_admin;
	revoke EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(text) from public;
	GRANT EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(text) TO rkottman;
	GRANT EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(text) TO megxuser;



-- Function: osdregistry.integrate_sample_submission(json)

-- DROP FUNCTION osdregistry.integrate_sample_submission(json);


CREATE OR REPLACE FUNCTION osdregistry.integrate_sample_submission(sub json)
  RETURNS void AS
  $BODY$
    DECLARE
        version integer;

  BEGIN
     -- sub = submission
        version := sub #>>  '{version}';
	   RAISE NOTICE 'version=%', version;

   IF version is null OR version < 1 THEN
        RAISE Exception 'Wrong json schema version: %. Expecting version as single number (integer) >0', version;
	   END IF;
	      INSERT INTO osdregistry.osd_raw_samples (version, raw_json) VALUES (version,sub);


  END;
  $BODY$
    LANGUAGE plpgsql VOLATILE
      COST 100;
      ALTER FUNCTION osdregistry.integrate_sample_submission(json)
        OWNER TO megdb_admin;
	revoke EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(json) from public;
	GRANT EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(json) TO megdb_admin;
	GRANT EXECUTE ON FUNCTION osdregistry.integrate_sample_submission(json) TO megxuser;

--SET ROLE megxuser;
select osdregistry.integrate_sample_submission('{"version" : 1}');


-- for some test queries as user megxuser



commit;


