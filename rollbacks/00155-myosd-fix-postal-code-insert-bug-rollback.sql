
BEGIN;

SELECT _v.unregister_patch( '00155-myosd-fix-postal-code-insert-bug');


ROLLBACK;
