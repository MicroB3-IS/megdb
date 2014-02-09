
BEGIN;

SELECT _v.unregister_patch( '42-ena-samples-stage');


DROP TABLE IF EXISTS stage_r8.ena_samples;

COMMIT;
