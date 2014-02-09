
BEGIN;

SELECT _v.unregister_patch( '51-mg-traits-web-permissions');

set search_path to mg_traits;


REVOKE USAGE ON SCHEMA mg_traits FROM megxuser;

REVOKE SELECT ON mg_traits_jobs FROM megxuser;
REVOKE SELECT ON mg_traits_aa FROM megxuser;
REVOKE SELECT ON mg_traits_dinuc  FROM megxuser;
REVOKE SELECT ON mg_traits_pfam  FROM megxuser;
REVOKE SELECT ON mg_traits_results  FROM megxuser;


COMMIT;
