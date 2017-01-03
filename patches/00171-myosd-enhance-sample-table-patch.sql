
BEGIN;
SELECT _v.register_patch('00171-myosd-enhance-sample-table-patch',
                          array['00170-myosd-update-filter-collectors'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path = myosd,osdregistry,public;


ALTER table myosd.samples
  add column campaign text
             default ''
	     not null
	     check ( campaign in ('MyOSD-Jun-2015', 'MyOSD-Jun-2016', '') );


-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


