
BEGIN;
SELECT _v.register_patch('75-new-esa-observation-view',
                          array['74-fix-elayer-permissions.sql'] );



ALTER TABLE elayers.world_regions OWNER TO megdb_admin;
GRANT SELECT ON TABLE elayers.world_regions TO megxuser;
 
ALTER TABLE esa.samples OWNER TO megdb_admin;
GRANT SELECT,UPDATE, DELETE,INSERT ON TABLE esa.samples TO megxuser;

ALTER TABLE esa.sample_images OWNER TO megdb_admin;
GRANT SELECT,UPDATE, DELETE,INSERT ON TABLE esa.sample_images TO megxuser;

-- now as megdb
set role megdb_admin;

		       
CREATE INDEX ON esa.samples
  USING gist
  (geom);

CREATE VIEW esa.observations AS

SELECT id, taken, modified, collector_id, osd.label, raw_data, barcode, 
       project_id, user_name, ship_name, nationality, elevation, biome, 
       feature, collection, permit, sampling_depth, water_depth, sample_size, 
       weather_condition, air_temperature, water_temperature, conductivity, 
       wind_speed, salinity, "comment", accuracy, 
       osd.geom, 
       st_y(osd.geom) as lat, 
       st_x(osd.geom) as lon,
       boat_manufacturer, 
       boat_model, boat_length, homeport, phosphate, nitrate, nitrite, 
       ph, secchi_depth, material, r.label as geo_region_label, r.region_type as geo_region_type

  FROM esa.samples osd LEFT JOIN elayers.world_regions r ON st_within(osd.geom, r.geom);


GRANT SELECT ON TABLE esa.observations TO megxuser;

-- just some test queries
-- select lat, lon, geo_region_label from esa.observations;

/*
SELECT s.collector_id,
		       s.modified,
		       s.label,
		       s.geo_region_label,

		                   (SELECT i.uuid
		                    FROM esa.sample_images AS i
		                    WHERE i.sid=s.id LIMIT 1)  AS uuid
		FROM esa.observations AS s
		ORDER BY s.modified DESC LIMIT 10;
*/

commit;
