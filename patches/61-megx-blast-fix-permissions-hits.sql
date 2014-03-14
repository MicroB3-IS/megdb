Begin;

SELECT _v.register_patch('61-megx-blast-fix-permissions-hits',
                          array['61-megx-blast-fix-permissions'] );
GRANT SELECT, INSERT, UPDATE ON TABLE megx_blast.blast_hits TO megxuser;
GRANT SELECT, UPDATE ON TABLE megx_blast.blast_hits TO sge;

commit;
