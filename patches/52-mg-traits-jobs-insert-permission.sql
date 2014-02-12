BEGIN;

SELECT _v.register_patch('52-mg-traits-jobs-insert-permission',
                          array[ '51-mg-traits-web-permissions'] );

set search_path to mg_traits;	 

GRANT insert ON mg_traits_jobs TO megxuser;
GRANT usage, select ON mg_traits_jobs_id_seq TO megxuser;
GRANT select,update ON mg_traits_jobs TO sge;
GRANT usage, select ON mg_traits_jobs_id_seq TO sge;

commit;
