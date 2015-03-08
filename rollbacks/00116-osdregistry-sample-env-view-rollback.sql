
BEGIN;

SELECT _v.unregister_patch( '00116-osdregistry-sample-env-view');

SET ROLE megdb_admin;


DROP VIEW osdregistry.sample_environmental_data ;


commit;
