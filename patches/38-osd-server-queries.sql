
BEGIN;

SELECT _v.register_patch('38-osd-server-queries', 
                          array['37-elayers-world-regions','35-esa-images-thumbnail']);


CREATE VIEW esa.oceans_sampled AS 
SELECT coalesce (iho.label, 'on land') as label, count(*) as count 
  FROM esa.samples as osd LEFT JOIN elayers.ocean_limits as iho  
    ON ST_within(osd.geom, iho.geom)					 
GROUP BY iho.label
;
REVOKE ALL ON esa.oceans_sampled FROM PUBLIC;
GRANT SELECt ON esa.oceans_sampled TO megxuser,selectors;

COMMENT ON VIEW esa.oceans_sampled IS 'Number of OSD samples per ocean as defined by IHO ocean limits';


commit;
