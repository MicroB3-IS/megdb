

BEGIN;


SET SEARCH_PATH TO mg_traits,public;

CREATE OR REPLACE VIEW job_time_protocols AS

SELECT j.main_job as job_id, 
       j.time_submitted,
       j.time_started,
       j.time_finished,
       total_run_time,
       split_part(comment, ':', 1) as job_part, 
       run_time 
  FROM (select j.job_id as main_job, j.time_started, j.time_finished,j.total_run_time,j.time_submitted,  (unnest(time_protocol)).* 
          from mg_traits_jobs j
          WHERE j.return_code = 0
       ) j 
 WHERE job_id <> '';


select * from job_time_protocols order by time_finished - time_started DESC;

select job_part, 
       avg(time_started - time_submitted ) as avg_queue_time,
       --avg(time_finished - time_started) as avg_cluster_time,
       avg(run_time) * '1 second'::interval as avg_run_time
       --avg(time_finished - time_submitted) as avg_total_run_time,
       --stddev( run_time) * '1 second'::interval as std
  from job_time_protocols
GROUP by job_part;


ROLLBACK;