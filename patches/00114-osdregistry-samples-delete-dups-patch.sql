
BEGIN;
SELECT _v.register_patch('00114-osdregistry-samples-delete-dups',
                          array['00113-osdregistry-filter-curation-trg'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

select osdregistry.deletesample( f.i ) 
  FROM (values (7),(112),(63),(72),(73),(74),(75),(76),(217),(161),(162),(163),(102),(127),(138),(159),(95),(111),(113),(118),(119),(232),(167),(252),(253),(19),(20),(23),(25),(202),(203),(242) ) as f(i);  

-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


