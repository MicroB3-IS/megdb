BEGIN;

SELECT _v.register_patch('30-drop-clonelib-trigger' , NULL, NULL );

DROP TRIGGER project_clonelibs_pk ON core.clonelibs;

COMMIT;