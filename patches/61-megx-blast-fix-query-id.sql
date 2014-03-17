Begin;

SELECT _v.register_patch('61-megx-blast-fix-query-id',
                          array['61-megx-blast-fix-permissions-hits'] );

ALTER TABLE megx_blast.blast_jobs RENAME COLUMN seq TO raw_fasta;
ALTER TABLE megx_blast.blast_jobs ADD COLUMN query_id text;
ALTER TABLE megx_blast.blast_jobs ADD COLUMN query_seq text;


commit;
