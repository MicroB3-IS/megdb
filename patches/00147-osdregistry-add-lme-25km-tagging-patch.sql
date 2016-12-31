
BEGIN;
SELECT _v.register_patch('00147-osdregistry-add-lme-25km-tagging',
                          array['00146-osdregistry-add-longhurst-36min-tagging'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

 
CREATE MATERIALIZED VIEW osdregistry.sample_lme_25km_tagging AS 
 WITH lme AS (
      SELECT DISTINCT ON (osd.submission_id)
	     osd.submission_id, 
             osd.osd_id,
             l.lme_name,
             st_distance(osd.start_geog, l.geog) as dist_m
        FROM marine_regions.lme l
        JOIN osdregistry.samples osd 
          ON ( st_dwithin(osd.start_geog, l.geog, 25000::double precision) )
     ORDER BY osd.submission_id, st_distance(osd.start_geog, l.geog)
 )
 SELECT *
   FROM lme
  ORDER BY lme.osd_id DESC
;

ALTER TABLE osdregistry.sample_lme_25km_tagging
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.sample_lme_25km_tagging TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.sample_lme_25km_tagging TO megx_team WITH GRANT OPTION;

COMMENT ON MATERIALIZED VIEW osdregistry.sample_lme_25km_tagging
  IS 'LME with 25km distance of OSD sampling site to nearest lme region from marine_regions.lme';


-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


