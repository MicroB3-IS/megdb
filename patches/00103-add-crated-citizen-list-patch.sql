
BEGIN;
SELECT _v.register_patch('00103-add-crated-citizen-list',
                          array['00102-pubmap-add-columns'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

CREATE TABLE esa.curated_citizen_observations AS 
   SELECT * 
    FROM esa.samples
   WHERE taken > '2014-06-19'
     AND taken < '2014-07-21'
     AND label NOT ilike '%osd%'
     and label not ilike '%fog%' 
     and label not ilike '%test%' 
     and label != '1'
;

GRANT select,delete on TABLE esa.curated_citizen_observations to megx_team;


create view esa.citizen_observations as 
   select s.*
     FROM esa.samples s
     JOIN esa.curated_citizen_observations 
    USING (id);

GRANT select on TABLE esa.curated_citizen_observations to megx_team;


commit;


