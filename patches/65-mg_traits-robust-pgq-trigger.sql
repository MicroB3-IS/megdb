Begin;

SELECT _v.register_patch('65-mg_traits-robust-pgq-trigger',
                          array['64-mg-traits-fix-unique-job-issues'] );

set search_path to mg_traits;

-- expecting 0 updates, but more robust
UPDATE mg_traits_jobs 
  SET return_code = -1 
WHERE return_code is null;

ALTER TABLE mg_traits_jobs 
  ADD CONSTRAINT return_code_chek CHECK (return_code >= -1),
  ALTER COLUMN return_code SET DEFAULT -1;


DROP TRIGGER mg_traits_jobs_i_to_queue ON mg_traits.mg_traits_jobs;

SELECT pgq.create_queue('qsubq');

CREATE TRIGGER mg_traits_jobs_i_to_queue
  AFTER INSERT
  ON mg_traits.mg_traits_jobs
  FOR EACH ROW
  -- only execute job if it is 'new' row 
  -- i.e. a non worked on job
  -- this makes it amneable to insert new rows from other DB 
  -- the data content
  WHEN (NEW.return_code = -1)
  EXECUTE PROCEDURE pgq.logutriga('qsubq');

commit;
