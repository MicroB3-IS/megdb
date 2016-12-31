
BEGIN;
SELECT _v.register_patch('00159-myosd-samples-table',
                          array['00158-myosd-sample-registration'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- DROP FUNCTION myosd.curation_samples_geom_trg();

CREATE OR REPLACE FUNCTION myosd.curation_samples_geom_trg()
  RETURNS trigger AS
$BODY$

DECLARE

BEGIN
   IF (NEW.start_lat IS DISTINCT FROM 'nan' 
          AND NEW.start_lon IS DISTINCT FROM 'nan') THEN
      NEW.start_geom 
         := st_geometryFromText(
               'POINT(' || NEW.start_lon || ' ' || NEW.start_lat ||')',
               4326 
            );
       RAISE DEBUG 'start geom=%', st_asText(NEW.start_geom);
      NEW.start_geog := NEW.start_geom::geography;
   END IF;
 
   RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

REVOKE EXECUTE ON FUNCTION osdregistry.curation_samples_geom_trg() from public;
GRANT EXECUTE ON FUNCTION osdregistry.curation_samples_geom_trg() TO megx_team,megxuser;



-- for some test queries as user megxuser
-- SET ROLE megxuser;

-- Table: osdregistry.samples

-- DROP TABLE myosd.samples;

CREATE TABLE myosd.samples
(
  myosd_id integer PRIMARY KEY check (myosd_id >=0),
  submission_id bigint NOT NULL default 0,
  label text not null default '',
  label_verb text NOT NULL DEFAULT ''::text,
  start_lat numeric DEFAULT 'NaN'::numeric,
  start_lon numeric DEFAULT 'NaN'::numeric,
  start_lat_verb text NOT NULL default '',
  start_lon_verb text NOT NULL  default '',
  max_uncertain numeric NOT NULL DEFAULT 'NaN'::numeric,
  water_depth numeric NOT NULL DEFAULT 'NaN'::numeric,
  water_depth_verb text NOT NULL DEFAULT ''::text,
  local_date date NOT NULL DEFAULT 'infinity'::date,
  local_date_verb text NOT NULL DEFAULT ''::text,
  local_start time(0) with time zone,
  local_start_verb text NOT NULL DEFAULT ''::text,
  local_end time(0) with time zone,
  local_end_verb text NOT NULL DEFAULT ''::text,
  
  water_temperature numeric NOT NULL DEFAULT 'NaN'::numeric,
  water_temperature_verb text NOT NULL DEFAULT ''::text,
  salinity numeric NOT NULL DEFAULT 'NaN'::numeric,
  salinity_verb text NOT NULL DEFAULT ''::text,
  biome text NOT NULL DEFAULT 'biome'::text,
  biome_verb text NOT NULL DEFAULT ''::text,
  curator text NOT NULL DEFAULT ''::text,
  curation_remark text NOT NULL DEFAULT ''::text,
  ph numeric NOT NULL DEFAULT 'NaN'::numeric,
  ph_verb text NOT NULL DEFAULT ''::text,

  other_params json NOT NULL DEFAULT '{}'::json,
  remarks json NOT NULL DEFAULT '{}'::json,
  raw_json json,
  start_geog geography(Point,4326),
  start_geom geometry,
  ena_acc text NOT NULL DEFAULT ''::text,
  biosample_acc text NOT NULL DEFAULT ''::text,

  submitted timestamp with time zone NOT NULL DEFAULT now(),
  modified timestamp with time zone NOT NULL DEFAULT now(),


  CONSTRAINT envo_biome_terms_fk FOREIGN KEY (biome)
      REFERENCES envo.terms (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,

  CONSTRAINT enforce_dims_start_geom CHECK (st_ndims(start_geom) = 2),

  CONSTRAINT enforce_geotype_start_geom CHECK (geometrytype(start_geom) = 'POINT'::text OR start_geom IS NULL),

  CONSTRAINT enforce_srid_start_geom CHECK (st_srid(start_geom) = 4326),


  CONSTRAINT samples_ph_check CHECK (ph >= 0::numeric AND ph < (+ 12)::numeric OR ph = 'NaN'::numeric),

  CONSTRAINT samples_salinity_check CHECK (salinity >= 0::numeric),

  CONSTRAINT samples_water_depth_check CHECK (water_depth >= 0::numeric OR water_depth = 'NaN'::numeric),
  CONSTRAINT samples_water_temperature_check CHECK (water_temperature > (-273)::numeric)
)
WITH (
  OIDS=FALSE
);


GRANT SELECT ON TABLE myosd.samples TO megx_team WITH GRANT OPTION;
GRANT SELECT ON TABLE myosd.samples TO megxuser;

COMMENT ON TABLE myosd.samples
  IS 'Collected environmental samples by MyOSD participants';

GRANT UPDATE (
      label, start_lat, start_lon, max_uncertain,
      water_depth, local_date, local_start,
      water_temperature, salinity, ph,
      curator, curation_remark) ON myosd.samples TO megx_team, megxuser;

CREATE UNIQUE INDEX samples_start_lat_start_lon_water_depth_local_date_local_st_idx
  ON myosd.samples
  USING btree
  (start_lat, start_lon, water_depth, local_date, local_start)
  WHERE start_lat <> 'NaN'::numeric AND start_lon <> 'NaN'::numeric;


CREATE TRIGGER audit_trigger_row
  AFTER INSERT OR UPDATE OR DELETE
  ON myosd.samples
  FOR EACH ROW
  EXECUTE PROCEDURE curation.if_modified_func('true', '{raw,start_geom,start_geog,stop_geom,stop_geog}');

-- Trigger: audit_trigger_stm on myosd.samples

-- DROP TRIGGER audit_trigger_stm ON myosd.samples;

CREATE TRIGGER audit_trigger_stm
  AFTER TRUNCATE
  ON myosd.samples
  FOR EACH STATEMENT
  EXECUTE PROCEDURE curation.if_modified_func('true');

-- Trigger: start_geom_geog_sync on myosd.samples

-- DROP TRIGGER start_geom_geog_sync ON myosd.samples;

CREATE TRIGGER start_geom_geog_sync
  BEFORE INSERT OR UPDATE OF start_lat, start_lon
  ON myosd.samples
  FOR EACH ROW
  WHEN (((new.start_lat IS DISTINCT FROM 'NaN'::numeric) AND (new.start_lon IS DISTINCT FROM 'NaN'::numeric)))
  EXECUTE PROCEDURE myosd.curation_samples_geom_trg();

rollback;


