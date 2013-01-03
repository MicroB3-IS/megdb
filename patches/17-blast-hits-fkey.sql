BEGIN;

SELECT _v.register_patch( '17-blast-hits-fkey', ARRAY['16-changes-from-discussion'], NULL );

ALTER TABLE core.blast_hits ADD CONSTRAINT blast_hits_key FOREIGN KEY (sid,jid) REFERENCES core.blast_run (sid,jid);

COMMIT;  
