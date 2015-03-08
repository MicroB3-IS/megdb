
BEGIN;

SELECT _v.unregister_patch( '00117-osdregistry-fix-utc-time');


ROLLBACK;
