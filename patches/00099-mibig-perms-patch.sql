
BEGIN;
SELECT _v.register_patch('00099-mibig-perms',
                          array['00098-mibig-gene-npkrs-tables'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

GRANT SELECT, INSERT ON mibig.gene_submissions TO megxuser;
GRANT SELECT, INSERT ON mibig.nrps_submissions TO megxuser;

-- for some test queries as user megxuser
-- SET ROLE megxuser


commit;


