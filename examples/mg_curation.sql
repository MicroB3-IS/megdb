

begin;


-- Table: osdregistry.samples

-- DROP TABLE osdregistry.samples;

CREATE TABLE osdregistry.samples (
  submission_id bigint NOT NULL,
  osd_id integer NOT NULL,
  curator text NOT NULL DEFAULT ''::text,
  curation_remark text NOT NULL DEFAULT ''::text,
-- todo
-- add sequence_count intefet
-- add pi_email
-- add links to differnet kind of measuremnts
  label text,
  label_verb text NOT NULL DEFAULT ''::text,
  start_lat numeric DEFAULT 'NaN'::numeric,
  start_lon numeric DEFAULT 'NaN'::numeric,
  stop_lat numeric DEFAULT 'NaN'::numeric,
  stop_lon numeric DEFAULT 'NaN'::numeric,
  start_lat_verb text NOT NULL,
  start_lon_verb text NOT NULL,
  stop_lat_verb text NOT NULL,
  stop_lon_verb text NOT NULL,
  max_uncertain numeric NOT NULL DEFAULT 'NaN'::numeric,
  water_depth numeric NOT NULL DEFAULT 'NaN'::numeric,
  local_date date NOT NULL DEFAULT 'infinity'::date,
  local_date_verb text NOT NULL DEFAULT ''::text,
  local_start time(0) with time zone,
  local_end time(0) with time zone,
  protocol text NOT NULL DEFAULT ''::text,
  objective text NOT NULL DEFAULT ''::text,
  platform text NOT NULL DEFAULT ''::text,
  platform_verb text NOT NULL DEFAULT ''::text,
  device text NOT NULL DEFAULT ''::text,
  description text NOT NULL DEFAULT ''::text,
  water_temperature numeric NOT NULL DEFAULT 'NaN'::numeric,
  salinity numeric NOT NULL DEFAULT 'NaN'::numeric,
  biome text NOT NULL DEFAULT ''::text,
  feature text NOT NULL DEFAULT ''::text,
  material text NOT NULL DEFAULT ''::text,
  ph numeric NOT NULL DEFAULT 'NaN'::numeric,
  ph_verb text NOT NULL DEFAULT ''::text,
  phosphate numeric NOT NULL DEFAULT 'NaN'::numeric,
  phosphate_verb text NOT NULL DEFAULT ''::text,
  nitrate numeric NOT NULL DEFAULT 'NaN'::numeric,
  nitrate_verb text NOT NULL DEFAULT ''::text,
  carbon_organic_particulate numeric NOT NULL DEFAULT 'NaN'::numeric,
  carbon_organic_particulate_verb text NOT NULL DEFAULT ''::text,
  nitrite numeric NOT NULL DEFAULT 'NaN'::numeric,
  nitrite_verb text NOT NULL DEFAULT ''::text,
  carbon_organic_dissolved_doc numeric NOT NULL DEFAULT 'NaN'::numeric,
  carbon_organic_dissolved_doc_verb text NOT NULL DEFAULT ''::text,
  nano_microplankton numeric NOT NULL DEFAULT 'NaN'::numeric,
  nano_microplankton_verb text NOT NULL DEFAULT ''::text,
  downward_par numeric NOT NULL DEFAULT 'NaN'::numeric,
  downward_par_verb text NOT NULL DEFAULT ''::text,
  conductivity numeric NOT NULL DEFAULT 'NaN'::numeric,
  conductivity_verb text NOT NULL DEFAULT ''::text,
  primary_production_isotope_uptake numeric NOT NULL DEFAULT 'NaN'::numeric,
  primary_production_isotope_uptake_verb text NOT NULL DEFAULT ''::text,
  primary_production_oxygen numeric NOT NULL DEFAULT 'NaN'::numeric,
  primary_production_oxygen_verb text NOT NULL DEFAULT ''::text,
  dissolved_oxygen_concentration numeric NOT NULL DEFAULT 'NaN'::numeric,
  dissolved_oxygen_concentration_verb text NOT NULL DEFAULT ''::text,
  nitrogen_organic_particulate_pon numeric NOT NULL DEFAULT 'NaN'::numeric,
  nitrogen_organic_particulate_pon_verb text NOT NULL DEFAULT ''::text,
  meso_macroplankton numeric NOT NULL DEFAULT 'NaN'::numeric,
  meso_macroplankton_verb text NOT NULL DEFAULT ''::text,
  bacterial_production_isotope_uptake numeric NOT NULL DEFAULT 'NaN'::numeric,
  bacterial_production_isotope_uptake_verb text NOT NULL DEFAULT ''::text,
  nitrogen_organic_dissolved_don numeric NOT NULL DEFAULT 'NaN'::numeric,
  nitrogen_organic_dissolved_don_verb text NOT NULL DEFAULT ''::text,
  ammonium numeric NOT NULL DEFAULT 'NaN'::numeric,
  ammonium_verb text NOT NULL DEFAULT ''::text,
  silicate numeric NOT NULL DEFAULT 'NaN'::numeric,
  silicate_verb text NOT NULL DEFAULT ''::text,
  bacterial_production_respiration numeric NOT NULL DEFAULT 'NaN'::numeric,
  bacterial_production_respiration_verb text NOT NULL DEFAULT ''::text,
  turbidity numeric NOT NULL DEFAULT 'NaN'::numeric,
  turbidity_verb text NOT NULL DEFAULT ''::text,
  fluorescence numeric NOT NULL DEFAULT 'NaN'::numeric,
  fluorescence_verb text NOT NULL DEFAULT ''::text,
  pigment_concentration numeric NOT NULL DEFAULT 'NaN'::numeric,
  pigment_concentration_verb text NOT NULL DEFAULT ''::text,
  picoplankton_flow_cytometry numeric NOT NULL DEFAULT 'NaN'::numeric,
  picoplankton_flow_cytometry_verb text NOT NULL DEFAULT ''::text,
  other_params json NOT NULL DEFAULT '{}'::json,
  remarks json NOT NULL DEFAULT '{}'::json,
  "raw" json,
  start_geom geometry,
  stop_geom geometry,
  bioarchive_code text NOT NULL DEFAULT ''::text,
  ena_acc text NOT NULL DEFAULT ''::text,
  biosample_acc text NOT NULL DEFAULT ''::text,
  local_start_verb text NOT NULL DEFAULT ''::text,
  local_end_verb text NOT NULL DEFAULT ''::text,
  start_geog geography(Point,4326),
  stop_geog geography(Point,4326),

  CONSTRAINT samples_pkey PRIMARY KEY (submission_id),
  CONSTRAINT samples_osd_id_fkey FOREIGN KEY (osd_id)
      REFERENCES osdregistry.sites (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT enforce_dims_start_geom CHECK (st_ndims(start_geom) = 2),
  CONSTRAINT enforce_dims_stop_geom CHECK (st_ndims(stop_geom) = 2),
  CONSTRAINT enforce_geotype_start_geom CHECK (geometrytype(start_geom) = 'POINT'::text OR start_geom IS NULL),
  CONSTRAINT enforce_geotype_stop_geom CHECK (geometrytype(stop_geom) = 'POINT'::text OR stop_geom IS NULL),
  CONSTRAINT enforce_srid_start_geom CHECK (st_srid(start_geom) = 4326),
  CONSTRAINT enforce_srid_stop_geom CHECK (st_srid(stop_geom) = 4326),
  CONSTRAINT samples_ammonium_check CHECK (ammonium >= 0::numeric OR ammonium = 'NaN'::numeric),
  CONSTRAINT samples_bacterial_production_isotope_uptake_check CHECK (bacterial_production_isotope_uptake >= 0::numeric OR bacterial_production_isotope_uptake = 'NaN'::numeric),
  CONSTRAINT samples_bacterial_production_respiration_check CHECK (bacterial_production_respiration >= 0::numeric OR bacterial_production_respiration = 'NaN'::numeric),
  CONSTRAINT samples_carbon_organic_dissolved_doc_check CHECK (carbon_organic_dissolved_doc >= 0::numeric OR carbon_organic_dissolved_doc = 'NaN'::numeric),
  CONSTRAINT samples_carbon_organic_particulate_check CHECK (carbon_organic_particulate >= 0::numeric OR carbon_organic_particulate = 'NaN'::numeric),
  CONSTRAINT samples_conductivity_check CHECK (conductivity >= 0::numeric OR conductivity = 'NaN'::numeric),
  CONSTRAINT samples_dissolved_oxygen_concentration_check CHECK (dissolved_oxygen_concentration >= 0::numeric OR dissolved_oxygen_concentration = 'NaN'::numeric),
  CONSTRAINT samples_downward_par_check CHECK (downward_par >= 0::numeric OR downward_par = 'NaN'::numeric),
  CONSTRAINT samples_meso_macroplankton_check CHECK (meso_macroplankton >= 0::numeric OR meso_macroplankton = 'NaN'::numeric),
  CONSTRAINT samples_nano_microplankton_check CHECK (nano_microplankton >= 0::numeric OR nano_microplankton = 'NaN'::numeric),
  CONSTRAINT samples_nitrate_check CHECK (nitrate >= 0::numeric OR nitrate = 'NaN'::numeric),
  CONSTRAINT samples_nitrite_check CHECK (nitrite >= 0::numeric OR nitrite = 'NaN'::numeric),
  CONSTRAINT samples_nitrogen_organic_dissolved_don_check CHECK (nitrogen_organic_dissolved_don >= 0::numeric OR nitrogen_organic_dissolved_don = 'NaN'::numeric),
  CONSTRAINT samples_nitrogen_organic_particulate_pon_check CHECK (nitrogen_organic_particulate_pon >= 0::numeric OR nitrogen_organic_particulate_pon = 'NaN'::numeric),
  CONSTRAINT samples_ph_check CHECK (ph >= 0::numeric AND ph < (+ 12)::numeric OR ph = 'NaN'::numeric),
  CONSTRAINT samples_phosphate_check CHECK (phosphate >= 0::numeric OR phosphate = 'NaN'::numeric),
  CONSTRAINT samples_picoplankton_flow_cytometry_check CHECK (picoplankton_flow_cytometry >= 0::numeric OR picoplankton_flow_cytometry = 'NaN'::numeric),
  CONSTRAINT samples_pigment_concentration_check CHECK (pigment_concentration >= 0::numeric OR pigment_concentration = 'NaN'::numeric),
  CONSTRAINT samples_primary_production_isotope_uptake_check CHECK (primary_production_isotope_uptake >= 0::numeric OR primary_production_isotope_uptake = 'NaN'::numeric),
  CONSTRAINT samples_primary_production_oxygen_check CHECK (primary_production_oxygen >= 0::numeric OR primary_production_oxygen = 'NaN'::numeric),
  CONSTRAINT samples_salinity_check CHECK (salinity >= 0::numeric),
  CONSTRAINT samples_silicate_check CHECK (silicate >= 0::numeric OR silicate = 'NaN'::numeric),
  CONSTRAINT samples_turbidity_check CHECK (turbidity >= 0::numeric OR turbidity = 'NaN'::numeric),
  CONSTRAINT samples_water_depth_check CHECK (water_depth >= 0::numeric OR water_depth = 'NaN'::numeric),
  CONSTRAINT samples_water_temperature_check CHECK (water_temperature > (-273)::numeric)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE osdregistry.samples
  OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.samples TO megdb_admin;
GRANT SELECT ON TABLE osdregistry.samples TO megx_team WITH GRANT OPTION;
COMMENT ON TABLE osdregistry.samples
  IS 'Collected environmental samples';
GRANT UPDATE(label) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(label) ON osdregistry.samples TO megx_team;
GRANT UPDATE(start_lat) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(start_lat) ON osdregistry.samples TO megx_team;
GRANT UPDATE(start_lon) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(start_lon) ON osdregistry.samples TO megx_team;
GRANT UPDATE(stop_lat) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(stop_lat) ON osdregistry.samples TO megx_team;
GRANT UPDATE(stop_lon) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(stop_lon) ON osdregistry.samples TO megx_team;
GRANT UPDATE(max_uncertain) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(max_uncertain) ON osdregistry.samples TO megx_team;
GRANT UPDATE(water_depth) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(water_depth) ON osdregistry.samples TO megx_team;
GRANT UPDATE(local_date) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(local_date) ON osdregistry.samples TO megx_team;
GRANT UPDATE(local_start) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(local_start) ON osdregistry.samples TO megx_team;
GRANT UPDATE(local_end) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(local_end) ON osdregistry.samples TO megx_team;
GRANT UPDATE(protocol) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(protocol) ON osdregistry.samples TO megx_team;
GRANT UPDATE(objective) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(objective) ON osdregistry.samples TO megx_team;
GRANT UPDATE(platform) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(platform) ON osdregistry.samples TO megx_team;
GRANT UPDATE(device) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(device) ON osdregistry.samples TO megx_team;
GRANT UPDATE(water_temperature) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(water_temperature) ON osdregistry.samples TO megx_team;
GRANT UPDATE(salinity) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(salinity) ON osdregistry.samples TO megx_team;
GRANT UPDATE(curator) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(curator) ON osdregistry.samples TO megx_team;
GRANT UPDATE(curation_remark) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(curation_remark) ON osdregistry.samples TO megx_team;
GRANT UPDATE(ph) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(ph) ON osdregistry.samples TO megx_team;
GRANT UPDATE(phosphate) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(phosphate) ON osdregistry.samples TO megx_team;
GRANT UPDATE(nitrate) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(nitrate) ON osdregistry.samples TO megx_team;
GRANT UPDATE(carbon_organic_particulate) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(carbon_organic_particulate) ON osdregistry.samples TO megx_team;
GRANT UPDATE(nitrite) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(nitrite) ON osdregistry.samples TO megx_team;
GRANT UPDATE(carbon_organic_dissolved_doc) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(carbon_organic_dissolved_doc) ON osdregistry.samples TO megx_team;
GRANT UPDATE(nano_microplankton) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(nano_microplankton) ON osdregistry.samples TO megx_team;
GRANT UPDATE(downward_par) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(downward_par) ON osdregistry.samples TO megx_team;
GRANT UPDATE(conductivity) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(conductivity) ON osdregistry.samples TO megx_team;
GRANT UPDATE(primary_production_isotope_uptake) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(primary_production_isotope_uptake) ON osdregistry.samples TO megx_team;
GRANT UPDATE(primary_production_oxygen) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(primary_production_oxygen) ON osdregistry.samples TO megx_team;
GRANT UPDATE(dissolved_oxygen_concentration) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(dissolved_oxygen_concentration) ON osdregistry.samples TO megx_team;
GRANT UPDATE(nitrogen_organic_particulate_pon) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(nitrogen_organic_particulate_pon) ON osdregistry.samples TO megx_team;
GRANT UPDATE(meso_macroplankton) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(meso_macroplankton) ON osdregistry.samples TO megx_team;
GRANT UPDATE(bacterial_production_isotope_uptake) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(bacterial_production_isotope_uptake) ON osdregistry.samples TO megx_team;
GRANT UPDATE(nitrogen_organic_dissolved_don) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(nitrogen_organic_dissolved_don) ON osdregistry.samples TO megx_team;
GRANT UPDATE(ammonium) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(ammonium) ON osdregistry.samples TO megx_team;
GRANT UPDATE(silicate) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(silicate) ON osdregistry.samples TO megx_team;
GRANT UPDATE(bacterial_production_respiration) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(bacterial_production_respiration) ON osdregistry.samples TO megx_team;
GRANT UPDATE(turbidity) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(turbidity) ON osdregistry.samples TO megx_team;
GRANT UPDATE(fluorescence) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(fluorescence) ON osdregistry.samples TO megx_team;
GRANT UPDATE(pigment_concentration) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(pigment_concentration) ON osdregistry.samples TO megx_team;
GRANT UPDATE(picoplankton_flow_cytometry) ON osdregistry.samples TO megdb_admin;
GRANT UPDATE(picoplankton_flow_cytometry) ON osdregistry.samples TO megx_team;


-- Index: osdregistry.samples_start_lat_start_lon_water_depth_local_date_local_st_idx

-- DROP INDEX osdregistry.samples_start_lat_start_lon_water_depth_local_date_local_st_idx;

CREATE UNIQUE INDEX samples_start_lat_start_lon_water_depth_local_date_local_st_idx
  ON osdregistry.samples
  USING btree
  (start_lat, start_lon, water_depth, local_date, local_start, protocol COLLATE pg_catalog."default")
  WHERE start_lat <> 'NaN'::numeric AND start_lon <> 'NaN'::numeric;


-- Trigger: audit_trigger_row on osdregistry.samples

-- DROP TRIGGER audit_trigger_row ON osdregistry.samples;

CREATE TRIGGER audit_trigger_row
  AFTER INSERT OR UPDATE OR DELETE
  ON osdregistry.samples
  FOR EACH ROW
  EXECUTE PROCEDURE curation.if_modified_func('true', '{raw,start_geom,start_geog,stop_geom,stop_geog}');

-- Trigger: audit_trigger_stm on osdregistry.samples

-- DROP TRIGGER audit_trigger_stm ON osdregistry.samples;

CREATE TRIGGER audit_trigger_stm
  AFTER TRUNCATE
  ON osdregistry.samples
  FOR EACH STATEMENT
  EXECUTE PROCEDURE curation.if_modified_func('true');

-- Trigger: start_geom_geog_sync on osdregistry.samples

-- DROP TRIGGER start_geom_geog_sync ON osdregistry.samples;

CREATE TRIGGER start_geom_geog_sync
  BEFORE INSERT OR UPDATE OF start_lat, start_lon
  ON osdregistry.samples
  FOR EACH ROW
  WHEN (((new.start_lat IS DISTINCT FROM 'NaN'::numeric) AND (new.start_lon IS DISTINCT FROM 'NaN'::numeric)))
  EXECUTE PROCEDURE osdregistry.curation_samples_geom_trg();

-- Trigger: stop_geom_geog_sync on osdregistry.samples

-- DROP TRIGGER stop_geom_geog_sync ON osdregistry.samples;

CREATE TRIGGER stop_geom_geog_sync
  BEFORE INSERT OR UPDATE OF stop_lat, stop_lon
  ON osdregistry.samples
  FOR EACH ROW
  WHEN (((new.stop_lat IS DISTINCT FROM 'NaN'::numeric) AND (new.stop_lon IS DISTINCT FROM 'NaN'::numeric)))
  EXECUTE PROCEDURE osdregistry.curation_samples_geom_trg();




rollback;