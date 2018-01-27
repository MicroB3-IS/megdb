-- Function: osdregistry.attempt_georef()

-- DROP FUNCTION osdregistry.attempt_georef();

CREATE OR REPLACE FUNCTION osdregistry.attempt_georef()
  RETURNS trigger AS
$BODY$
       DECLARE
	lat numeric;
	lon numeric;
	water_depth numeric;
	local_date date;
	local_start time(0);
	local_end time(0);
	tz text;
       BEGIN
       --
       -- Attempt to insert value into curated column from verbatim column.
       -- Hence this trigger is only defined to work on insert
       --
       RAISE NOTICE 'start lat lon trigger fired';
       IF (TG_OP != 'INSERT') THEN
       	  -- just doing nothing
           RETURN NEW;
       END IF;
       -- now depth parsed from verbatim or simply the current unchanged defaults
       water_depth := osdregistry.parse_numeric( NEW.water_depth_verb, NEW.water_depth );
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.is_in_range(water_depth, 0::numeric, 12000::numeric  ) THEN
       	  NEW.water_depth := water_depth;
       END IF;

       -- now local date parsed from verbatim or simply the current unchanged defaults
       local_date :=  osdregistry.parse_date( NEW.local_date_verb, NEW.local_date ) ;
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_date( local_date ) THEN
       	  NEW.local_date := local_date;
       END IF;

       RAISE NOTICE 'verb times: % and % ', NEW.local_start_verb, NEw.local_end_verb;
       
       local_start :=  osdregistry.parse_local_time( NEW.local_start_verb, NEW.local_start::time without time zone ) ;
       local_end :=  osdregistry.parse_local_time( NEW.local_end_verb, NEW.local_end::time without time zone) ;



       -- now lat/lon are either parsed from verbatim or simply the current unchanged defaults
       lat := osdregistry.parse_numeric( NEW.start_lat_verb, NEW.start_lat );
       lon := osdregistry.parse_numeric( NEW.start_lon_verb, NEW.start_lon );
       -- therefore simply check if valid and just assign in any case
       IF osdregistry.valid_lat_lon( lat, lon ) THEN
       	  NEW.start_lat := lat;
       	  NEW.start_lon := lon;
	  SELECT CASE WHEN time_zone = 'UTC±00:00'
                      THEN '+00:00'
                      ELSE substring(time_zone from 4)
		 END
  	    INTO STRICT tz
	    FROM elayers.world_time_zones tz
  	   WHERE ( ST_intersects (
	             ST_geometryFromText('POINT(' || NEW.start_lon || ' ' || NEW.start_lat ||')', 4326 ),
		     tz.geom)
		 );
           NEW.local_start := (local_start || tz)::time(0) with time zone;
           NEW.local_end := (local_end || tz)::time(0) with time zone;

       END IF;

       RETURN NEW; 
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION osdregistry.attempt_georef()
  OWNER TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.attempt_georef() TO public;
GRANT EXECUTE ON FUNCTION osdregistry.attempt_georef() TO megdb_admin;
GRANT EXECUTE ON FUNCTION osdregistry.attempt_georef() TO megx_team;
