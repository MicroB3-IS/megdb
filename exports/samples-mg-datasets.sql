


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

CREATE TEMP TABLE iho_tagging AS
with iho_tagging AS (
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
select * from iho_tagging order by dist desc
;



CREATE TABLE ena_mg_datasets (
  file_name_prefix text PRIMARY KEY,
  sample_id integer UNIQUE REFERENCES samples (submission_id)

);

-- OSD 21 are from pilot runs

COPY ena_mg_datasets(file_name_prefix) FROM STDIN;
OSD1
OSD10
OSD100-1m-depth
OSD101
OSD102
OSD103
OSD105
OSD106-0m-depth
OSD106-15-depth
OSD107
OSD108
OSD109
OSD110
OSD111
OSD113
OSD114
OSD115
OSD116
OSD117
OSD118
OSD122
OSD123
OSD124
OSD125
OSD126
OSD127
OSD128
OSD129
OSD13
OSD130
OSD131
OSD132
OSD133
OSD14
OSD141
OSD142
OSD143
OSD144
OSD145
OSD146
OSD147
OSD148
OSD149
OSD150
OSD151
OSD152-1m-depth
OSD152-5m-depth
OSD153
OSD154
OSD155-1m-depth
OSD156-1m-depth
OSD157-1m-depth
OSD158
OSD159
OSD15-50m-depth
OSD15-surf
OSD162
OSD163
OSD164
OSD165
OSD166
OSD167
OSD168
OSD169
OSD17
OSD170
OSD171
OSD172
OSD173
OSD174
OSD175
OSD176
OSD177
OSD178
OSD18
OSD182
OSD183
OSD184
OSD185
OSD186
OSD19
OSD2
OSD20-20m-depth
OSD20-iceland
OSD21
OSD22
OSD24
OSD25
OSD26
OSD28
OSD29
OSD3
OSD30
OSD34
OSD35
OSD36
OSD37
OSD38
OSD39
OSD4
OSD41
OSD42
OSD43
OSD45
OSD46
OSD47
OSD48
OSD49
OSD50
OSD51
OSD5-1m-depth
OSD52
OSD53
OSD54
OSD55
OSD56
OSD57
OSD5-75m-depth
OSD58
OSD6
OSD60
OSD61
OSD62
OSD63
OSD64
OSD65
OSD69
OSD7
OSD70
OSD71
OSD72
OSD73
OSD74
OSD76
OSD77
OSD78
OSD80
OSD80-2m-depth
OSD81
OSD9
OSD90
OSD91
OSD92
OSD93
OSD94
OSD95
OSD96
OSD97
OSD98
OSD99
\.

/*
select substring(file_name_prefix from 'OSD(\d+)') as match,
       substring(file_name_prefix from 'OSD\d+-(\d*)m')::numeric as depth
  from ena_mg_datasets;
--*/

-- make several path updates
UPDATE ena_mg_datasets AS ena 
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

UPDATE ena_mg_datasets AS ena 
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

UPDATE ena_mg_datasets AS ena 
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

UPDATE ena_mg_datasets AS ena 
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

UPDATE ena_mg_datasets AS ena 
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

UPDATE ena_mg_datasets AS ena 
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

UPDATE ena_mg_datasets AS ena 
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
UPDATE ena_mg_datasets AS ena 
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

UPDATE ena_mg_datasets AS ena 
   SET sample_id = s.submission_id 
  FROM samples s
 WHERE s.osd_id = 106 AND s.water_depth = 15
       AND 
         s.protocol = 'NPL022'
       AND
         date_part('year', s.local_date) >= 2014::double precision
       AND
       ena.file_name_prefix = 'OSD106-15m-depth';



\echo should no give any row
SELECT ena.file_name_prefix, sam.* 
  FROM ena_mg_datasets ena 
       LEFT JOIN 
       osdregistry.samples sam 
       ON (ena.sample_id = sam.submission_id )
 WHERE sam.osd_id is Null
       AND
       sam.osd_id NOT in (21)
;

\echo the NOT null ones


SELECT ena.* 
  FROM ena_mg_datasets ena 
where sample_id is not null and file_name_prefix <> 'OSD21' 
order by file_name_prefix;


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
                         water_depth::text, protocol::text, 'shotgun'::text
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
             ena_sample_attribute('Sampling Site', 'OSD' || sam.osd_id || ', ' || sites.label_verb ),
             ena_sample_attribute('Marine Region', iho.iho_label),
             ena_sample_attribute('mrgid'::text, iho.mrgid::text),
             ena_sample_attribute('IHO', iho.iho_label),
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
                                         water_depth::text, protocol::text, 'shotgun'::text
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
      JOIN
      iho_tagging iho ON ( sam.submission_id = iho.submission_id)
 WHERE sam.osd_id NOT IN (21)
;


CREATE OR REPLACE VIEW ena_m2b3_experiment_xml AS 
   SELECT 
       osd_id,
       
       xmlelement(name "EXPERIMENT", 
                    xmlattributes( 'osd-2014-lgc-shotgun-' || submission_id  as "alias",
                                   'OSD-CONSORTIUM' as "center_name",
                                   'MPI-BREM'  as "broker_name"
                                  ),
          xmlelement(name "TITLE", 'Metagenome Shotgun Sequencing'),
          xmlelement(name "STUDY_REF", 
                       xmlattributes( 'ena-STUDY-OSD-CONSORTIUM-19-01-2015-11:47:33:121-276'
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
        ena_mg_datasets ena ON (samples.submission_id = ena.sample_id)
        
 WHERE osd_id NOT IN (21)
;




CREATE OR REPLACE VIEW ena_m2b3_run_xml AS 
   SELECT 
       sample_id,
       file_name_prefix,
       xmlelement(name "RUN", 
                    xmlattributes( file_name_prefix  as "alias",
                                   'OSD-CONSORTIUM' as "center_name",
                                   'MPI-BREM'  as "broker_name",
                                   'LGC-GENOMICS' as "run_center"
                                  ), 
          xmlelement(name "EXPERIMENT_REF", 
                       xmlattributes( 'osd-2014-lgc-shotgun-' || sample_id
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
   FROM ena_mg_datasets
   where sample_id is not null and file_name_prefix <> 'OSD21' 
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


