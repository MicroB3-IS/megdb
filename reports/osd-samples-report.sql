

SET enable_seqscan TO off;


\pset null null

--explain analyze
CREATE TEMP TABLE iho_tagging AS
with iho_tagging AS (
SELECT DISTINCT ON (submission_id)
    osd_id,
    osd.start_lat,
    osd.start_lon,
    osd.label_verb as site_name,
    iho.label as iho_label,
    iho.id as iho_id,
    iho.gazetteer as mrgid,
  ST_AsText(
    st_closestpoint(iho.geom, osd.start_geom)
  ) as point_on_iho,
   ST_Distance(iho.geom, osd.start_geom) as dist

  FROM
     -- lines/polygones
     marine_regions_stage.iho AS iho
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    (ST_DWithin(osd.start_geom,iho.geom, 1))
ORDER BY
 submission_id, ST_Distance(osd.start_geom, iho.geom) 

)
select * from iho_tagging order by dist desc
;


\echo number of OSD samples:

select count(*) from osdregistry.samples;


\echo osd sites in the meditereanen

select * from iho_tagging 
 where iho_id 
    in ( 
          '28A', -- med sea western basin
          '28B', -- med seaeastern  basin
          '28a', -- strait gibraltar
          '28b', -- alboran sea
          '28c', -- balearic
          '28d', -- ligurien
          '28e', -- thyrr
          '28f', -- ion
          '28g', -- adriat
          '28h', -- aegean
          '28f' -- ion
       ) ;


\echo black sea (which is not med!)

select * from iho_tagging 
 where iho_id = '30';




\echo overview of sites within countries EEZ: 

Select array_agg(osd_id) as osd_ids, max(iso3_code) as iso3_code, count(country), country
  FROM
     -- lines/polygones
     marine_regions_stage.eez_land AS eez
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    (ST_intersects(osd.start_geom,eez.geom) )
  GROUP BY country
  ORDER BY count (country) DESC
;


\echo european site within countries EEZ
Select osd_id, osd.label_verb, iso3_code, country, changes, shape_length, shape_area
  FROM
     -- lines/polygones
     marine_regions_stage.eez_land AS eez
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    (ST_intersects(osd.start_geom,eez.geom) )
WHERE country in ('Bulgaria', 'Croatia',  'Finnland', 'France', 'Germany', 'Greece', 'Iceland','Italy','Norway', 'Portugal', 'Ukraine', 'United Kingdom', 'Slovenia', 'Spain');

;

\echo north america
Select osd_id, osd.label_verb, iso3_code, country, changes, shape_length, shape_area
  FROM
     -- lines/polygones
     marine_regions_stage.eez_land AS eez
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    (ST_intersects(osd.start_geom,eez.geom) )
WHERE country in ('Greenland', 'United States', 'Canada', 'Mexiko', 'Belize')

;


\echo num sites in norhtern hemisphere
select count(*) from osdregistry.samples where start_lat > 0;


\echo sites along portugal coast
\echo from gml of http://www.marineregions.org/gazetteer.php?p=details&id=25368





SET enable_seqscan TO on;
