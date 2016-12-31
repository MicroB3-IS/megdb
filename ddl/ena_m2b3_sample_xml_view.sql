
Begin;


-- DROP VIEW osdregistry.ena_m2b3_sample_xml;

CREATE OR REPLACE VIEW osdregistry.ena_m2b3_sample_xml AS 
 SELECT sam.submission_id, 
    sam.osd_id, 
    XMLELEMENT(NAME "SAMPLE",
      XMLATTRIBUTES(sam.submission_id AS alias, c.center_name AS center_name),
      XMLELEMENT(NAME "TITLE",
                 osdregistry.osd_sample_label(sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol)
     ),
     XMLELEMENT(NAME "SAMPLE_NAME",
       XMLELEMENT(NAME "TAXON_ID", '408172'),
         XMLELEMENT(NAME "SCIENTIFIC_NAME", 'marine metagenome')
     ),
     XMLELEMENT(NAME "DESCRIPTION", sam.objective),
         XMLELEMENT(NAME "SAMPLE_ATTRIBUTES",
            osdregistry.ena_sample_attribute('ENA-CHECKLIST'::text, 'ERC000027'::text),
	    osdregistry.ena_sample_attribute('Sampling Campaign'::text, 'OSD-Jun-2014'::text),
	    osdregistry.ena_sample_attribute('Sampling Site'::text, (('OSD'::text || sam.osd_id) || ','::text) || sites.label_verb),
	    osdregistry.ena_sample_attribute('SAMPLING_Investigators'::text, osdregistry.create_investigator(sam.submission_id)),
	    osdregistry.ena_sample_attribute('Marine Region'::text, COALESCE(iho.iho_label, 'unknown'::text::character varying)::text),
	    osdregistry.ena_sample_attribute('mrgid'::text, COALESCE(iho.mrgid::text, 'unknown'::text)),
	    osdregistry.ena_sample_attribute('IHO'::text, COALESCE(iho.iho_label, 'unknown'::text::character varying)::text),
	    osdregistry.ena_sample_attribute('Sampling Platform'::text, sam.platform),
	    osdregistry.ena_sample_attribute('Event Date/Time'::text, (sam.local_date || 'T'::text) || sam.local_start),
	    osdregistry.ena_sample_attribute('Longitude Start'::text, sam.start_lon::text, 'DD'::text),
	    osdregistry.ena_sample_attribute('Latitude Start'::text, sam.start_lat::text, 'DD'::text),
	    osdregistry.ena_sample_attribute('Longitude End'::text, sam.stop_lon::text, 'DD'::text),
	    osdregistry.ena_sample_attribute('Latitude End'::text, sam.stop_lat::text, 'DD'::text),
	    osdregistry.ena_sample_attribute('Depth'::text, sam.water_depth::text, 'm'::text),
	    osdregistry.ena_sample_attribute('Protocol Label'::text, sam.protocol),
	    osdregistry.ena_sample_attribute('SAMPLE_Title'::text, osdregistry.osd_sample_label(sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol)), osdregistry.ena_sample_attribute('Environment (Biome)'::text, sam.biome),
	    osdregistry.ena_sample_attribute('Environment (Feature)'::text, sam.feature),
	    osdregistry.ena_sample_attribute('Environment (Material)'::text, sam.material),
	    osdregistry.ena_sample_attribute('Temperature'::text, sam.water_temperature::text, 'ºC'::text),
	    osdregistry.ena_sample_attribute('Salinity'::text, sam.salinity::text, 'psu'::text),
	    osdregistry.ena_sample_attribute('Project Name'::text, 'Micro B3'::text),
	    osdregistry.ena_sample_attribute('Environmental Package'::text, 'water'::text),
	    osdregistry.ena_sample_attribute('SAMPLING_Objective'::text, sam.objective),
	    osdregistry.ena_sample_attribute('EVENT_Device'::text, sam.device)
       )
		    
   ) AS sample
   FROM osdregistry.samples sam
   JOIN osdregistry.institute_sites i ON i.id = sam.osd_id
   JOIN osdregistry.ena_center_names c ON c.label = i.label
   JOIN osdregistry.sites ON sam.osd_id = sites.id
   LEFT JOIN osdregistry.iho_tagging iho ON sam.submission_id = iho.submission_id;

ALTER TABLE osdregistry.ena_m2b3_sample_xml
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.ena_m2b3_sample_xml TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.ena_m2b3_sample_xml TO megx_team WITH GRANT OPTION;


rollback;
