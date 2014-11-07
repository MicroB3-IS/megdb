
BEGIN;
SELECT _v.register_patch('00095-mg-traits-meguser-perm',
                          array['00094-unq-boundary-countru-name'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

GRANT SELECT ON mg_traits.mg_traits_jobs_public TO megxuser;

-- for some test queries as user megxuser
SET ROLE megxuser;

select 1 from mg_traits.mg_traits_jobs_public limit 1;


commit;


