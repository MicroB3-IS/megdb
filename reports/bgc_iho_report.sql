

Begin;
\pset null null

CREATE TEMP TABLE  iho_tagging  AS
with iho_tagging AS (
SELECT DISTINCT ON (submission_id)
    osd.osd_id,
    osd.start_lat,
    osd.start_lon,
    osd.label_verb as site_name,
    osd.water_depth,
    osd.start_geom as geom,
    iho.label as iho_label,
    iho.id as iho_id,
    iho.gazetteer as mrgid,
  ST_AsText(
    st_closestpoint(iho.geom, osd.start_geom)
  ) as point_on_iho,
   ST_Distance(iho.geom, osd.start_geom) as dist

  FROM
    osdregistry.ena_datasets ena
  INNER JOIN
     -- points
     osdregistry.samples osd
   ON (ena.sample_id = osd.submission_id AND ena.cat = 'shotgun')
  INNER JOIN
     -- lines/polygones
     marine_regions_stage.iho AS iho

  ON
    (ST_DWithin(osd.start_geom,iho.geom, 0.5))
WHERE protocol = 'NPL022' and date_part('year', osd.local_date) >= 2014::double precision
ORDER BY
 submission_id, ST_Distance(osd.start_geom, iho.geom) 

)
select * from iho_tagging order by dist asc
;



-- select * from iho_tagging order by dist desc;


drop table if exists region_tags;

CREATE TEMP TABLE  region_tags  (
    osd_id integer ,
    start_lat double precision,
    start_lon double precision,
    site_name  text,
    water_depth numeric,
    region_name text,
    PRIMARY KEY (osd_id, water_depth,region_name)

);


\echo number of OSD samples:

select count(*) from osdregistry.samples;


\echo osd sites in the meditereanen

INSERT INTO region_tags 
 SELECT
    osd_id,
    start_lat,
    start_lon,
    site_name,
    water_depth,
    'Mediterranean Sea'  
  FROM iho_tagging 
 WHERE iho_id 
    IN ( 
          '28A', -- med sea western basin
          '28B', -- med seaeastern  basin
          '28a', -- strait gibraltar
          '28b', -- alboran sea
          '28c', -- balearic
          '28d', -- ligurien
          '28e', -- thyrr
          '28f', -- ion
          '28g', -- adriat
          '28h' -- aegean
       ) 
;



INSERT INTO region_tags 
 SELECT
    osd_id,
    start_lat,
    start_lon,
    site_name,
    water_depth,
    'West Mediterranean Sea'  
  FROM iho_tagging 
 WHERE iho_id 
    IN ( 
          '28A', -- med sea western basin
          '28a', -- strait gibraltar
          '28b', -- alboran sea
          '28c', -- balearic
          '28d', -- ligurien
          '28e' -- thyrr
       ) 
;



INSERT INTO region_tags 
 SELECT
    osd_id,
    start_lat,
    start_lon,
    site_name,
    water_depth,
    'EAST Mediterranean Sea'  
  FROM iho_tagging 
 WHERE iho_id 
    IN ( 
          '28B', -- med seaeastern  basin
          '28g', -- adriat
          '28h', -- aegean
          '28f' -- ion
       ) 
;



/*
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
--*/




INSERT INTO region_tags 
 SELECT
    osd_id,
    start_lat,
    start_lon,
    site_name,
    osd.water_depth,
    'Belgium'  
  FROM
     -- lines/polygones
     marine_regions_stage.eez_land AS eez
  INNER JOIN
     -- points
     iho_tagging osd 
  ON
    (ST_intersects(osd.geom,eez.geom) )
WHERE country in ('Belgium')
;



INSERT INTO region_tags 
 SELECT
    osd_id,
    start_lat,
    start_lon,
    site_name,
    osd.water_depth,
    'US East Coast'  
  FROM
     -- lines/polygones
     marine_regions_stage.eez_land AS eez
  INNER JOIN
     -- points
     iho_tagging osd 
  ON
    (ST_intersects(osd.geom,eez.geom) )
WHERE country in ('United States')
   AND st_x(osd.geom) > -81.5

;


--/*
INSERT INTO region_tags 
 SELECT
    osd_id,
    start_lat,
    start_lon,
    site_name,
    water_depth,
    'North Atlantic'  
  FROM iho_tagging 
 WHERE iho_label
    IN ( 
          'Greenland Sea', 
          'Norwegian Sea', 
          'Celtic Sea', 
          'Bay of Biscay', 
          'Labrador Sea', 
          'North Atlantic Ocean', 
          'Gulf of Guinea' 
       ) 
;
--*/




--select * from region_tags order by region_name;

\COPY region_tags TO '/tmp/bgc_super_cat.csv' WITH (format csv, header, delimiter '|');


rollback;
