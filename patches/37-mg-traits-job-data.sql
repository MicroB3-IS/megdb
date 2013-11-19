
BEGIN;

SELECT _v.register_patch('37-mg-traits-job-data', 
                          array['8-authdb','31-mg-traits', '34-new-mg-traits' ] );

ALTER TABLE mg_traits.mg_traits_jobs
  ADD COLUMN time_started TIMESTAMP WITH TIME ZONE,
  ADD COLUMN cluster_node TEXT,
  ADD COLUMN job_id INT CHECK (job_id > 0);

COMMIT;                          