
BEGIN;
SELECT _v.register_patch('00140-add-schema-tara-stage',
                          array['00139-add-osd-boundaries-tagging'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


CREATE SCHEMA tara_stage
  AUTHORIZATION megdb_admin;

GRANT USAGE ON SCHEMA tara_stage TO megxuser;
GRANT ALL ON SCHEMA tara_stage TO megx_team;
GRANT USAGE ON SCHEMA tara_stage TO students;
COMMENT ON SCHEMA tara_stage
  IS 'Staged Data from Marine Regions';

ALTER DEFAULT PRIVILEGES IN SCHEMA tara_stage
    GRANT SELECT ON TABLES
    TO megx_team;


SET search_path TO tara_stage,public;

CREATE TABLE tara_stage.gos_samples (
  label text PRIMARY KEY,
  local_date date,
  geog geography(POINT, 4326)
);


select AddGeometryColumn(
  'tara_stage',
  'gos_samples',
  'geom',
  4326,
  'POINT',
  2
);

INSERT INTO tara_stage.gos_samples (label, local_date, geom)
  SELECT label, date_taken, geom
    FROM core.samples
   WHERE study = 'gos';

UPDATE tara_stage.gos_samples SET geog = geom::geography;

CREATE INDEX gos_samples_geog_idx
    ON tara_stage.gos_samples
USING gist ( geog );    


CREATE MATERIALIZED VIEW tara_stage.gos_boundaries_tagging AS 
 WITH boundary AS (
      SELECT DISTINCT ON (gos.label)
             gos.label,
	     gos.local_date,
	     b.gid,
             b.iso3_code,
             st_distance(gos.geog, b.geog) as dist_m
        FROM elayers.boundary_polygons b
        JOIN tara_stage.gos_samples gos 
          ON ( st_dwithin(gos.geog, b.geog, 10000000::double precision) )
     ORDER BY label, st_distance(gos.geog, b.geog)
 )
 SELECT *
   FROM boundary b
  ORDER BY b.label DESC
;

ALTER TABLE tara_stage.gos_boundaries_tagging
  OWNER TO megdb_admin;

GRANT SELECT ON TABLE tara_stage.gos_boundaries_tagging
   TO megx_team WITH GRANT OPTION;

COMMENT ON MATERIALIZED VIEW tara_stage.gos_boundaries_tagging
  IS 'Distance of GOS sampling site to nearest country border taken as coastline based on elayers.boundaries.';



select * from tara_stage.gos_boundaries_tagging;

select count(*) from tara_stage.gos_samples;

commit;


