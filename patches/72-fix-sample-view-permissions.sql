
BEGIN;
SELECT _v.register_patch('72-fix-sample-view-permissions',
                          array['71-fix-sample-view-permissions'] );


ALTER TABLE web_r8.silva_102_regions OWNER TO megdb_admin;
ALTER TABLE web_r8.silva_102_samples OWNER TO megdb_admin;
ALTER TABLE web_r8.silva_samples OWNER TO megdb_admin;

ALTER TABLE web_r8.longhurst_regions OWNER TO megdb_admin;
ALTER TABLE web_r8.genome_reports OWNER TO megdb_admin;

ALTER TABLE web_r8.osd_samplingsites OWNER TO megdb_admin;

ALTER TABLE web_r8.tools OWNER TO megdb_admin;

ALTER TABLE web_r8.whale_falls OWNER TO megdb_admin;
ALTER TABLE web_r8.woa05_nitrate OWNER TO megdb_admin;

ALTER TABLE web_r8.woa05_oxygen_dissolved OWNER TO megdb_admin;

ALTER TABLE web_r8.woa05_oxygen_saturation OWNER TO megdb_admin;

ALTER TABLE web_r8.woa05_oxygen_utilization OWNER TO megdb_admin;

ALTER TABLE web_r8.woa05_phosphate OWNER TO megdb_admin;


ALTER TABLE web_r8.woa05_phosphate OWNER TO megdb_admin;

ALTER TABLE web_r8.woa05_silicate OWNER TO megdb_admin;

ALTER TABLE web_r8.woa05_temperature OWNER TO megdb_admin;

ALTER TABLE web_r8.world_regions OWNER TO megdb_admin;
commit;
