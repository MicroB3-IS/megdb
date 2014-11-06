
BEGIN;
SELECT _v.register_patch('00094-unq-boundary-countru-name',
                          array['00093-delete_cascade_unq_job'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

ALTER TABLE elayers.boundaries ADD UNIQUE (iso3_code,terr_name);
-- for some test queries as user megxuser
-- SET ROLE megxuser


commit;


