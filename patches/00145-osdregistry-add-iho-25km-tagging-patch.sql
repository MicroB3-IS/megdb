
BEGIN;
SELECT _v.register_patch('00145-osdregistry-add-iho-25km-tagging',
                          array['00144-osd-env-view'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

CREATE MATERIALIZED VIEW osdregistry.iho_25km_tagging AS 
 WITH iho AS (
         SELECT DISTINCT ON (osd.submission_id) osd.submission_id, 
            osd.osd_id, 
            iho_1.label AS iho_label, 
            iho_1.id AS iho_id, 
            iho_1.gazetteer AS mrgid, 
            st_distance(iho_1.geog, osd.start_geog) AS dist
           FROM marine_regions_stage.iho iho_1
      JOIN osdregistry.samples osd ON st_dwithin(osd.start_geog, iho_1.geog, 25000::double precision)
     ORDER BY osd.submission_id, st_distance(osd.start_geog, iho_1.geog)
        )
 SELECT iho.submission_id, 
    iho.osd_id, 
    iho.iho_label, 
    iho.iho_id, 
    iho.mrgid, 
    iho.dist
   FROM iho
  ORDER BY iho.dist DESC
WITH DATA;

ALTER TABLE osdregistry.iho_25km_tagging
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.iho_25km_tagging TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.iho_25km_tagging TO megx_team WITH GRANT OPTION;
COMMENT ON MATERIALIZED VIEW osdregistry.iho_25km_tagging
  IS 'IHO name and mgrid for each OSD sample with a distance of 25 or less km from an IHO region';


-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


