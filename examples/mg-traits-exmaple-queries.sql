BEGIN;

set search_path to mg_traits;


-- post on /jobs
-- example started(ing) job
-- customer as by authorization or anonymous
INSERT INTO mg_traits_jobs (
    customer, mg_url, sample_label, sample_environment
  ) 
  VALUES (
    'mg-traits-tester', 
    'https://dev-dav.megx.net/test-data/mg-traits-test2.fasta',
    'running job sample', 'marine'
) RETURNING id;

-- get job details on /jobs/mg{id}:{sample_name}
select id, sample_label, time_submitted, time_finished, return_code, error_message from mg_traits.mg_traits_jobs;

-- // get on /mg{id}:{sample_name}/simple-traits
select * from mg_traits_results where id = ?;

-- // get on /mg{id}:{sample_name}/function-table
select * from mg_traits_pfam where id = ?;

-- // get on /mg{id}:{sample_name}/amino-acid-content
select * from mg_traits.aa where id = ?;

-- // get on /mg{id}:{sample_name}/di-nucleotide-odds-ratio
select * from mg_traits.dinuc where id = ?;



rollback;
