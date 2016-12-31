
BEGIN;
SELECT _v.register_patch('00154-myosd-gsheet-view',
                          array['00153-myosd-2016-insert-registration-func'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;

CREATE OR REPLACE VIEW myosd.gsheet_overview AS

SELECT
  id as submission_id,
  first_name || ' ' || last_name as name,
  user_name as benutzer_name,
  email,  
  date_trunc('minute', timezone('Europe/Berlin',submitted)) as datum, 
  has_kit as kit_ja_nein, myosd_id,post_station,  
  address_name as post_name, dhl_client_num as dhl_id,
  street_name as strasse,
  street_num as strassen_nummer,
  postal_code as postleitzahl,
  city as stadt,
  place_name as proben_ort,
  lat as latitude,
  lon as longitude
FROM myosd.registrations
;

--select * from myosd.gsheet_overview ;

commit;


