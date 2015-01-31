
BEGIN;

SELECT _v.unregister_patch( '00106-pubmap-fix-missing-schema-qualifier');


ROLLBACK;
