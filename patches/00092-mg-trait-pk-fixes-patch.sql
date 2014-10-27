
BEGIN;
SELECT _v.register_patch('00092-mg-trait-pk-fixes',
                          array['00088-megx-team-rights'] );


-- first need to change as superuser


-- now changing ownership to megdb_admin
ALTER TYPE mg_traits.time_log_entry OWNER TO megdb_admin;


-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path to mg_traits;

-- no need for codon, functional, taxonomy

ALTER TABLE mg_traits.mg_traits_aa DROP CONSTRAINT mg_traits_aa_pkey;
ALTER TABLE mg_traits.mg_traits_aa ADD PRIMARY KEY (id);

ALTER TABLE mg_traits.mg_traits_dinuc DROP CONSTRAINT mg_traits_dinuc_pkey;
ALTER TABLE mg_traits.mg_traits_dinuc ADD PRIMARY KEY (id);

ALTER TABLE mg_traits.mg_traits_results DROP CONSTRAINT mg_traits_results_pkey;
ALTER TABLE mg_traits.mg_traits_results ADD PRIMARY KEY (id);



ALTER TABLE mg_traits.mg_traits_jobs
   ALTER COLUMN make_public SET DEFAULT 'P1000'::interval;


COMMENT ON COLUMN mg_traits.mg_traits_jobs.make_public IS 'The time interval when results shoud be made public after results were succesfully calculated. Default is to not make public at all by practically having interval of 1000 years.  ';
COMMENT ON COLUMN mg_traits.mg_traits_jobs.cluster_node IS 'On which nore in our cluster job was calculated.';
COMMENT ON COLUMN mg_traits.mg_traits_jobs.job_id IS 'the Sun Grid Engine job id/number';
COMMENT ON COLUMN mg_traits.mg_traits_jobs.return_code IS '-1 = submitted job, still runninf (error super error)
0 = suceesful job
> 0 is job with error ';
COMMENT ON COLUMN mg_traits.mg_traits_jobs.total_run_time IS 'the wallclock time of the running job';
COMMENT ON TABLE mg_traits.mg_traits_jobs IS 'receives job submissions and updates on job status of mg traits analysis pipeline.';



CREATE VIEW mg_traits.mg_traits_jobs_public 
  AS Select * 
       FROM mg_traits.mg_traits_jobs 
      WHERE return_code = 0
        AND time_finished + make_public <= now();

-- for some test queries as user megxuser
-- SET ROLE megxuser


commit;


