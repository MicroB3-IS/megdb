
BEGIN;
SELECT _v.register_patch('00143-osd-lme-longhurst-tagging',
                          array['00142-osd-2014-bioarchive-codes-add'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path to osdregisry, public;


CREATE SCHEMA marine_regions
  AUTHORIZATION megdb_admin;

GRANT USAGE ON SCHEMA marine_regions TO megxuser;
GRANT ALL ON SCHEMA marine_regions TO megx_team;
GRANT USAGE ON SCHEMA marine_regions TO students;
COMMENT ON SCHEMA marine_regions
  IS 'Data from Marine Regions';

ALTER DEFAULT PRIVILEGES IN SCHEMA marine_regions
    GRANT SELECT ON TABLES
    TO megx_team;


CREATE TABLE marine_regions.longhurst AS
  SELECT gid, "ProvCode" as prov_code,
         "ProvDescr" as prov_descr, geom
   FROM marine_regions_stage.longhurst;

--select * from marine_regions.longhurst;

CREATE TABLE marine_regions.lme AS
  SELECT gid, "OBJECTID" as object_id,
         "LME_NUMBER" as lme_num,
	 "LME_NAME" as lme_name,
	 "Shape_Leng" as shape_length,
	 "Shape_Area" as shape_area, 
         geom
    FROM marine_regions_stage.lme;


ALTER TABLE marine_regions.lme
  ADD COLUMN geog geography(MultiPolygon,4326);
UPDATE marine_regions.lme
   set geog = geom::geography;


CREATE MATERIALIZED VIEW osdregistry.sample_longhurst_tagging AS 
 WITH longhurst AS (
      SELECT DISTINCT ON (osd.submission_id)
	     osd.submission_id, 
             osd.osd_id,
	     l.prov_code,
             l.prov_descr,
             st_distance(osd.start_geom, l.geom) as dist_degrees
        FROM marine_regions.longhurst l
        JOIN osdregistry.samples osd 
          ON ( st_dwithin(osd.start_geom, l.geom, 0.5::double precision) )
     ORDER BY osd.submission_id, st_distance(osd.start_geom, l.geom)
 )
 SELECT *
   FROM longhurst lh
  ORDER BY lh.osd_id DESC
;

ALTER TABLE osdregistry.sample_longhurst_tagging
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.sample_longhurst_tagging TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.sample_longhurst_tagging TO megx_team WITH GRANT OPTION;

COMMENT ON MATERIALIZED VIEW osdregistry.sample_longhurst_tagging
  IS 'Distance of OSD sampling site to nearest longhurst egeion/province on marine_regions.longhurst';


 
CREATE MATERIALIZED VIEW osdregistry.sample_lme_tagging AS 
 WITH lme AS (
      SELECT DISTINCT ON (osd.submission_id)
	     osd.submission_id, 
             osd.osd_id,
             l.lme_name,
             st_distance(osd.start_geog, l.geog) as dist_m
        FROM marine_regions.lme l
        JOIN osdregistry.samples osd 
          ON ( st_dwithin(osd.start_geog, l.geog, 10000::double precision) )
     ORDER BY osd.submission_id, st_distance(osd.start_geog, l.geog)
 )
 SELECT *
   FROM lme
  ORDER BY lme.osd_id DESC
;

ALTER TABLE osdregistry.sample_lme_tagging
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.sample_lme_tagging TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.sample_lme_tagging TO megx_team WITH GRANT OPTION;

COMMENT ON MATERIALIZED VIEW osdregistry.sample_lme_tagging
  IS 'Distance of OSD sampling site to nearest lme region from marine_regions.lme';




--select * from osdregistry.sample_longhurst_tagging where osd_id in (10,90);

--select * from osdregistry.sample_lme_tagging where osd_id in (10,90);

commit;
