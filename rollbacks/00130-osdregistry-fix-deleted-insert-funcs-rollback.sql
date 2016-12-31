
BEGIN;

SELECT _v.unregister_patch( '00130-osdregistry-fix-deleted-insert-funcs');


ROLLBACK;
