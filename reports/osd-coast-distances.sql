

Begin;


-- Materialized View: osdregistry.iho_tagging

-- DROP MATERIALIZED VIEW osdregistry.iho_tagging;

select 'createing mat view';

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


select 'done with mat view';

select * from osdregistry.sample_boundaries_tagging;


CREATE VIEW osdregistry.osd2014_boundary_distances AS
  SELECT osdregistry.osd_sample_label(sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol) AS label,
         tag.iso3_code, b.terr_name, tag.dist_m, extract
    FROM osdregistry.samples sam
         LEFT JOIN
	 osdregistry.sample_boundaries_tagging tag
         ON ( sam.submission_id = tag.submission_id
	    )
	 LEFT JOIN
	 elayers.boundaries b
	 ON (tag.gid = b.gid)
   WHERE sam.local_date is not null
	 and
	 sam.local_date BETWEEN '2014-04-01'::date AND '2014-08-01'::date 

;

select * from osdregistry.osd2014_boundary_distances;

rollback;
