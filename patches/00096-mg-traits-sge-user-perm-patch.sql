
BEGIN;
SELECT _v.register_patch('00096-mg-traits-sge-user-perm',
                          array['00095-mg-traits-meguser-perm']);

-- section of creation best as user role megdb_admin

SET ROLE megdb_admin;

GRANT SELECT ON mg_traits.mg_traits_jobs_public TO sge;

-- for some test queries as user megxuser

SET ROLE sge;

select 1 from mg_traits.mg_traits_jobs_public limit 1;

commit;


