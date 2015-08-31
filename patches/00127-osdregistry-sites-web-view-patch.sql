
BEGIN;
SELECT _v.register_patch('00127-osdregistry-sites-web-view',
                          array['00126-osdregistry-add-site-func'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- DROP VIEW web_r8.osd_samplingsites;

CREATE OR REPLACE VIEW web_r8.osd_samplingsites AS
 SELECT site.id::text as osd_id,
        site.label as site_name,
        ''::text as site_coordinator,
	i.label as institution,
	i.country,
	site.lat::text as site_lat,
	site.lon::text as site_lon,
	i.lat::text as institution_lat,
	i.lon::text as institution_lon,
	''::text as osd_group,
	site.lat::text as site_lat_prec2,
	site.lon::text as site_lon_prec2,
	null::boolean as mb3partner,
	site.geom as site_geom,
	i.geom as institution_geom
  FROM osdregistry.sites site
 INNER JOIN osdregistry.institute_sites insite ON (site.id = insite.id AND insite.campaign = 'OSD')
 INNER JOIN osdregistry.institutes i ON (insite.label = i.label)
; 
ALTER TABLE web_r8.osd_samplingsites
  OWNER TO megdb_admin;
  GRANT ALL ON TABLE web_r8.osd_samplingsites TO megdb_admin;
  GRANT SELECT ON TABLE web_r8.osd_samplingsites TO megxuser;
  

-- for some test queries as user megxuser
SET ROLE megxuser;

select * from web_r8.osd_samplingsites order by osd_id::integer desc;

select count(*) from web_r8.osd_samplingsites ;


commit;


