
BEGIN;
SELECT _v.register_patch('00152-myosd-2016-all-columns',
                          array['00151-myosd-2016-allow-many-kits-from-one-email'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


ALTER TABLE myosd.registrations
      ADD first_name text check (first_name <> ''),
      ADD last_name text  check (last_name <> ''),
      ADD has_kit boolean NOT NULL DEFAULT false,
      ADD post_station text NOT NULL DEFAULT '' check (post_station IN ('post','station', '') )	,
      ADD address_name text NOT NULL DEFAULT '',
      ADD dhl_client_num integer NOT NULL DEFAULT 0 check(dhl_client_num >= 0),
      ADD street_name text NOT NULL DEFAULT '',
      ADD street_num text NOT NULL DEFAULT '',
      ADD postal_code text NOT NULL DEFAULT '',
      ADD city text NOT NULL DEFAULT '',
      ADD place_name text NOT NULL check (place_name <> '') DEFAULT 'na',
      ADD lat numeric NOT NULL DEFAULT 'NaN',
      ADD lon numeric NOT NULL DEFAULT 'NaN',
      ADD bounds text NOT NULL DEFAULT '',
      ADD terms_agree boolean CHECK (terms_agree = true),
      ADD osd_agree boolean  NOT NULL DEFAULT false,
      ADD sensebox_agree boolean  NOT NULL DEFAULT false,
      ADD reg_confirmed boolean  NOT NULL DEFAULT false,
      ADD email_valid boolean  NOT NULL DEFAULT true,
      ADD geog GEOGRAPHY(POINT,4326)
      ;

 SELECT AddGeometryColumn ('myosd','registrations','geom',4326,'POINT',2);



CREATE FUNCTION myosd.upd_myosd_regisrations_from_json() RETURNS void AS $$

UPDATE myosd.registrations
   SET first_name  = raw->>'firstname',
   last_name = raw->>'lastname',
   has_kit = (raw->>'kit')::boolean,
   post_station = COALESCE ( raw->>'post_station', '' ),
   address_name = CASE raw->>'post_station'
                    WHEN 'post' THEN raw#>>'{address,name}'
                    WHEN 'station' THEN raw#>>'{station,name}'
		    ELSE ''
                  END,
   dhl_client_num = CASE raw->>'post_station'
                      WHEN 'station' THEN (raw#>>'{station,post_num}')::integer
		      ELSE 0
		    END,
   street_name = CASE raw->>'post_station'
                    WHEN 'post' THEN raw#>>'{address,street}'
                    WHEN 'station' THEN ''
		    ELSE ''
                  END,
   street_num =  CASE raw->>'post_station'
                    WHEN 'post' THEN raw#>>'{address,street_num}'
                    WHEN 'station' THEN raw#>>'{station,station_num}'
		    ELSE ''
                  END,
   postal_code = CASE raw->>'post_station'
                    WHEN 'post' THEN raw#>>'{address,poastal_code}'
                    WHEN 'station' THEN raw#>>'{station,station_num}'
		    ELSE ''
                  END,
   city = CASE raw->>'post_station'
            WHEN 'post' THEN raw#>>'{address,city}'
            WHEN 'station' THEN raw#>>'{station,city}'
	    ELSE ''
          END,
   place_name = raw->>'placename',
   lat = (raw->>'lat')::numeric,
   lon = (raw->>'lon')::numeric,
   bounds = raw->>'bounds',
   terms_agree = (raw#>>'{terms,terms_agree}')::boolean,
   osd_agree = (raw#>>'{terms,osd_agree}')::boolean,
   sensebox_agree = (raw#>>'{terms,sensebox_agree}')::boolean,

   geom = ST_geomFromText( 'POINT(' || (raw->>'lon') || ' ' || (raw->>'lat') || ')', 4326),
   geog = ST_GeographyFromText( 'POINT(' || (raw->>'lon')  || ' ' || (raw->>'lat') || ')' )
   
 WHERE first_name IS NULL;


$$ LANGUAGE SQL;

GRANT EXECUTE ON FUNCTION myosd.upd_myosd_regisrations_from_json() to megxnet, megx_team;


-- need to update new colums to also apply not null constraints
select myosd.upd_myosd_regisrations_from_json();

ALTER TABLE myosd.registrations
      ALTER first_name SET NOT NULL,
      ALTER last_name  SET NOT NULL,
      ALTER terms_agree SET NOT NULL,
      ALTER geom SET NOT NULL,
      ALTER geog SET NOT NULL
;

 CREATE INDEX ON myosd.registrations USING GIST ( geog );
  CREATE INDEX ON myosd.registrations USING GIST ( geom );

--select * from myosd.registrations;

--\d myosd.registrations


--select st_astext(geom) as geom, st_astext(geog) from myosd.registrations;

commit;


