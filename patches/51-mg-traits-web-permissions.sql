BEGIN;

SELECT _v.register_patch('51-mg-traits-web-permissions',
                          array[ '50-mg-traits-jobs-fix'] );

set search_path to mg_traits;

GRANT USAGE ON SCHEMA mg_traits TO megxuser;

GRANT SELECT ON mg_traits_jobs TO megxuser;
GRANT SELECT ON mg_traits_aa TO megxuser;
GRANT SELECT ON mg_traits_dinuc  TO megxuser;
GRANT SELECT ON mg_traits_pfam  TO megxuser;
GRANT SELECT ON mg_traits_results  TO megxuser;

commit;
