
BEGIN;
SELECT _v.register_patch('74-fix-elayer-permissions.sql',
                          array['73-stage_r8-permissions'] );

 ALTER TABLE elayers.boundaries OWNER TO megdb_admin;
 ALTER TABLE elayers.whale_falls OWNER TO megdb_admin;
 ALTER TABLE elayers.ocean_limits OWNER TO megdb_admin;
 ALTER TABLE elayers.standard_levels OWNER TO megdb_admin;
 ALTER TABLE elayers.marine_protected_area OWNER TO megdb_admin;
 ALTER TABLE elayers.seasons OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_oxygen_dissolved OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_nitrate OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_oxygen_dissolved_stability OWNER TO megdb_admin;
 ALTER TABLE elayers.country OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_silicate_stability OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_salinity_stability OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_salinity OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_temperature OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_phosphate_stability OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_oxygen_utilization_stability OWNER TO megdb_admin;
 ALTER TABLE elayers.wod05_osd_all OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_temperature_stability OWNER TO megdb_admin;
 ALTER TABLE elayers.chlorophyll OWNER TO megdb_admin;
 ALTER TABLE elayers.lake_quality_po OWNER TO megdb_admin;
 ALTER TABLE elayers.longhurst_regions OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_nitrate_stability OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_oxygen_saturation OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_oxygen_saturation_stability OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_oxygen_utilization OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_phosphate OWNER TO megdb_admin;
 ALTER TABLE elayers.woa05_silicate OWNER TO megdb_admin;

commit;
