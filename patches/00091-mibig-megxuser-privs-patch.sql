
BEGIN;
SELECT _v.register_patch('00091-mibig-megxuser-privs',
                          array['00090-new-mibig-schema.sql'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

REVOKE ALL ON TABLE mibig.submissions FROM megxuser;
GRANT SELECT, INSERT ON TABLE mibig.submissions TO megxuser;

-- for some test queries as user megxuser
-- SET ROLE megxuser


commit;


