Begin;

SELECT _v.register_patch('61-megx-blast-fix-permissions',
                          array['61-unknown-blast'] );
GRANT SELECT, INSERT ON TABLE megx_blast.blast_jobs TO megxuser;
GRANT SELECT, UPDATE ON TABLE megx_blast.blast_jobs TO sge;

GRANT SELECT, INSERT, UPDATE ON TABLE megx_blast.blast_hits TO megxuser;
GRANT SELECT, UPDATE ON TABLE megx_blast.blast_hits TO sge;

commit;
