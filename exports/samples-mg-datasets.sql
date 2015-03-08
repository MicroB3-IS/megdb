
BEGIN;

SET search_path to osdregistry,public;



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


