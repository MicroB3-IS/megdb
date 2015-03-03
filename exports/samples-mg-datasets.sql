


BEGIN;

SET search_path to osdregistry,public;

select osdregistry.deletesample( f.i ) 
  FROM (values (187),(171) ) as f(i);  

--- refreshing data from osd_raw_samples


CREATE OR REPLACE FUNCTION osdregistry.osd_sample_label (
     osd_id text, 
     local_date text,
     water_depth text,
     protocol text,
     dataset_type text) 
  RETURNS text AS $$
   SELECT 'OSD' || osd_id || '_' 
             || local_date || '_'
             || water_depth::text || 'm_'
             || protocol::text || '_'
             || dataset_type
         ;    
$$ LANGUAGE SQL; 


CREATE OR REPLACE FUNCTION osdregistry.osd_sample_label (
     osd_id text, 
     local_date text,
     water_depth text,
     protocol text) 
  RETURNS text AS $$
   SELECT 'OSD' || osd_id || '_' 
             || local_date || '_'
             || water_depth::text || 'm_'
             || protocol::text
         ;    
$$ LANGUAGE SQL; 


CREATE TEMP TABLE iho_tagging AS
with iho AS (
SELECT DISTINCT ON (submission_id)
    submission_id,
    osd_id,
    iho.label as iho_label,
    iho.id as iho_id,
    iho.gazetteer as mrgid,
  ST_AsText(
    st_closestpoint(iho.geom, osd.start_geom)
  ) as point_on_iho,
   ST_Distance(iho.geom, osd.start_geom) as dist

  FROM
     -- lines/polygones
     marine_regions_stage.iho AS iho
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    (ST_DWithin(osd.start_geom,iho.geom, 1))
ORDER BY
 submission_id, ST_Distance(osd.start_geom, iho.geom) 

)
select * from iho order by dist desc
;
--*/

select count(*) as iho_tag_count from iho_tagging;


CREATE TABLE ena_datafiles (
  file_name text CHECK (file_name ~ '^OSD') PRIMARY KEY,
  md5 text UNIQUE,
  full_path text CHECK (full_path ~ '/bioinf/projects/osd/main')
);

DELETE FROM  ena_datafiles;
-- fiill 
-- OSD 21 are from pilot runs
\copy ena_datafiles(md5,file_name,full_path) FROM '/home/renzo/src/osd-submissions/2014/submission_files_report.csv' CSV;


CREATE TABLE ena_datasets (
  sample_id integer REFERENCES samples (submission_id),
  file_name_prefix text check (file_name_prefix ~ '^OSD') PRIMARY KEY,
  osd_id integer,
  sequencing_center text NOT NULL,
  cat text CHECK ( cat in ('16S', '18S', 'shotgun') ) ,
  processing_status text NOT NULL CHECK ( processing_status in ('raw','workable') ),
  create_time timestamp NOT NULL DEFAULT now()

);


delete from ena_datasets;

INSERT INTO ena_datasets (file_name_prefix, cat, processing_status, sequencing_center)

WITH files AS (
  SELECT split_part( file_name, '_', 1 ) as file_name_prefix,
         split_part( file_name, '_', 3 ) as cat,
         split_part( split_part( file_name, '_', 4), '.', 1 ) as processing_status,
         (regexp_matches(full_path, '(lgc|ramaciotti-gc)'))[1] as sequencing_center
 
 FROM ena_datafiles
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

\copy ena_datasets TO '/home/renzo/src/megdb/exports/ena_datasets.csv' CSV;

\echo should no give any row

\echo how many samples with all infos?

SELECT count(*) as sam_all_info
 FROM osdregistry.samples sam
      --JOIN
      --institute_sites i  ON (i.osd_id = sam.osd_id) 
      --JOIN
      --ena_center_names c ON (c.label =  i.label)
      --JOIN
      --sites ON ( sam.osd_id = sites.id )
      --LEFT JOIN
      --iho_tagging iho ON ( sam.submission_id = iho.submission_id)
 WHERE date_part('year', sam.local_date) = 2014::double precision
;



SELECT ena.file_name_prefix, sam.* 
  FROM ena_datasets ena 
       LEFT JOIN 
       osdregistry.samples sam 
       ON (ena.sample_id = sam.submission_id )
 WHERE sam.osd_id is Null

;



\echo the NOT null ones

SELECT ena.* 
  FROM ena_datasets ena 
where sample_id is null  
order by file_name_prefix;

select count(*) from ena_datasets;
---

CREATE OR REPLACE VIEW ena_m2b3_sample_xml AS 
   SELECT 
       sam.osd_id,
       xmlelement(name "SAMPLE", 
                    xmlattributes( sam.submission_id as "alias",
                                   c.center_name as "center_name"
                                  ),
          xmlelement(name "TITLE", 
                       osd_sample_label ( 
                         sam.osd_id::text, local_date::text,  
                         water_depth::text, protocol::text
                       )
                    ),
          xmlelement(name "SAMPLE_NAME", 
             xmlelement(name "TAXON_ID", '408172'),
             xmlelement(name "SCIENTIFIC_NAME",  'marine metagenome')
          ),
          xmlelement(name "DESCRIPTION", objective::text),
          xmlelement(name "SAMPLE_ATTRIBUTES", 
             ena_sample_attribute('ENA-CHECKLIST', 'ERC000027' ),
             ena_sample_attribute('Sampling Campaign', 'OSD-Jun-2014' ),
             ena_sample_attribute('Sampling Site', 'OSD' || sam.osd_id || ',' || sites.label_verb ),
        
             ena_sample_attribute('Marine Region', COALESCE (iho.iho_label, 'unknown') ),
             ena_sample_attribute('mrgid'::text, COALESCE ( iho.mrgid::text, 'unknown') ),
             ena_sample_attribute('IHO', COALESCE ( iho.iho_label, 'unknown') ),
             ena_sample_attribute('Sampling Platform', platform ),
             ena_sample_attribute('Event Date/Time', local_date || 'T' || local_start ),
             ena_sample_attribute('Longitude Start', start_lon::text, 'DD' ),
             ena_sample_attribute('Latitude Start', start_lat::text, 'DD' ),
             ena_sample_attribute('Longitude End', stop_lon::text, 'DD' ),
             ena_sample_attribute('Latitude End', stop_lat::text, 'DD' ),

             ena_sample_attribute('Depth', water_depth::text, 'm' ),
             ena_sample_attribute('Protocol Label', protocol::text ),
             ena_sample_attribute('SAMPLE_Title', 
                                     osd_sample_label ( 
                                         sam.osd_id::text, local_date::text,  
                                         water_depth::text, protocol::text
                                     )
                                 ),
             ena_sample_attribute('Environment (Biome)', biome::text ),
             ena_sample_attribute('Environment (Feature)', feature::text ),
             ena_sample_attribute('Environment (Material)', material::text ),
             ena_sample_attribute('Temperature'::text, water_temperature::text, 'ºC'::text ),
             ena_sample_attribute('Salinity', salinity::text, 'psu'),

             ena_sample_attribute('Project Name', 'Micro B3' ),
             ena_sample_attribute('Environmental Package', 'water' ),
             ena_sample_attribute('SAMPLING_Objective', objective::text ),
             ena_sample_attribute('EVENT_Device', device::text )
             
          )
        ) AS sample

 FROM samples sam
      JOIN
      institute_sites i  ON (i.osd_id = sam.osd_id) 
      JOIN
      ena_center_names c ON (c.label =  i.label)
      JOIN
      sites ON ( sam.osd_id = sites.id )
      left JOIN
      iho_tagging iho ON ( sam.submission_id = iho.submission_id)
 WHERE date_part('year', sam.local_date) = 2014::double precision
;



CREATE OR REPLACE VIEW ena_m2b3_experiment_xml AS 
   SELECT 
       ena.osd_id,
       
       xmlelement(name "EXPERIMENT", 
                    xmlattributes( 'osd-2014-' 
                                     || sequencing_center || '-' 
                                     || cat || '-'                  
                                     || submission_id  as "alias",
                                   'OSD-CONSORTIUM' as "center_name",
                                   'MPI-BREM'  as "broker_name"
                                  ),
          xmlelement(name "TITLE", 'Metagenome Shotgun Sequencing'),
          xmlelement(name "STUDY_REF", 
                       xmlattributes( 'osd-2014'
                                       as "refname")
                     ),
         xmlelement(name "DESIGN",
             xmlelement(name "DESIGN_DESCRIPTION",  'marine metagenome'),
             xmlelement(name "SAMPLE_DESCRIPTOR", 
                         xmlattributes( submission_id
                                       as "refname")
                       ),
             xmlelement(name "LIBRARY_DESCRIPTOR",
                xmlelement(name "LIBRARY_STRATEGY", 'WGS'),
                xmlelement(name "LIBRARY_SOURCE", 'METAGENOMIC'),
                xmlelement(name "LIBRARY_SELECTION", 'RANDOM'),
                xmlelement(name "LIBRARY_LAYOUT",
                   xmlelement(name "PAIRED", 
                                xmlattributes( '300'
                                       as "NOMINAL_LENGTH")
                              )
                           )
              )
         ), 
         xmlelement(name "PLATFORM",
            xmlelement(name "ILLUMINA", 
               xmlelement(name "INSTRUMENT_MODEL", 'Illumina MiSeq') 
            )
         ),
         xmlelement(name "PROCESSING")
     ) as experiment
   FROM samples
          INNER JOIN 
        ena_datasets ena ON (samples.submission_id = ena.sample_id)
        
 WHERE date_part('year', samples.local_date) >= 2014::double precision

;




CREATE OR REPLACE VIEW ena_m2b3_run_xml AS 
   SELECT 
       sample_id,
       file_name_prefix,
       xmlelement(name "RUN", 
                    xmlattributes( file_name_prefix  || '-'
                                     || sequencing_center || '-' 
                                     || cat || '-'                  
                                     || sample_id as "alias",
                                   'OSD-CONSORTIUM' as "center_name",
                                   'MPI-BREM'  as "broker_name",
                                   'LGC-GENOMICS' as "run_center"
                                  ), 
          xmlelement(name "EXPERIMENT_REF", 
                       xmlattributes( 'osd-2014-' 
                                     || sequencing_center || '-' 
                                     || cat || '-'                  
                                     || sample_id
                                       as "refname")
                     ),
          xmlelement(name "DATA_BLOCK",
             xmlelement(name "FILES",
                xmlelement(name "FILE", 
                             xmlattributes( file_name_prefix || '_R1_shotgun_raw.fastq.gz'
                                              as "filename",
                                            'fastq' as "filetype",
                                            'MD5' as "checksum_method"
                                           )
                          ),
                xmlelement(name "FILE", 
                             xmlattributes( file_name_prefix || '_R2_shotgun_raw.fastq.gz'
                                              as "filename",
                                            'fastq' as "filetype",
                                            'MD5' as "checksum_method"
                                           )
                           )
             )
          )
       ) as run
   FROM ena_datasets where sample_id IS NOT NULL;
;

--SELECT xmlelement(name "SAMPLE_SET", t.s)  FROM (select xmlagg( sample order by osd_id DESC) as s  from ena_m2b3_sample_xml) as t(s);


\a
\t

\copy (SELECT xmlelement(name "SAMPLE_SET", t.s::xml) FROM (select xmlagg( sample order by osd_id DESC)::xml as s from ena_m2b3_sample_xml) as t(s)) TO '/home/renzo/src/osd-submissions/2014/dirty_xml/sample_2014-02-27.xml'


\copy (SELECT xmlelement(name "EXPERIMENT_SET", t.s::xml) FROM (select xmlagg( experiment order by osd_id DESC)::xml as s from ena_m2b3_experiment_xml) as t(s)) TO '/home/renzo/src/osd-submissions/2014/dirty_xml/experiment_2014-02-27.xml'



\copy (SELECT xmlelement(name "RUN_SET", t.s::xml) FROM (select xmlagg( run order by file_name_prefix DESC)::xml as s from ena_m2b3_run_xml) as t(s)) TO '/home/renzo/src/osd-submissions/2014/dirty_xml/run_2014-02-27.xml'


\a
\t

ROLLBACK;


