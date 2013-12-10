BEGIN;

SELECT _v.register_patch('39-mg-traits-time-protocol', 
                          array['8-authdb','31-mg-traits', '35-mg-traits-results-status', '36-mg-traits-pfam-fix', '37-mg-traits-job-data', '38-mg-traits' ] );

CREATE TYPE mg_traits.time_log_entry AS (
  job_id text,
  comment text,
  run_time numeric
);

ALTER TABLE mg_traits.mg_traits_jobs ADD COLUMN time_protocol mg_traits.time_log_entry[] NOT NULL DEFAULT ARRAY[('','',1)::mg_traits.time_log_entry]::mg_traits.time_log_entry[];

COMMIT;     