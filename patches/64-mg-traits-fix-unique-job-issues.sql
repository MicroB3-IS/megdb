Begin;

SELECT _v.register_patch('64-mg-traits-fix-unique-job-issues',
                          array['63-update-core-tools'] );

set search_path to mg_traits;

-- fixing issue https://colab.mpi-bremen.de/its/browse/MB3_IS-436
-- drop old constraints

ALTER TABLE mg_traits_jobs DROP CONSTRAINT mg_traits_jobs_mg_url_key;
ALTER TABLE mg_traits_jobs DROP CONSTRAINT customer_sample_label_key;

-- should be only be unqiue url if job was run succesful
CREATE UNIQUE INDEX successful_jobs_key ON mg_traits_jobs (mg_url)
  WHERE return_code = 0;

CREATE UNIQUE INDEX sample_label_per_customer_key
   ON mg_traits_jobs (customer, sample_label)
   WHERE return_code = 0;

-- need to disable pgq trigger for inserts
-- ALTER TABLE mg_traits_jobs DISABLE TRIGGER USER; 

-- should not fail
/*
INSERT INTO mg_traits_jobs (
    customer, mg_url, sample_label, sample_environment,return_code
  ) 
  VALUES (
    'mg-traits-tester', 
    'https://dev-dav.megx.net/test-data/mg-traits-test2.fasta',
    'running job sample', 'marine', 1
  ), (
    'mg-traits-tester', 
    'https://dev-dav.megx.net/test-data/mg-traits-test2.fasta',
    'running job sample', 'marine', 0
  );
*/


-- now re-able
-- ALTER TABLE mg_traits_jobs ENABLE TRIGGER  USER;

commit;
