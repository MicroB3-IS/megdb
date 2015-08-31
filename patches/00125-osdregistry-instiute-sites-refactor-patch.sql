
BEGIN;
SELECT _v.register_patch('00125-osdregistry-instiute-sites-refactor',
                          array['00124-osdregistry-add-campaign-key-table'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


ALTER TABLE osdregistry.campaign_tags ADD PRIMARY KEY (tag);


ALTER TABLE osdregistry.institute_sites RENAME osd_id TO id;

ALTER TABLE osdregistry.institute_sites
        ADD COLUMN campaign text REFERENCES osdregistry.campaign_tags;
	
UPDATE osdregistry.institute_sites SET campaign = 'OSD';

ALTER TABLE osdregistry.institute_sites ADD PRIMARY KEY (label,campaign,id);

ALTER TABLE osdregistry.institute_sites ALTER campaign SET NOT NULL, ALTER label SET NOT NULL;


-- for some test queries as user megxuser
-- SET ROLE megxuser;


--select * from osdregistry.institute_sites;

--\d osdregistry.institute_sites;
commit;


