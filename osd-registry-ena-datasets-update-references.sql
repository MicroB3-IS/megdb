

BEGIN;

-- make several path updates
UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id ,
       ena.osd_id = s.osd_id
  FROM samples s
 WHERE 
       --first exlcuding the ones we do later
       s.osd_id NOT IN (15,20,90,80,106)
       AND
       s.osd_id =  substring(ena.file_name_prefix from 'OSD(\d+)')::integer
       AND
       s.protocol = 'NPL022'
       AND
       date_part('year', local_date) >= 2014::double precision
       AND
       CASE WHEN substring(ena.file_name_prefix from 'OSD\d+-(\d*)m')::numeric IS NOT NULL 
            THEN s.water_depth = substring(ena.file_name_prefix from 'OSD\d+-(\d*)m')::numeric
            ELSE true
       END
;

-- re-establisch problem with wrong file name in OSD155-12-8m-depth

UPDATE ena_datasets AS ena 
   SET ena.sample_id = s.submission_id, 
       ena.osd_id = s.osd_id
  FROM samples s
 WHERE 
       ena.file_name_prefix = 'OSD155-12-8m-depth'
       AND s.submission_id = 204       

;


-- there is also an 
-- what about 187 ist von 2013
-- what about 8

UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id,
       ena.osd_id = s.osd_id 
  FROM samples s
 WHERE s.osd_id = 15 AND s.water_depth = 0
       AND 
         s.protocol = 'NPL022'        
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
        ena.file_name_prefix in ( 'OSD15-surf', 'OSD15-surface' )
;

UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 15 AND s.water_depth = 50
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix = 'OSD15-50m-depth'
;

UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 20 AND s.water_depth = 0
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix in ('OSD20-iceland', 'OSD20-surface')
;

UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 20 AND s.water_depth = 20
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix = 'OSD20-20m-depth'
;


UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 80 AND s.water_depth = 0
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix = 'OSD80'
;

UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 80 AND s.water_depth = 2
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix = 'OSD80-2m-depth';
-- 90 melted
UPDATE ena_datasets AS ena  
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 90 AND s.water_depth = 2
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix in ( 'OSD90-melted')
;


UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 90 AND s.water_depth = 2
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix in ('OSD90')
;

-- 106
UPDATE ena_datasets AS ena  
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 106 AND s.water_depth = 0
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix in ( 'OSD106-0m-depth', 'OSD106-surface')
;


UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 106 AND s.water_depth = 15
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix in ('OSD106-15m-depth','OSD106-sea-water-bottom');




ROLLBACK;
