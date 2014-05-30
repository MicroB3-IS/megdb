
BEGIN;

SELECT _v.unregister_patch( '00083-osd-registry-test-table');

SET ROLE megdb_admin;

set search_path to osdregistry;

DROP TABLE test_samples;

DROP FUNCTION  integrate_sample_submission(json);

commit;
