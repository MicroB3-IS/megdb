
BEGIN;

SELECT _v.unregister_patch( '00118-osdregistry-fix-utc-time-patch');


ROLLBACK;
