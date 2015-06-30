

begin;
SET enable_seqscan TO off;

\pset null null


--select st_x(geom) as lon, st_y(geom) as lat from marine_regions_stage.longhurst order by st_x(geom), st_y(geom)
--;

--"ProvCode" varchar(5),
--"ProvDescr" varchar(100));

--explain analyze
/*
CREATE TEMP TABLE longhurst_tagging AS

  SELECT submission_id, "ProvCode" as provcode, "ProvDescr" as provdescr
  FROM
     -- lines/polygones
     marine_regions_stage.longhurst AS lh
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    ( ST_intersects(osd.start_geom,lh.geom) )

;
*/


CREATE TEMP TABLE longhurst_tagging AS
  WITH lh_tagging AS (
  SELECT DISTINCT ON (submission_id)
    submission_id,
    osd_id,
    osd.start_lat,
    osd.start_lon,
    osd.label_verb as site_name,
    lh."ProvCode" as provcode,
    lh."ProvDescr" as provdescr,
    lh.gid as lh_id,
  ST_AsText(
    st_closestpoint(lh.geom, osd.start_geom)
  ) as point_on_lh,
   ST_Distance(lh.geom, osd.start_geom) as dist

  FROM
     -- lines/polygones
     marine_regions_stage.longhurst AS lh
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    ( ST_DWithin(osd.start_geom, lh.geom, 0.3))
ORDER BY
 submission_id, ST_Distance(osd.start_geom, lh.geom) 

)
select * from lh_tagging order by dist desc
;


\copy (select osdregistry.osd_sample_label( sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol::text ) as osd_label, s.label_verb as site_name, sam.start_lat as latitude, sam.start_lon as longtitude, lh.provcode, lh.provdescr, lh.dist as distance_degrees from longhurst_tagging lh right join osdregistry.samples sam on (sam.submission_id = lh.submission_id) inner join osdregistry.sites s ON (s.id = sam.osd_id)  ) to '/home/renzo/src/megdb/reports/osd2014-longurst-report.csv' CSV DELIMITER '|' HEADER;

SET enable_seqscan TO on;


rollback;