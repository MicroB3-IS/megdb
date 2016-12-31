
BEGIN;

SET search_path to osdregistry,public;


CREATE OR REPLACE FUNCTION osdregistry.create_investigator(bigint)
  RETURNS text AS
$BODY$
  SELECT string_agg ( p.last_name ||', ' || p.first_name || ', ' || aff.institute, '; ' ORDER BY own.seq_author_order)
    FROM participants p 
   INNER JOIN affiliated aff ON (p.email = aff.email)
   INNER JOIN owned_by own ON (p.email = own.email) 
   WHERE sample_id = $1 group by $1;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

ALTER FUNCTION osdregistry.create_investigator(bigint)	
  OWNER TO megdb_admin;

REVOKE EXECUTE ON FUNCTION osdregistry.create_investigator(bigint) from public;
GRANT EXECUTE ON FUNCTION osdregistry.create_investigator(bigint) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.create_investigator(bigint) TO megx_team;

CREATE OR REPLACE FUNCTION osdregistry.create_ena_shotgun_library()
  RETURNS xml AS
$BODY$
   SELECT xmlelement(name "LIBRARY_DESCRIPTOR",
                xmlelement(name "LIBRARY_STRATEGY", 'WGS'),
                xmlelement(name "LIBRARY_SOURCE", 'METAGENOMIC'),
                xmlelement(name "LIBRARY_SELECTION", 'RANDOM'),
                xmlelement(name "LIBRARY_LAYOUT",
                   xmlelement(name "PAIRED", 
                                xmlattributes( '300'
                                       as "NOMINAL_LENGTH")
                              )
                           )
              );
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

ALTER FUNCTION osdregistry.create_ena_shotgun_library()	
  OWNER TO megdb_admin;

REVOKE EXECUTE ON FUNCTION osdregistry.create_ena_shotgun_library() from public;
GRANT EXECUTE ON FUNCTION osdregistry.create_ena_shotgun_library() TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.create_ena_shotgun_library() TO megx_team;

---------


CREATE OR REPLACE FUNCTION osdregistry.create_ena_amplicon_library(locus text)
  RETURNS xml AS
$BODY$
SELECT xmlelement(name "LIBRARY_DESCRIPTOR",
                xmlelement(name "LIBRARY_STRATEGY", 'AMPLICON'),
                xmlelement(name "LIBRARY_SOURCE", 'METAGENOMIC'),
                xmlelement(name "LIBRARY_SELECTION", 'PCR'),
                xmlelement(name "LIBRARY_LAYOUT",
                   xmlelement(name "PAIRED", 
                                xmlattributes( '300'
                                       as "NOMINAL_LENGTH")
                              )
                           ),
                xmlelement(name "TARGETED_LOCI",
                    xmlelement(name "LOCUS",
                      xmlattributes( locus || ' rRNA' AS "locus_name" )
                    )
                )
              );
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

ALTER FUNCTION osdregistry.create_ena_amplicon_library(text)
  OWNER TO megdb_admin;

REVOKE EXECUTE ON FUNCTION osdregistry.create_ena_amplicon_library(text) from public;
GRANT EXECUTE ON FUNCTION osdregistry.create_ena_amplicon_library(text) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.create_ena_amplicon_library(text) TO megx_team;


DROP VIEW IF EXISTS ena_m2b3_sample_xml;

CREATE OR REPLACE VIEW ena_m2b3_sample_xml AS 
   SELECT 
       sam.submission_id,
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
             ena_sample_attribute('SAMPLING_Investigators', osdregistry.create_investigator(sam.submission_id) ),
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
;



CREATE OR REPLACE VIEW ena_m2b3_experiment_xml AS 
   SELECT 
       ena.*,
       
       xmlelement(name "EXPERIMENT", 
                    xmlattributes( 'osd-2014-' 
                                     || lower(sequencing_center) || '-' 
                                     || cat || '-'                  
                                     || submission_id  as "alias",
                                   'OSD-CONSORTIUM' as "center_name",
                                   'MPI-BREM'  as "broker_name"
                                  ),
          xmlelement(name "TITLE", 
                       CASE WHEN cat = 'shotgun'                    
                            THEN 'Metagenome Shotgun Sequencing'
                            ELSE 'Illumina MiSeq sequencing of sample ' 
                                  || osdregistry.osd_sample_label(
                                       ena.osd_id::text, samples.local_date::text, samples.water_depth::text, samples.protocol::text  
                                     ) 
                                  || 'from OSD-JUN-2014'
                        END
                    ),
          xmlelement(name "STUDY_REF", 
                       xmlattributes( 'osd-2014'
                                       as "refname")
                     ),
         xmlelement(name "DESIGN",
             xmlelement(name "DESIGN_DESCRIPTION",  
                          CASE WHEN cat = 'shotgun' 
                               THEN 'marine metagenome'
                               ELSE 'marine ' || cat || ' rDNA amplicon sequencing'
                           END
                        ),
             xmlelement(name "SAMPLE_DESCRIPTOR", 
                         xmlattributes( submission_id
                                       as "refname")
                       ),
             CASE WHEN cat = 'shotgun'
                  THEN osdregistry.create_ena_shotgun_library()
                  ELSE osdregistry.create_ena_amplicon_library( cat )
              END
             
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
;




CREATE OR REPLACE VIEW ena_m2b3_run_xml AS 
   SELECT 
       ena.*,
       xmlelement(name "RUN", 
                    xmlattributes( file_name_prefix  || '-'
                                     || lower(sequencing_center) || '-' 
                                     || cat || '-'                  
                                     || sample_id as "alias",
                                   'OSD-CONSORTIUM' as "center_name",
                                   'MPI-BREM'  as "broker_name",
                                   sequencing_center as "run_center"
                                  ), 
          xmlelement(name "EXPERIMENT_REF", 
                       xmlattributes( 'osd-2014-' 
                                     || lower(sequencing_center) || '-' 
                                     || cat || '-'                  
                                     || sample_id
                                       as "refname")
                     ),
          xmlelement(name "DATA_BLOCK",
             xmlelement(name "FILES",
                xmlelement(name "FILE", 
                             xmlattributes( file_name_prefix || '_R1_' || cat || '_raw.fastq.gz'
                                              as "filename",
                                            'fastq' as "filetype",
                                            'MD5' as "checksum_method"
                                           )
                          ),
                xmlelement(name "FILE", 
                             xmlattributes( file_name_prefix || '_R2_' || cat || '_raw.fastq.gz'
                                              as "filename",
                                            'fastq' as "filetype",
                                            'MD5' as "checksum_method"
                                           )
                           )
             )
          )
       ) as run
   FROM ena_datasets ena where sample_id IS NOT NULL;
;


commit;


