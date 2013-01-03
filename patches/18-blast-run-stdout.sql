BEGIN;

SELECT _v.register_patch( '18-blast-run-stdout', ARRAY['17-blast-hits-fkey'], NULL );

ALTER TABLE core.blast_run ADD COLUMN stdout text;

COMMIT;  