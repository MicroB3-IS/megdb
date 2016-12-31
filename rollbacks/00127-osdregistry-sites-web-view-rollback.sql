
BEGIN;

SELECT _v.unregister_patch( '00127-osdregistry-sites-web-view');


-- View: web_r8.osd_samplingsites

-- DROP VIEW web_r8.osd_samplingsites;

CREATE OR REPLACE VIEW web_r8.osd_samplingsites AS
 SELECT osd_data_2014_11_06.osd_id,
     osd_data_2014_11_06.site_name,
         osd_data_2014_11_06.site_coordinator,
	     osd_data_2014_11_06.institution,
	         osd_data_2014_11_06.country,
		     osd_data_2014_11_06.site_lat,
		         osd_data_2014_11_06.site_lon,
			     osd_data_2014_11_06.institution_lat,
			         osd_data_2014_11_06.institution_lon,
				     osd_data_2014_11_06.osd_group,
				         osd_data_2014_11_06.site_lat_prec2,
					     osd_data_2014_11_06.site_lon_prec2,
					         osd_data_2014_11_06.mb3partner,
						     osd_data_2014_11_06.site_geom,
						         osd_data_2014_11_06.institution_geom
							    FROM stage_r8.osd_data_2014_11_06;

ALTER TABLE web_r8.osd_samplingsites
  OWNER TO megdb_admin;
  GRANT ALL ON TABLE web_r8.osd_samplingsites TO megdb_admin;
  GRANT SELECT ON TABLE web_r8.osd_samplingsites TO megxuser;
  

commit;
