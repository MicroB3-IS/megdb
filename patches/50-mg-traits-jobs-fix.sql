BEGIN;

SELECT _v.register_patch('50-mg-traits-jobs-fix', 
                          array[ '48-mg-traits-example-data'] );

set search_path to mg_traits;

ALTER TABLE mg_traits.mg_traits_jobs 
  DROP CONSTRAINT "mg_traits_jobs_job_id_check";


commit;
