
BEGIN;
SELECT _v.register_patch('00108-convert-hstore-to-extension',
                          array['00107-pubmap-fix-another-mising-schema-qualifier'] );

-- section of creation best as user role megdb_admin
-- SET ROLE megdb_admin;

-- must be superuser to apply this patch
-- first PATCH
CREATE EXTENSION IF NOT EXISTS hstore FROM unpackaged;

-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


