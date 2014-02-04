BEGIN;

SELECT _v.register_patch('46-osd-registry-view-permission', 
                          array['41-osd-registry-url-change.sql','44-auth-user-defaults' ] );


ALTER TABLE osdregistry.osd_participants OWNER TO megdb_admin;

CREATE OR REPLACE VIEW web_r8.osd_participants as 
  SELECT id, osd_id, site_name, 
         site_lat, site_long, institution, institution_lat, 
         institution_long, institution_address, institution_web_address, 
         site_coordinator, coordinator_email, country
  FROM osdregistry.osd_participants;

ALTER TABLE web_r8.osd_participants OWNER TO megdb_admin;
GRANT SELECT ON TABLE web_r8.osd_participants TO megxuser;
GRANT SELECT ON TABLE web_r8.osd_participants TO megx_team;

commit; 
