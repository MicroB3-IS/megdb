
BEGIN;
SELECT _v.register_patch('00137-osdregistry_new_sample_env_view',
                          array['00136-osdregistry_add_envo_contraint_fix_naming'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path to osdregistry,public;

-- Function: osdregistry.create_investigator(bigint)

-- DROP FUNCTION osdregistry.create_investigator(bigint);

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
 GRANT EXECUTE ON FUNCTION osdregistry.create_investigator(bigint) TO megdb_admin;
 GRANT EXECUTE ON FUNCTION osdregistry.create_investigator(bigint) TO megx_team;
 REVOKE ALL ON FUNCTION osdregistry.create_investigator(bigint) FROM public;
 


-- Function: osdregistry.create_ena_shotgun_library()

-- DROP FUNCTION osdregistry.create_ena_shotgun_library();

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
  GRANT EXECUTE ON FUNCTION osdregistry.create_ena_shotgun_library() TO megdb_admin;
  GRANT EXECUTE ON FUNCTION osdregistry.create_ena_shotgun_library() TO megx_team;
  REVOKE ALL ON FUNCTION osdregistry.create_ena_shotgun_library() FROM public;
  

-- Function: osdregistry.create_ena_amplicon_library(text)

-- DROP FUNCTION osdregistry.create_ena_amplicon_library(text);

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
GRANT EXECUTE ON FUNCTION osdregistry.create_ena_amplicon_library(text) TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.create_ena_amplicon_library(text) TO megx_team;
REVOKE ALL ON FUNCTION osdregistry.create_ena_amplicon_library(text) FROM public;
                                                                                                                                                                                                                                                                                                                                       





DROP VIEW osdregistry.ena_m2b3_sample_xml;

-- View: osdregistry.sample_environmental_data

DROP VIEW osdregistry.sample_environmental_data;
  



DROP TABLE IF EXISTS osdregistry.iho_tagging;

CREATE MATERIALIZED VIEW  osdregistry.iho_tagging AS
WITH iho AS (
SELECT DISTINCT ON (submission_id)
    submission_id,
    osd_id,
    iho.label as iho_label,
    iho.id as iho_id,
    iho.gazetteer as mrgid,
  --ST_AsText(
    ---st_closestpoint(iho.geom, osd.start_geom)
  --) as point_on_iho,
   ST_Distance(iho.geog, osd.start_geog) as dist

  FROM
     -- lines/polygones
     marine_regions_stage.iho AS iho
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    (ST_DWithin(osd.start_geog,iho.geog, 10000))
ORDER BY
 submission_id, ST_Distance(osd.start_geog, iho.geog) 

)
select * from iho order by dist desc
;

select * from iho_tagging where osd_id  = 10;


COMMENT ON MATERIALIZED VIEW  iho_tagging
  IS 'IHO name and mgrid for each OSD sample with a distance of 10 or less km from an IHO region';

-- for some test queries as user megxuser
-- SET ROLE megxuser;


-- DROP VIEW osdregistry.ena_m2b3_sample_xml;

CREATE OR REPLACE VIEW osdregistry.ena_m2b3_sample_xml AS
 SELECT sam.submission_id,
     sam.osd_id,
         XMLELEMENT(NAME "SAMPLE", XMLATTRIBUTES(sam.submission_id AS alias, c.center_name AS center_name), XMLELEMENT(NAME "TITLE", osdregistry.osd_sample_label(sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol)), XMLELEMENT(NAME "SAMPLE_NAME", XMLELEMENT(NAME "TAXON_ID", '408172'), XMLELEMENT(NAME "SCIENTIFIC_NAME", 'marine metagenome')), XMLELEMENT(NAME "DESCRIPTION", sam.objective), XMLELEMENT(NAME "SAMPLE_ATTRIBUTES", osdregistry.ena_sample_attribute('ENA-CHECKLIST'::text, 'ERC000027'::text), osdregistry.ena_sample_attribute('Sampling Campaign'::text, 'OSD-Jun-2014'::text), osdregistry.ena_sample_attribute('Sampling Site'::text, (('OSD'::text || sam.osd_id) || ','::text) || sites.label_verb), osdregistry.ena_sample_attribute('SAMPLING_Investigators'::text, osdregistry.create_investigator(sam.submission_id)), osdregistry.ena_sample_attribute('Marine Region'::text, COALESCE(iho.iho_label, 'unknown'::text)), osdregistry.ena_sample_attribute('mrgid'::text, COALESCE(iho.mrgid::text, 'unknown'::text)), osdregistry.ena_sample_attribute('IHO'::text, COALESCE(iho.iho_label, 'unknown'::text)), osdregistry.ena_sample_attribute('Sampling Platform'::text, sam.platform), osdregistry.ena_sample_attribute('Event Date/Time'::text, (sam.local_date || 'T'::text) || sam.local_start), osdregistry.ena_sample_attribute('Longitude Start'::text, sam.start_lon::text, 'DD'::text), osdregistry.ena_sample_attribute('Latitude Start'::text, sam.start_lat::text, 'DD'::text), osdregistry.ena_sample_attribute('Longitude End'::text, sam.stop_lon::text, 'DD'::text), osdregistry.ena_sample_attribute('Latitude End'::text, sam.stop_lat::text, 'DD'::text), osdregistry.ena_sample_attribute('Depth'::text, sam.water_depth::text, 'm'::text), osdregistry.ena_sample_attribute('Protocol Label'::text, sam.protocol), osdregistry.ena_sample_attribute('SAMPLE_Title'::text, osdregistry.osd_sample_label(sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol)), osdregistry.ena_sample_attribute('Environment (Biome)'::text, sam.biome), osdregistry.ena_sample_attribute('Environment (Feature)'::text, sam.feature), osdregistry.ena_sample_attribute('Environment (Material)'::text, sam.material), osdregistry.ena_sample_attribute('Temperature'::text, sam.water_temperature::text, 'ºC'::text), osdregistry.ena_sample_attribute('Salinity'::text, sam.salinity::text, 'psu'::text), osdregistry.ena_sample_attribute('Project Name'::text, 'Micro B3'::text), osdregistry.ena_sample_attribute('Environmental Package'::text, 'water'::text), osdregistry.ena_sample_attribute('SAMPLING_Objective'::text, sam.objective), osdregistry.ena_sample_attribute('EVENT_Device'::text, sam.device))) AS sample
            FROM osdregistry.samples sam
               JOIN osdregistry.institute_sites i ON i.id = sam.osd_id
                  JOIN osdregistry.ena_center_names c ON c.label = i.label
                     JOIN osdregistry.sites ON sam.osd_id = sites.id
                        LEFT JOIN osdregistry.iho_tagging iho ON sam.submission_id = iho.submission_id;

ALTER TABLE osdregistry.ena_m2b3_sample_xml
  OWNER TO megdb_admin;
  GRANT ALL ON TABLE osdregistry.ena_m2b3_sample_xml TO megdb_admin;
  GRANT SELECT ON TABLE osdregistry.ena_m2b3_sample_xml TO megx_team WITH GRANT OPTION;
  GRANT SELECT ON TABLE osdregistry.ena_m2b3_sample_xml TO abryan;



-- View: osdregistry.sample_environmental_data

-- DROP VIEW osdregistry.sample_environmental_data;

CREATE OR REPLACE VIEW osdregistry.sample_environmental_data AS
  SELECT sam.osd_id,
  osdregistry.osd_sample_label(sam.osd_id::text, sam.local_date::text, sam.water_depth::text, sam.protocol) AS label,
  COALESCE(sam.bioarchive_code, 'na'::text) AS bioarchive_code,
  sam.ena_acc,
  COALESCE(sam.biosample_acc, 'na'::text) AS biosample_acc,
  sam.start_lat,
  sam.start_lon,
  sam.stop_lat,
  sam.stop_lon,
  sam.water_depth,
  sam.local_date,
  sam.local_start,
  sam.local_end,
  (sam.local_date::text || 'T'::text) || timezone('UTC'::text, sam.local_start) AS start_date_time_utc,
  (sam.local_date::text || 'T'::text) || timezone('UTC'::text, sam.local_end) AS end_date_time_utc,
  CASE
  WHEN sites.label = ''::text THEN sites.label_verb
  ELSE sites.label
  END AS site_name,
  iho.iho_label,
  iho.mrgid,
  sam.protocol,
  regexp_replace(sam.objective, '[\n\r\u2028]+'::text, ' '::text, 'g'::text) AS objective,
  sam.platform,
  sam.device,
  regexp_replace(sam.description, '[\n\r\u2028]+'::text, ' '::text, 'g'::text) AS description,
  sam.water_temperature,
  sam.salinity,
  sam.biome,
  envo_biome.id as biome_id,
  sam.feature,
  envo_feature.id as feature_id,
  sam.material,
  envo_material.id as material_id,
  sam.ph,
  sam.phosphate,
  sam.nitrate,
  sam.carbon_organic_particulate,
  sam.nitrite,
  sam.carbon_organic_dissolved_doc,
  sam.nano_microplankton,
  sam.downward_par,
  sam.conductivity,
  sam.primary_production_isotope_uptake,
  sam.primary_production_oxygen,
  sam.dissolved_oxygen_concentration,
  sam.nitrogen_organic_particulate_pon,
  sam.meso_macroplankton,
  sam.bacterial_production_isotope_uptake,
  sam.nitrogen_organic_dissolved_don,
  sam.ammonium,
  sam.silicate,
  sam.bacterial_production_respiration,
  sam.turbidity,
  sam.fluorescence,
  sam.pigment_concentration,
  sam.picoplankton_flow_cytometry
  FROM osdregistry.samples sam
  LEFT JOIN osdregistry.iho_tagging iho ON sam.submission_id = iho.submission_id
  JOIN envo.terms envo_biome ON sam.biome = envo_biome.term
  JOIN envo.terms envo_feature ON sam.feature = envo_feature.term
  JOIN envo.terms envo_material ON sam.material = envo_material.term
  JOIN osdregistry.sites ON sam.osd_id = sites.id;

ALTER TABLE osdregistry.sample_environmental_data
  OWNER TO megdb_admin;
  GRANT ALL ON TABLE osdregistry.sample_environmental_data TO megdb_admin;
  GRANT SELECT ON TABLE osdregistry.sample_environmental_data TO megx_team WITH GRANT OPTION;
  GRANT SELECT ON TABLE osdregistry.sample_environmental_data TO megxuser WITH GRANT OPTION;
  GRANT SELECT ON TABLE osdregistry.sample_environmental_data TO abryan;
  
/*
select osd_id, biome, biome_id , feature, feature_id, material, material_id
  from osdregistry.sample_environmental_data sam

;
--*/

commit;


