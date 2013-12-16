BEGIN;

SELECT _v.register_patch('40-gendb-pipe', NULL, NULL);

CREATE SCHEMA gendbpipe;

CREATE TABLE gendbpipe.gendbpipe_jobs
(
  customer text,
  url text NOT NULL UNIQUE,
  sample_label text NOT NULL UNIQUE,
  sample_environment text,
  time_submitted timestamp with time zone NOT NULL DEFAULT now(),
  time_finished timestamp with time zone,
  make_public interval NOT NULL DEFAULT '00:00:00'::interval,
  keep_data interval NOT NULL DEFAULT '7 days'::interval,
  time_started timestamp with time zone,
  cluster_node text,
  job_id integer,
  return_code integer,
  error_message text,
  total_run_time numeric DEFAULT 0::numeric,
  CONSTRAINT gendbpipe_jobs_pkey PRIMARY KEY (url, sample_label),
  CONSTRAINT gendbpipe_jobs_customer_fkey FOREIGN KEY (customer)
      REFERENCES auth.users (logname)
);

CREATE TABLE gendbpipe.gendbpipe_results(
  seqid TEXT,
  source TEXT,
  type TEXT,
  start_pos INT,
  end_pos INT,
  score NUMERIC,
  strand CHAR(1),
  phase CHAR(1),
  attributes TEXT
);

CREATE TRIGGER gendbpipe_jobs_i_to_queue
  AFTER INSERT
  ON gendbpipe.gendbpipe_jobs
  FOR EACH ROW
  EXECUTE PROCEDURE pgq.logutriga('qsubq');


COMMIT;