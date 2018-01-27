

Begin;


CREATE VIEW osdregistry.gfbio_submission AS
  SELECT
    
    label AS sample_title, 
    408172::integer AS taxon_id, --marine metagenome
    description AS sample_description, 
    'Illumina MiSeq' AS sequencing_platform, 
    'AMPLICON' AS library_strategy ,
    'METAGENOMIC' AS library_source ,
    'PCR' AS library_selection ,
    'paired' AS library_layout ,
    300::integer AS nominal_length, 
    AS forward_read_file_name ,
    AS forward_read_file_checksum ,
    AS reverse_read_file_name ,
    AS reverse_read_file_checksum, 
    '' AS checksum_method ,
    'mimarks-survey' AS "investigation type",
    'water' AS "environmental package",
    local_date AS "collection date",
    start_lat  AS "geographic location (latitude)",
    start_lon AS "geographic location (longitude)" ,
    water_depth AS "geographic location (depth)",
    '' AS "geographic location (country and/or sea)", -- mandatory list from chekclist
    iho_label AS "geographic location (region and locality)",
    biome || ' [ENVO:'  biome_id || ']' AS "environment (biome)",
    feature || ' [ENVO:'  feature_id || ']' AS "environment (feature)" ,
    material || ' [ENVO:'  material_id || ']' AS "environment (material)", 
    '16S rRNA' as "target gene",
    'v4-v5' as "target subfragment",
    -- add rpimer
--submssion_id als sample attribute mit phanasie namenn
    osd_id,
    "Micro B3" as "project name", -- projekt das OSD betriben hat

    bioarchive_code,
    stop_lat  ,
    stop_lon as "Longitude Stop",
    local_start, local_end, start_date_time_utc, end_date_time_utc,
    site_name AS "Sampling Site",
    mrgid,
    protocol AS "Protocol Label",
    platform AS "Sampling Platform",
    device AS "sampling collection device or method",
    '' AS "Sampling Campaign",
    water_temperature AS temperature,
    salinity, 
    ph AS "pH",
    phosphate,
    nitrate,
    carbon_organic_particulate as "particulate organic carbon",
    nitrite,
    carbon_organic_dissolved_doc AS "dissolved organic carbon",
    nano_microplankton,
    downward_par as "downward PAR",
    conductivity,
    primary_production_isotope_uptake,
    primary_production_oxygen,
    dissolved_oxygen_concentration as "dissolved oxygen",
    nitrogen_organic_particulate_pon as "particulate organic nitrogen",
    meso_macroplankton,
    bacterial_production_isotope_uptake as "bacterial production",
    nitrogen_organic_dissolved_don "dissolved organic nitrogen",
    ammonium,
    silicate,
    bacterial_production_respiration as "bacterial respiration",
    turbidity,
    fluorescence,
    pigment_concentration, -- check against OSD hanbook
    picoplankton_flow_cytometry,
    dist_coast_m,
    dist_coast_iso3_code,
    longhurst_code,
    longhurst_descr,
    longhurst_dist_degrees,
    lme_name,
    lme_dist_m



  FROM osdregistry.sample_environmental_data 

  


Rollback;
