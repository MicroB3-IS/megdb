
Begin;

set search_path = osdregistry, public;


-- Function: osdregistry.ena_sample_attribute(text, text)

-- DROP FUNCTION osdregistry.ena_sample_attribute(text, text);

CREATE OR REPLACE FUNCTION osdregistry.ena_sample_attribute(k text, v text)
  RETURNS xml AS
  $BODY$
    SELECT osdregistry.ena_sample_attribute(k,v,null);
  $BODY$
LANGUAGE sql VOLATILE
COST 100;

ALTER FUNCTION osdregistry.ena_sample_attribute(text, text) OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.ena_sample_attribute(text, text) TO public;
GRANT EXECUTE ON FUNCTION osdregistry.ena_sample_attribute(text, text) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.ena_sample_attribute(text, text) TO megx_team;
	  
CREATE OR REPLACE FUNCTION osdregistry.create_investigator(bigint)
  RETURNS text AS
  $BODY$
    SELECT string_agg ( p.last_name ||', ' || p.first_name || ', ' || aff.institute, '; ' ORDER BY own.seq_author_order)
      FROM osdregistry.participants p
	   INNER JOIN
	   osdregistry.affiliated aff ON (p.email = aff.email)
	   INNER JOIN
	   owned_by own ON (p.email = own.email)
     WHERE sample_id = $1 group by $1;
   $BODY$
LANGUAGE sql VOLATILE
COST 100;

ALTER FUNCTION osdregistry.create_investigator(bigint)  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.create_investigator(bigint) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.create_investigator(bigint) TO megx_team;
REVOKE ALL ON FUNCTION osdregistry.create_investigator(bigint) FROM public;
		       

CREATE OR REPLACE FUNCTION osdregistry.envo_label(envo_id text, envo_term text)
  RETURNS text AS
  $BODY$
    SELECT
      CASE WHEN envo_id IS NULL OR envo_id = ''
                OR envo_term IS NULL OR envo_term = ''
           THEN 'unknown'
	   ELSE envo_term || ' [ENVO:' ||  envo_id || ']'
       END; 
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100
;
ALTER FUNCTION osdregistry.envo_label(text, text) OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.envo_label(text, text) TO public;
GRANT EXECUTE ON FUNCTION osdregistry.envo_label(text, text) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.envo_label(text, text) TO megx_team;
							   



-- DROP VIEW osdregistry.ena_m2b3_sample_xml;

CREATE OR REPLACE VIEW osdregistry.ena_m2b3_sample_xml AS 
 SELECT
    sam.submission_id, 
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
	    osdregistry.ena_sample_attribute('Marine Region'::text, COALESCE(iho.iho_label::text, 'unknown'::text)::text),
	    osdregistry.ena_sample_attribute('mrgid'::text, COALESCE(iho.mrgid::text, 'unknown'::text)::text),
	    osdregistry.ena_sample_attribute('IHO'::text, COALESCE(iho.iho_label::text, 'unknown'::text)::text),
	    osdregistry.ena_sample_attribute('Sampling Platform'::text, sam.platform),
	    osdregistry.ena_sample_attribute('Event Date/Time'::text, (sam.local_date || 'T'::text) || sam.local_start),
	    osdregistry.ena_sample_attribute('Longitude Start'::text, sam.start_lon::text, 'DD'::text),
	    osdregistry.ena_sample_attribute('Latitude Start'::text, sam.start_lat::text, 'DD'::text),
	    osdregistry.ena_sample_attribute('Longitude End'::text, sam.stop_lon::text, 'DD'::text),
	    osdregistry.ena_sample_attribute('Latitude End'::text, sam.stop_lat::text, 'DD'::text),
	    osdregistry.ena_sample_attribute('Depth'::text, sam.water_depth::text, 'm'::text),
	    osdregistry.ena_sample_attribute('Protocol Label'::text, sam.protocol::text),
	    osdregistry.ena_sample_attribute('SAMPLE_Title'::text, osdregistry.osd_sample_label(sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol)::text),
	    osdregistry.ena_sample_attribute (
	      'Environment (Biome)'::text,
	      osdregistry.envo_label(envo_biome.id,envo_biome.term)::text
	    ),
	    osdregistry.ena_sample_attribute (
	      'Environment (Feature)'::text,
	      osdregistry.envo_label(envo_feature.id,envo_feature.term)::text
	    ),
	    osdregistry.ena_sample_attribute (
	      'Environment (Material)'::text,
	      osdregistry.envo_label(envo_material.id,envo_material.term)::text
	    ),
	    osdregistry.ena_sample_attribute('Temperature'::text, sam.water_temperature::text, 'ºC'::text),
	    osdregistry.ena_sample_attribute('Salinity'::text, sam.salinity::text, 'psu'::text),
	    osdregistry.ena_sample_attribute('Project Name'::text, 'Micro B3'::text),
	    osdregistry.ena_sample_attribute('Environmental Package'::text, 'water'::text),
	    osdregistry.ena_sample_attribute('SAMPLING_Objective'::text, sam.objective),
	    osdregistry.ena_sample_attribute('EVENT_Device'::text, sam.device),
	    osdregistry.ena_sample_attribute('relevant electronic resources'::text, 'Detailed documentation at: https://github.com/MicroB3-IS/osd-analysis'::text ),
	    osdregistry.ena_sample_attribute('relevant standard operating procedures'::text, 'https://github.com/MicroB3-IS/osd-analysis/blob/master/doc/handbook/OSD_Handbook_2014-06.pdf'::text )
       )
		    
   ) AS sample
   FROM osdregistry.samples sam
   LEFT JOIN osdregistry.institute_sites i ON i.id = sam.osd_id
   LEFT JOIN osdregistry.ena_center_names c ON c.label = i.label
   LEFT JOIN osdregistry.sites ON sam.osd_id = sites.id
   LEFT JOIN osdregistry.iho_25km_tagging iho ON sam.submission_id = iho.submission_id
   LEFT JOIN osdregistry.sample_boundaries_tagging bt ON sam.submission_id = bt.submission_id
   LEFT JOIN osdregistry.sample_longhurst_36min_tagging lh ON sam.submission_id = lh.submission_id
   LEFT JOIN osdregistry.sample_lme_25km_tagging lme ON sam.submission_id = lme.submission_id
   LEFT JOIN envo.terms envo_biome ON sam.biome = envo_biome.term
   LEFT JOIN envo.terms envo_feature ON sam.feature = envo_feature.term
   LEFT JOIN envo.terms envo_material ON sam.material = envo_material.term

;
ALTER TABLE osdregistry.ena_m2b3_sample_xml
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.ena_m2b3_sample_xml TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.ena_m2b3_sample_xml TO megx_team WITH GRANT OPTION;



select count(x.osd_id)
  from osdregistry.ena_m2b3_sample_xml x
  left join osdregistry.samples sam on x.submission_id = sam.submission_id
 where sam.ena_acc != '' and local_date between '2014-05-01' AND '2014-08-01';


commit;
