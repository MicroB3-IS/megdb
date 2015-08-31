
BEGIN;
SELECT _v.register_patch('00124-osdregistry-add-campaign-key-table',
                          array['00123-osdregistry-sites-fix-lat-lon-sync-trigger'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


CREATE TABLE osdregistry.campaign_tags (

  tag text NOT NULL,
  descr text NOT NULL DEFAULT ''
);
REVOKE ALL ON osdregistry.campaign_tags FROM public;

GRANT SELECT on osdregistry.campaign_tags to megx_team;


INSERT INTO osdregistry.campaign_tags (tag)
  VALUES ('OSD'),('MyOSD'),('RSD'); 

-- for some test queries as user megxuser
SET ROLE megx_team;

select * from osdregistry.campaign_tags ;


commit;


