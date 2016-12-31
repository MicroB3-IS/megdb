
BEGIN;
SELECT _v.register_patch('00156-myosd-perm-ongsheet-view',
                          array['00155-myosd-fix-postal-code-insert-bug'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;


GRANT SELECT ON TABLE myosd.gsheet_overview TO megxuser;

commit;


