
BEGIN;

SELECT _v.unregister_patch( '82-esa-version-fun-col');

ALTER TABLE esa.samples 
   DROP COLUMN app_version,
   DROP COLUMN fun;



COMMIT;
