
BEGIN;
SELECT _v.register_patch('00153-myosd-2016-insert-registration-func',
                          array['00152-myosd-2016-all-columns'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;

GRANT UPDATE (reg_confirmed) ON myosd.registrations TO megxuser;

CREATE OR REPLACE FUNCTION myosd.ins_myosd_regisration(
       in_email text,
       in_user_name text,
       in_myosd_id integer,
       in_schema_version integer,
       in_raw json) RETURNS void AS $$

INSERT INTO myosd.registrations(
  myosd_id,
  email,  user_name,  "raw", schema_version, 
  first_name, last_name,
  has_kit,
  post_station,
  address_name,
    dhl_client_num,
  street_name,
  street_num,
  postal_code,
  city,
  place_name,  lat,  lon,  bounds,
  terms_agree,
  osd_agree,
  sensebox_agree,
  geom, geog)
VALUES (
  CASE WHEN in_myosd_id = 0 THEN null::integer ELSE in_myosd_id END,
  in_email,  in_user_name,  in_raw, in_schema_version,
  in_raw->>'firstname',  in_raw->>'lastname',
  (in_raw->>'kit')::boolean,
  COALESCE ( in_raw->>'post_station', '' ),
  CASE in_raw->>'post_station'
     WHEN 'post' THEN in_raw#>>'{address,name}'
     WHEN 'station' THEN in_raw#>>'{station,name}'
     ELSE ''
  END,
  CASE in_raw->>'post_station'
    WHEN 'station' THEN (in_raw#>>'{station,post_num}')::integer
    ELSE 0
  END,
  CASE in_raw->>'post_station'
    WHEN 'post' THEN in_raw#>>'{address,street}'
    WHEN 'station' THEN ''
    ELSE ''
  END,
  CASE in_raw->>'post_station'
    WHEN 'post' THEN in_raw#>>'{address,street_num}'
    WHEN 'station' THEN in_raw#>>'{station,station_num}'
    ELSE ''
  END,
  CASE in_raw->>'post_station'
    WHEN 'post' THEN in_raw#>>'{address,poastal_code}'
    WHEN 'station' THEN in_raw#>>'{station,station_num}'
    ELSE ''
  END,
  CASE in_raw->>'post_station'
    WHEN 'post' THEN in_raw#>>'{address,city}'
    WHEN 'station' THEN in_raw#>>'{station,city}'
    ELSE ''
  END,
  in_raw->>'placename', (in_raw->>'lat')::numeric, (in_raw->>'lon')::numeric, in_raw->>'bounds',
  (in_raw#>>'{terms,terms_agree}')::boolean,
  (in_raw#>>'{terms,osd_agree}')::boolean,
  (in_raw#>>'{terms,sensebox_agree}')::boolean,
  ST_geomFromText( 'POINT(' || (in_raw->>'lon') || ' ' || (in_raw->>'lat') || ')', 4326),
  ST_GeographyFromText( 'POINT(' || (in_raw->>'lon')  || ' ' || (in_raw->>'lat') || ')' )
   
);
$$ LANGUAGE SQL;

GRANT EXECUTE ON FUNCTION myosd.ins_myosd_regisration(
       in_email text, in_user_name text,
       in_myosd_id integer,
       in_schema_version integer,
       in_raw json) to megxnet, megx_team;

commit;


