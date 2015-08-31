
BEGIN;
SELECT _v.register_patch('00126-osdregistry-add-site-func',
                          array['00125-osdregistry-instiute-sites-refactor'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


GRANT INSERT ON TABLE osdregistry.institutes TO megx_team;
GRANT INSERT ON TABLE osdregistry.sites TO megx_team;
GRANT INSERT,update ON TABLE osdregistry.institute_sites TO megx_team;




CREATE FUNCTION osdregistry.add_site (
  campaign text,
  id integer,
  site_name text,
  institute text,
  lat double precision,
  lon double precision,
  curator text,
  curation_remark text
) 
  RETURNS osdregistry.sites  AS
$BODY$
      INSERT INTO osdregistry.sites (
         --campaign,
         id,
         label, label_verb,
         lat, lat_verb,
         lon, lon_verb,
         curator, curation_remark
       ) VALUES (
         --campaign,
         id,
         site_name,
         institute,
         lat, lat::text,
         lon, lon::text,
         curator,
         curation_remark
       )   RETURNING *;      
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

REVOKE ALL ON FUNCTION
  osdregistry.add_site (
    text, integer, text,text,double precision,double precision, text,text
  )
  FROM public;
GRANT ALL ON FUNCTION
  osdregistry.add_site (
    text, integer, text,text,double precision,double precision, text,text
  )
  TO megxuser,megx_team;



CREATE FUNCTION osdregistry.add_site_institute_connect (
  campaign text,
  id integer,
  site_name text,
  lat double precision,
  lon double precision,
  institute text,
  curator text,
  curation_remark text
)
RETURNS osdregistry.institute_sites AS
$f$
   select osdregistry.add_site(
         campaign,
         id,
         site_name,
         institute,
         lat, lon,
         curator, curation_remark

   ); 
      INSERT INTO osdregistry.institute_sites (label,id,campaign)
           VALUES (institute, id, campaign)
        RETURNING *;

$f$
LANGUAGE SQL VOLATILE;



CREATE FUNCTION osdregistry.add_institute (
  institute text,
  country text,
  lat double precision,
  lon double precision,
  curator text,
  curation_remark text
) RETURNS osdregistry.institutes AS $f$

  INSERT INTO osdregistry.institutes (
    label, label_verb,
    lat, lat_verb,
    lon, lon_verb,
    country, country_verb,
    curator,
    curation_remark
  ) VALUES (
    institute, institute,
    lat, lat::text,
    lon, lon::text,
    country, country,
    curator,
    curation_remark
  ) RETURNING *;
  
$f$ LANGUAGE SQL VOLATILE;

REVOKE ALL ON FUNCTION
  osdregistry.add_institute (
    text, text,double precision,double precision, text,text
  )
  FROM public;
GRANT ALL ON FUNCTION
  osdregistry.add_institute (
    text, text,double precision,double precision, text,text
  )
  TO megxuser,megx_team;



CREATE FUNCTION osdregistry.add_site_institute (
  campaign text,
  id integer,
  site_name text,
  site_lat double precision,
  site_lon double precision,
  institute text,
  country text,
  institute_lat double precision,
  institute_lon double precision,
  curator text,
  curation_remark text
) 
  RETURNS osdregistry.institute_sites AS
$BODY$
  select osdregistry.add_institute (
    institute,
    country,
    institute_lat, institute_lon,
    curator, curation_remark
  );

  select osdregistry.add_site_institute_connect (
     campaign,
     id,
     site_name,
     site_lat, site_lon,
     institute,
     curator, curation_remark
   );
   
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

REVOKE ALL ON FUNCTION osdregistry.add_site_institute (
       text, integer, text,double precision,double precision,text,text,double precision,double precision, text,text)
  FROM public;

GRANT EXECUTE ON FUNCTION osdregistry.add_site_institute (
      text, integer, text,double precision,double precision,text,text,double precision,double precision, text,text)
   TO megxuser,megx_team;


-- for some test queries as user megxuser
SET ROLE megx_team;


select osdregistry.add_site_institute_connect (
  'OSD'::text,
   192,
  'Tjärnö'::text,
   58.877949::double precision,
   11.126123::double precision,
   'Sven Loven Center for Marine Sciences, Tjärnö laboratory, University of Gothenburg'::text,
   'rkottman'::text, 'adding for 2015'::text );


SELECT osdregistry.add_site_institute_connect (
  'OSD',
   193,
   'ElmaxAlex',
   31.116::double precision,
   29.833::double precision,
   'University of Alexandria',
   'rkottman'::text, 'adding for 2015'::text );


SELECT osdregistry.add_site_institute (
  'OSD',
   194,
   'Zelenogradsk',
   31.21060::double precision,
   29.91308::double precision,
   'Immanuel Kant Baltic Federal University, Winogradsky Institute of microbiology, RAS, Moscow',
   'Russia',
   54.96::double precision,
   20.15::double precision,
   'rkottman'::text, 'adding for 2015'::text );

select osdregistry.add_institute (
  'University of Oslo',
  'Norway',
  59.89809::double precision,
  10.69491::double precision,
 'rkottman'::text, 'got assigned to OSD 155'::text 
);

UPDATE osdregistry.institute_sites set label = 'University of Oslo' where campaign = 'OSD' and id = 155;
UPDATE osdregistry.institute_sites set label = 'University of Oslo' where campaign = 'OSD' and id = 157;



SELECT osdregistry.add_site_institute (
  'OSD',
   195,
   'Saline di Margherita di Savoia',
   41.383588::double precision,
   16.127715::double precision,
   'Institute of Biomembranes and Bioenergetics of the Italian national research council (CNR)',
   'Italy',
   41.1099778::double precision,
   16.883731::double precision,
   'rkottman'::text, 'adding for 2015'::text );


SELECT osdregistry.add_site_institute (
  'OSD',
   196,
   'Shark Bay, Australia',
   -26.448::double precision,
   114.095::double precision,
   'The University of New South Wales',
   'Australia',
   -33.918::double precision,
   151.231::double precision,
   'rkottman'::text, 'adding for 2015'::text );

SELECT osdregistry.add_site_institute (
  'OSD',
   197,
   'Anjafa Beach (Kuwait)',
   29.280125::double precision,
   48.089031::double precision,
   'CEFAS (UK)',
   'Kuwait',
   52.878565::double precision,
   1.718148::double precision,
   'rkottman'::text, 'adding for 2015'::text );


SELECT osdregistry.add_site_institute_connect (
  'OSD',
   198,
   'Fram Strait 2',
   79::double precision,
   -13::double precision,
   'Alfred Wegener Institute Helmholtz Center for Polar and Marine Research',
   'rkottman'::text, 'adding for 2015'::text );


SELECT osdregistry.add_site_institute (
  'OSD',
   199,
   'Monterey Bay NMS',
   36.603298::double precision,
   -121.889377::double precision,
   '36.603298, -121.889377',
   'USA',
   36.603298::double precision,
   -121.889377::double precision,
   'rkottman'::text, 'adding for 2015'::text );


SELECT osdregistry.add_site_institute (
  'OSD',
   200,
   'Arctic Ocean N-ICE 2015',
   80.3010::double precision,
   6.2063::double precision,
   'Norwegian Polar Institute',
   'Norway',
   69.6437::double precision,
    18.9491::double precision,
   'rkottman'::text, 'adding for 2015'::text );



commit;


