
BEGIN;
SELECT _v.register_patch('00177-myosd-biome-correction',
                          array['00176-international-myosd2016-integration'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

update myosd.samples set biome_verb = 'Coastal sea area'
 where (biome_verb ~* 'Coastel sea area'
       OR biome_verb ilike 'Coastal area%'
       OR biome_verb ilike 'Coastal sea%'
       OR biome_verb ilike 'Coastal site%')
       AND biome = 'biome'
  RETURNING myosd_id, biome, biome_verb, submitted;



update myosd.samples
   set biome_verb =  initcap ( substring( biome_verb from '(\w+)') )
         || lower( substring( biome_verb from '\w+(.*)' ) )
  where biome  in ('biome')
  RETURNING myosd_id, biome, biome_verb, submitted;


update myosd.samples set biome = biome_verb
 where biome = 'biome'
       AND
       myosd_id NOT IN (10,21,46,173,179,206,209,217,250,1380,1382)
  RETURNING myosd_id, biome, biome_verb, submitted;


-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;
