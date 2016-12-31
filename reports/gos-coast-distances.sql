
Begin;


CREATE MATERIALIZED VIEW osdregistry.sample_boundaries_tagging AS 
 WITH boundary AS (
      SELECT DISTINCT ON (osd.submission_id)
	     osd.submission_id, 
             osd.osd_id,
	     b.gid,
             b.iso3_code,
             st_distance(osd.start_geog, b.geog) as dist_m
        FROM elayers.boundary_polygons b
        JOIN osdregistry.samples osd 
          ON ( st_dwithin(osd.start_geog, b.geog, 1000000::double precision) )
     ORDER BY osd.submission_id, st_distance(osd.start_geog, b.geog)
 )
 SELECT *
   FROM boundary b
  ORDER BY b.osd_id DESC
;

ALTER TABLE osdregistry.sample_boundaries_tagging
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.sample_boundaries_tagging TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.sample_boundaries_tagging TO megx_team WITH GRANT OPTION;

COMMENT ON MATERIALIZED VIEW osdregistry.sample_boundaries_tagging
  IS 'Distance to OSD sampling site to nearest country border taken as coastline based on elayers.boundaries.';

rollback;
