
BEGIN;
SELECT _v.register_patch('00146-osdregistry-add-longhurst-36min-tagging',
                          array['00145-osdregistry-add-iho-25km-tagging'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


CREATE MATERIALIZED VIEW osdregistry.sample_longhurst_36min_tagging AS 
 WITH longhurst AS (
      SELECT DISTINCT ON (osd.submission_id)
	     osd.submission_id, 
             osd.osd_id,
	     l.prov_code,
             l.prov_descr,
             st_distance(osd.start_geom, l.geom) as dist_degrees
        FROM marine_regions.longhurst l
        JOIN osdregistry.samples osd 
          ON ( st_dwithin(osd.start_geom, l.geom, 0.6::double precision) )
     ORDER BY osd.submission_id, st_distance(osd.start_geom, l.geom)
 )
 SELECT *
   FROM longhurst lh
  ORDER BY lh.osd_id DESC
;

ALTER TABLE osdregistry.sample_longhurst_36min_tagging
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.sample_longhurst_36min_tagging TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.sample_longhurst_36min_tagging TO megx_team WITH GRANT OPTION;

COMMENT ON MATERIALIZED VIEW osdregistry.sample_longhurst_36min_tagging
  IS 'Nearest distance of OSD sampling site to longhurst region/province on marine_regions.longhurst within 0.6 degress lat/lon';


-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


