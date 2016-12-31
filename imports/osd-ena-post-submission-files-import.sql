
begin;

SET search_path to osdregistry,public;


/* creating ena_dataset entries from ena_files */

INSERT INTO ena_datasets (file_name_prefix, cat, processing_status, sequencing_center)

WITH before_files AS (

 SELECT regexp_replace(file_name, '_R[12]', ''::text )::text as file_name, full_path::text 
   FROM osdregistry.ena_datafiles
), files as (
  SELECT split_part( file_name, '_', 1 )::text as file_name_prefix,
         split_part( file_name, '_', 2 )::text as cat,
         split_part( split_part(file_name, '_', 3), '.', 1 )::text as processing_status,
         ((regexp_matches(full_path, '(lgc|ramaciotti-gc)'))[1])::text as sequencing_center
  from before_files

)
SELECT file_name_prefix::text, 
       cat::text,
       processing_status::text,
       CASE WHEN sequencing_center::text = 'lgc' 
            THEN 'LGC-GENOMICS'
            ELSE 'RAMACIOTTI-GC'
       END
  FROM files where cat != 'shotgun'
  GROUP BY file_name_prefix,cat,processing_status,sequencing_center
;


\echo after insert

--select * from ena_datasets where file_name_prefix ~ 'OSD\d+-[a-zA-Z]' ;

/*
select substring(file_name_prefix from 'OSD(\d+)') as match,
       substring(file_name_prefix from 'OSD\d+-(\d*)m')::numeric as depth
  from ena_mg_datasets;
--*/

-- make several path updates
UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE 
       --first exlcuding the ones we do later
       s.osd_id NOT IN (15,20,90,80,106)
       AND
       s.osd_id =  substring(ena.file_name_prefix from 'OSD(\d+)')::integer
       AND
       s.protocol = 'NPL022'
       AND
       date_part('year', local_date) = 2014::double precision
       AND
       CASE WHEN substring(ena.file_name_prefix from 'OSD\d+-(\d*)m')::numeric IS NOT NULL 
            THEN s.water_depth = substring(ena.file_name_prefix from 'OSD\d+-(\d*)m')::numeric
            ELSE true
       END
;

-- there is also an 
-- what about 187 ist von 2013
-- what about 8

UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
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

\copy ena_datasets TO '/home/renzo/src/megdb/exports/ena_datasets-2015-04-14.csv' CSV;
      
\echo should no give any row

\echo how many samples with all infos?

SELECT count(*) as sam_all_info
 FROM osdregistry.samples sam
      JOIN
      institute_sites i  ON (i.osd_id = sam.osd_id) 
      JOIN
      ena_center_names c ON (c.label =  i.label)
      JOIN
      sites ON ( sam.osd_id = sites.id )
      LEFT JOIN
      iho_tagging iho ON ( sam.submission_id = iho.submission_id)
 WHERE date_part('year', sam.local_date) = 2014::double precision
;


SELECT '=' || ena.file_name_prefix || '='
  FROM ena_datasets ena 
       --INNER JOIN
       --ena_datafiles files ON ( subs)
       LEFT JOIN 
       osdregistry.samples sam 
       ON (ena.sample_id = sam.submission_id )
 WHERE sam.osd_id is Null

;

rollback;
--commit;
