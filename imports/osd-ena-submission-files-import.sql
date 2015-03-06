
begin;

SET search_path to osdregistry,public;

-- DELETE FROM  ena_datafiles;
-- fill 
-- OSD 21 are from pilot runs

-- make patch

insert into osdregistry.sequencing_centers 
  VALUES ('lgc'),('ramaciotti-gc');

insert into osdregistry.processing_categories
  VALUES ('raw'),('workable');


delete from osdregistry.dataset_categories;
insert into osdregistry.dataset_categories
  VALUES ('shotgun'),('16S'),('18S');


\copy ena_datafiles(md5,file_name,full_path) FROM '/home/renzo/src/megdb/imports/test.csv' (FORMAT CSV) ;

\copy ena_datafiles(md5,file_name,full_path) FROM '/home/renzo/src/megdb/imports/submission_raw_shotgun_files_report.csv' CSV;

--\copy ena_datafiles(md5,file_name,full_path) FROM '/home/renzo/src/megdb/imports/submission_workable_rrna_files_report.csv' CSV;


-- OSD100-1m-depth_18S_workable.fastq.gz
-- OSD100-1m-depth_R2_16S_raw.fastq.gz
INSERT INTO ena_datasets (file_name_prefix, cat, processing_status, sequencing_center)
WITH files AS (
  SELECT split_part( file_name, '_', 1 ) as file_name_prefix,
         split_part( file_name, '_', 2 ) as cat,
         split_part( split_part( file_name, '_', 3), '.', 1 ) as processing_status,
         (regexp_matches(full_path, '(lgc|ramaciotti-gc)'))[1] as sequencing_center
 
 FROM (select regexp_replace(file_name, '_R[12]', '' ), full_path from ena_datafiles) as t(file_name)
)
SELECT file_name_prefix, max(cat), max(processing_status), max(sequencing_center)
  FROM files
  GROUP BY file_name_prefix
;


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
       s.osd_id NOT IN (15,20,80,106)
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

UPDATE ena_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 15 AND s.water_depth = 0
       AND 
         s.protocol = 'NPL022'        
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
        ena.file_name_prefix = 'OSD15-surf'
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
       ena.file_name_prefix = 'OSD20-iceland'
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
       ena.file_name_prefix = 'OSD106-0m-depth'
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
       ena.file_name_prefix = 'OSD106-15m-depth';

\copy ena_datasets TO '/home/renzo/src/megdb/exports/ena_datasets-2015-03-03.csv' CSV;
      
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


SELECT ena.file_name_prefix, sam.* 
  FROM ena_datasets ena 
       LEFT JOIN 
       osdregistry.samples sam 
       ON (ena.sample_id = sam.submission_id )
 WHERE sam.osd_id is Null

;

rollback;