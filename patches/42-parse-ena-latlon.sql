BEGIN;

SELECT _v.register_patch( '42-parse-ena-latlon', NULL, NULL );


CREATE OR REPLACE FUNCTION core.parse_ena_latlon(i text, srid integer)
  RETURNS geometry AS
$BODY$
   DECLARE
     lon double precision;
     lat double precision;
     p text;
     r geometry;
   BEGIN
      IF i ISNULL THEN
        RETURN r;
      END IF;
     
      IF srid ISNULL then
        srid := -1;
      END IF;
 
      p:=upper(i);
      lat:=substring(p from E'^([1-9]?[0-9](\\.[0-9]+)?) [NS]')::double precision;
        --90 bis 90
      lon:=substring(p from E' ((([1]?[0-9])?[0-9])(\\.[0-9]+)?) [WE]')::double precision;
        --180 bis -180
      IF lat IS NULL OR lon IS NULL THEN
        RAISE DEBUG 'Longitude or Latitude is wrong';
        RETURN NULL;
      END IF;

      IF lat > 90 OR lat < -90 THEN
        RAISE DEBUG 'Latitude is out of range=%. Should be between -90 to 90', lat;
        RETURN NULL;
      END IF;

      IF lon > 180 OR lon < -180 THEN
        RAISE DEBUG 'Longitude is out of range=%. Should be between -180 to 180', lon;
        RETURN NULL;
      END IF;

      IF position('S' in p) > 0 THEN
        lat := lat * -1;
      END IF; 

      IF position('W' in p) > 0 THEN
        lon := lon * -1;
      END IF; 

      r := st_pointfromtext(('Point ('::text || lon || ' ' || lat || ')'::text), srid);
            
      RETURN r;
   END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION core.parse_ena_latlon(text,integer) OWNER TO core_admin;

GRANT EXECUTE ON FUNCTION core.parse_ena_latlon(text,integer) TO megx_team;

commit;
