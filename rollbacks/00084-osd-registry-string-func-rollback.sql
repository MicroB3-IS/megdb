
BEGIN;

SELECT _v.unregister_patch( '00084-osd-registry-string-func');



set search_path to osdregistry;



DROP FUNCTION  integrate_sample_submission(text);

commit;

