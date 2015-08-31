
BEGIN;
SELECT _v.register_patch('00128-osdregistry-sites-update-labels',
                          array['00127-osdregistry-sites-web-view'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;

update osdregistry.sites set label = label_verb where label = '' returning id, label, label_verb;



commit;

