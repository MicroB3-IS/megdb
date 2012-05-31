BEGIN;
SELECT _v.register_patch( 'hstore', NULL, NULL );

CREATE EXTENSION hstore;

COMMIT;