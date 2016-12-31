
BEGIN;
SELECT _v.register_patch('00164-osd2015-integration',
                          array['00163-myosd-collectors-table'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path to osdregistry,public;


CREATE OR REPLACE VIEW submission_overview_osd2015 AS 
  SELECT so.raw_json #>> '{sampling_site,campaign}' as campaign, so.*
   FROM osdregistry.submission_overview so
  WHERE so.raw_json #>> '{sampling_site,campaign}' = 'OSD-June-2015'
        AND
	submitted > '2015-06-01'::date
	and
	submission_id > 295
;

-- select * from submission_overview_osd2015;

CREATE OR REPLACE VIEW submission_overview_osd2015_new AS
  SELECT o.*
    FROM submission_overview_osd2015 o
         LEFT JOIN osdregistry.samples s ON s.submission_id = o.submission_id
  WHERE s.submission_id IS NULL;

-- select * from filters;

-- for some test queries as user megxuser
-- SET ROLE megxuser;

commit;


