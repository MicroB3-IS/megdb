
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
/*
 SELECT COALESCE(iho.label, 'on land'::character varying) AS label, 
    count(*) AS count
   FROM osdregistry.sites osd
   LEFT JOIN elayers.ocean_limits iho ON st_dwithin(osd.geom, iho.geom, 0.001)
  GROUP BY iho.label limit 2;
*/

--find the nearest ocean to each site
--DISTINCT ON (s.gid) 
/*
SELECT 
        iho.label, osd.id, osd.label_verb, ST_Distance(osd.geom, iho.geom)
	FROM osdregistry.sites as osd
		LEFT JOIN elayers.ocean_limits as iho ON ST_DWithin(osd.geom, iho.geom, 0.01)
	ORDER BY osd.id, ST_Distance(osd.geom, iho.geom);
*/

SET enable_seqscan TO off;

/*
SELECT
  id,
  iho_label,
  ST_AsText(
    st_closestpoint(iho_geom, osd_geom)
  ) as point_on_iho,
   ST_Distance(iho_geom, osd_geom) as dist
FROM
  (  SELECT DISTINCT ON (osd.id)
    osd.id,
    iho.geom as iho_geom,
    osd.geom as osd_geom,
    iho.label as iho_label
  FROM
     -- lines/polygones
     elayers.ocean_limits iho
  INNER JOIN
     -- points
     osdregistry.sites osd
  ON
    ST_DWithin(osd.geom,iho.geom, 0.4)
ORDER BY
 osd.id, ST_Distance(osd.geom, iho.geom)
OFFSET 0
) as subquery; 
--*/


explain analyze
SELECT DISTINCT ON (osd.id)
    osd.id,
    iho.label as iho_label,
  ST_AsText(
    st_closestpoint(iho.geom, osd.geom)
  ) as point_on_iho,
   ST_Distance(iho.geom, osd.geom) as dist

  FROM
     -- lines/polygones
     elayers.ocean_limits AS iho
  INNER JOIN
     -- points
     osdregistry.sites osd
  ON
    (st_isvalid(iho.geom) AND ST_DWithin(osd.geom,iho.geom, 0.4))
ORDER BY
 osd.id, ST_Distance(osd.geom, iho.geom)
OFFSET 0; 





--dists order by id; 

--*/
SET enable_seqscan TO on;
