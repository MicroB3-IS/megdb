BEGIN;

set search_path = osdregistry_stage;


drop table if exists osdregistry_stage.osd_2014_corrections;

CREATE TABLE osdregistry_stage.osd_2014_corrections (

  ena_acc text,
  biosample_acc text,
  bioarchive_code text,
  description text,
  site_name text,
  objective text,
  platform text,
  device text,
  osd_id integer,
  label text,
  start_lat text,
  start_lon text,
  stop_lat text,
  stop_lon text,
  water_depth text,
  local_date text,
  local_start text,
  local_end text,
  start_date_time_utc text,
  end_date_time_utc text,
  iho_label text,
  mrgid text,
  protocol text,
  water_temperature text,
  salinity text,
  biome text,
  biome_id text,
  feature text,
  feature_id text,
  material text,
  material_id text,
  ph text,
  phosphate text,
  nitrate text,
  carbon_organic_particulate text,
  nitrite text,
  carbon_organic_dissolved_doc text,
  nano_microplankton text,
  downward_par text,
  conductivity text,
  primary_production_isotope_uptake text,
  primary_production_oxygen text,
  dissolved_oxygen_concentration text,
  nitrogen_organic_particulate_pon text,
  meso_macroplankton text,
  bacterial_production_isotope_uptake text,
  nitrogen_organic_dissolved_don text,
  ammonium text,
  silicate text,
  bacterial_production_respiration text,
  turbidity text,
  fluorescence text,
  pigment_concentration text,
  picoplankton_flow_cytometry text,
  dist_coast_m text,
  dist_coast_iso3_code text,
  longhurst_code text,
  longhurst_biome text,
  longhurst_label text,
  longhurst_dist_degrees text,
  lme_name text,
  lme_dist_m text,
  osd_meow_ecoregion text,
  meow_ecoregion text,
  meow_province text,
  meow_realm text,


PRIMARY key (osd_id,label)
);

-- only interested in specific columsn and lines 
\copy osdregistry_stage.osd_2014_corrections FROM PROGRAM 'cat osd2014_cdata_20171121.tsv' (format csv, header, delimiter '	' )


commit;
