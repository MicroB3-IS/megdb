
BEGIN;
SELECT _v.register_patch('79-megx-blast-id-fk-fix',
                          array['78-fix-spatial-table-perms'] );


set role megdb_admin;

ALTER TABLE megx_blast.blast_hits
  drop CONSTRAINT blast_hits_jid_fkey;

ALTER TABLE megx_blast.blast_hits
  ADD CONSTRAINT blast_hits_jid_fkey FOREIGN KEY (jid)
      REFERENCES megx_blast.blast_jobs (id)
      ON UPDATE cascade ON DELETE cascade;


SELECT setval('megx_blast.blast_jobs_id_seq', 100, false);


commit;
