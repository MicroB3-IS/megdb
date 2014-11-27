
BEGIN;
SELECT _v.register_patch('00100-mibig-seq-perms',
                          array['00099-mibig-perms'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

GRANT USAGE ON SEQUENCE gene_submissions_id_seq TO megxuser;
GRANT USAGE ON SEQUENCE nrps_submissions_id_seq TO megxuser;


-- for some test queries as user megxuser
-- SET ROLE megxuser


commit;


