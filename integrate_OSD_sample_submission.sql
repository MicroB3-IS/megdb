
begin;



SELECT osdregistry.integrate_sample_submission(
            osdregistry.parse_sample_submission(
                  sub.raw_json,
                  sub.submission_id,
                  sub.version,
                  sub.submitted,
                  null
            )
        )
  FROM osdregistry.submission_overview_osd2015 sub
 WHERE sub.submission_id IN (887) ;


--select * from osdregistry.samples where submission_id = 887;

rollback;