
BEGIN;

SELECT _v.unregister_patch( '52-mg-traits-jobs-insert-permission');

set search_path to mg_traits;


REVOKE insert ON mg_traits_jobs FROM  megxuser;
REVOKE usage, select on mg_traits_jobs_id_seq FROM megxuser;
REVOKE all on mg_traits_jobs FROM sge;

COMMIT;
