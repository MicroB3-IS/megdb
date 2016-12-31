
BEGIN;

SELECT _v.register_patch('00138-add-boundaries-polygon-table-elayers',
                          array['00137-osdregistry_new_sample_env_view'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

create table elayers.boundary_polygons (
  gid integer REFERENCES elayers.boundaries,
  iso3_code text,
  geog geography(Polygon,4326)
);


select AddGeometryColumn(
  'elayers',
  'boundary_polygons',
  'geom',
  4326,
  'POLYGON',
  2
);

Insert into elayers.boundary_polygons  (gid,iso3_code, geom)
    SELECT gid, iso3_code, (ST_DUMP(geom)).geom AS geom FROM elayers.boundaries;


update elayers.boundary_polygons set geog = geom::geography;

select 'creating idx';

CREATE INDEX boundary_polygons_geog_idx ON elayers.boundary_polygons USING GIST ( geog );

-- for some test queries as user megxuser
-- SET ROLE megxuser;

COMMENT ON TABLE  elayers.boundary_polygons
  IS 'Materialzed decomposition of boundaries multipolygon into single polygons';

CLUSTER elayers.boundary_polygons USING boundary_polygons_geog_idx;  

commit;


