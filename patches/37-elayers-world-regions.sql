
BEGIN;
   
SELECT _v.register_patch('37-elayers-world-regions', 
                          null );

CREATE VIEW elayers.world_regions AS

  SELECT boundaries.gid::text AS gid,
            boundaries.terr_name AS label,
            boundaries.geom,
            'country'::text AS region_type
    FROM elayers.boundaries
    UNION
  SELECT ocean_limits.iho_id AS gid,
         ocean_limits.label,
         ocean_limits.geom,
         'water'::text AS region_type
    FROM elayers.ocean_limits
;

COMMIT;
