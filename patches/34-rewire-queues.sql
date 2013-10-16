BEGIN;

SELECT _v.register_patch('34-rewire-queues', ARRAY['31-mg-traits'], NULL );

DROP TRIGGER mg_traits_jobs_i_to_queue ON mg_traits.mg_traits_jobs;
DROP TRIGGER i_to_queue ON core.blast_run;

SELECT pgq.create_queue('qsubq');

CREATE TRIGGER mg_traits_jobs_i_to_queue
  AFTER INSERT
  ON mg_traits.mg_traits_jobs
  FOR EACH ROW
  EXECUTE PROCEDURE pgq.logutriga('qsubq');
  
CREATE TRIGGER i_to_queue
  AFTER INSERT
  ON core.blast_run
  FOR EACH ROW
  EXECUTE PROCEDURE pgq.logutriga('qsubq');

COMMIT;