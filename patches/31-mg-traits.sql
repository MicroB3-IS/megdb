
BEGIN;

SELECT _v.register_patch('31-mg-traits' , NULL, NULL );

CREATE schema mg_traits;

SET search_path to mg_traits,core;

CREATE TABLE mg_traits_jobs (
  customer text REFERENCES auth.users(logname),
  mg_url text UNIQUE,
  sample_label text UNIQUE,
  sample_environment text,
  time_submitted timestamp with time zone NOT NULL DEFAULT now(), -- date and time of job submission
  time_finished timestamp with time zone  NOT NULL DEFAULT 'infinity'::timestamp, -- date and time of job finished
  PRIMARY KEY (mg_url, sample_label)
);


select pgq.create_queue('clusterjobq');

CREATE TRIGGER mg_traits_jobs_i_to_queue
  AFTER INSERT
  ON mg_traits.mg_traits_jobs
  FOR EACH ROW
  EXECUTE PROCEDURE pgq.logutriga('clusterjobq');


CREATE TABLE mg_traits_results (
   sample_label text REFERENCES mg_traits_jobs(sample_label),
   gc_content numeric NOT NULL DEFAULT 'NaN',
   gc_variance numeric NOT NULL DEFAULT 'NaN',
   PRIMARY KEY(sample_label)
);


-- testing
COMMIT;

BEGIN;

INSERT INTO  mg_traits.mg_traits_jobs VALUES ('anonymous', 'http://www.megx.net','test-sample', 'marine');

ROLLBACK;


