
BEGIN;
SELECT _v.register_patch('00111-osdregistru-delete-func',
                          array['00110-full-osd-registry'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

CREATE FUNCTION osdregistry.deleteSample(id integer)
  RETURNS integer AS
$BODY$

  DELETE FROM osdregistry.owned_by where sample_id = id;
  DELETE FROM osdregistry.filters where sample_id = id;
  DELETE FROM osdregistry.samples where submission_id = id returning submission_id::integer;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


select osdregistry.deleteSample(id) 
 from osdregistry.osd_raw_samples 
 where id in (60,61,62,65,67,68,69,70);

-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


