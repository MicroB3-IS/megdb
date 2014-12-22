
BEGIN;
SELECT _v.register_patch('00104-better-citizien-list',
                          array['00103-add-crated-citizen-list'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;
DROP VIEW esa.citizen_observations;
DROP TABLE esa.curated_citizen_observations;


CREATE TABLE esa.curated_citizen_observations AS 
   SELECT * 
    FROM esa.samples
   WHERE taken > '2014-06-19'
     AND taken < '2014-07-21'
     AND label NOT ilike '%osd%'
     and label not ilike '%fog%' 
     and label not ilike '%test%' 
     and label != '1'
     AND id not in ( '5f9e20dd-82ff-4247-97b6-6ac849eb8e9f',
'555a9965-9b93-4efc-9b4c-e252b8f6558c',
'a9beb8fcbf0a5d60:ac3c34a1-5631-4012-b14e-ca4bf72c8215',
'd0e9811c4a02e71e:acff175f-9d92-46a0-a58b-ac102696e0f5',
'c1bd2a70-26bc-433c-8289-756a0515ff01',
'6f5a6653-8121-4880-b348-627086189dae',
'40790FFF-CDAC-4D89-83D4-9F4B96D96BF0:e93ea201-bcc7-493e-b7a9-ae37ec9cad8f',
'40790FFF-CDAC-4D89-83D4-9F4B96D96BF0:3d1ebeba-62af-4160-8517-668837a5c25c',
'40790FFF-CDAC-4D89-83D4-9F4B96D96BF0:d2799cbc-1785-4e3e-a85c-60bc4602fcf9',
'40790FFF-CDAC-4D89-83D4-9F4B96D96BF0:10dc99bc-52ba-4634-b037-6d57925326e5',
'40790FFF-CDAC-4D89-83D4-9F4B96D96BF0:eca1d937-e75c-4190-a557-3224a779a701')
;

ALTER TABLE esa.curated_citizen_observations 
  ADD PRIMARY KEY (id);

GRANT select,delete on TABLE esa.curated_citizen_observations to megx_team;


create view esa.citizen_observations as 
   select s.*
     FROM esa.samples s
     JOIN esa.curated_citizen_observations 
    USING (id);

GRANT select on TABLE esa.curated_citizen_observations to megx_team;

--select * from esa.citizen_observations where collector_id ilike '%eliz%';


commit;


