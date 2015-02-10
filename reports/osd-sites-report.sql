
/*
Wir müssen präzise die sites (also dort wo gesampled wird) von den Instituten auseinander halten:

105 sites in Euripoe (meinste jetzt sites in europaeischen Gewaessern, d.h. sites in den jeweiligen EEZ) oder Anzahl Europäischer Institute (wo auch immer deren sites sind)?

34 sites in North America (s. Punkt drueber)

171 sites in the Northers Hermisphere (ich denke Du meinst hier jetzt sites, s. Punkt drueber)

37 in Mediterranean and Black Sea (unmissverständlich klar)

13 sites along the western coast of Portugal ( (unmissverständlich klar).
*/



--sites per ocean region

--CREATE OR REPLACE VIEW esa.oceans_sampled AS 
 SELECT COALESCE(iho.label, 'on land'::character varying) AS label, 
    count(*) AS count
   FROM osdregistry.sites osd
   LEFT JOIN elayers.ocean_limits iho ON st_dwithin(osd.geom, iho.geom, 0.001)
  GROUP BY iho.label limit 2;

--find the nearest ocean to each site
--DISTINCT ON (s.gid) 
SELECT 
        iho.label, osd.id, osd.label_verb, ST_Distance(osd.geom, iho.geom)
	FROM osdregistry.sites as osd
		LEFT JOIN elayers.ocean_limits as iho ON ST_DWithin(osd.geom, iho.geom, 0.01)
	ORDER BY osd.id, ST_Distance(osd.geom, iho.geom);



/*
SELECT
  pt_id,
  ln_id,
  ST_AsText(
    ST_line_interpolate_point(
     ln_geom,
     ST_line_locate_point(ln_geom, pt_geom?)
    )
  )
FROM
(
 SELECT DISTINCT ON (pt.id)
ln.the_geom AS ln_geom,
pt.the_geom AS pt_geom,
ln.id AS ln_id,
pt.id AS pt_id
FROM
point_table pt INNER JOIN
line_table ln
ON
ST_DWithin(pt.the_geom, ln.the_geom, 10.0)
ORDER BY
pt.id,ST_Distance(ln.the_geom, pt.the_geom)
) AS subquery; 



WITH dists AS (

  SELECT
    ln.geom AS ln_geom,
    pt.geom AS pt_geom
  FROM
    (VALUES ( geomfromtext('POINT(0.3 0.2)', 4326) ),( geomfromtext('POINT(10 10)', 4326) ) ) as pt(geom) 
  INNER JOIN
    (VALUES (geomfromtext('LINESTRING(0 0, 1 1, 2 2)', 4326) )) as ln(geom) 
  ON
    ST_DWithin(pt.geom, ln.geom, 10.0)
ORDER BY
 ST_Distance(ln.geom, pt.geom)


)
SELECT
  ST_AsText(
    ST_line_interpolate_point(
     ln_geom,
      ST_line_locate_point(ln_geom, pt_geom)
    )
  ),
   ST_Distance(ln_geom, pt_geom) as dist
 from dists; 
--*/