
BEGIN;
SELECT _v.register_patch('00158-myosd-sample-registration',
                          array['00157-esa-myosd-patch'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path = myosd,public;

CREATE TABLE myosd.sample_registrations (

  submission_id integer not null default 0,  
  full_name text not null check (full_name != ''),  
  user_name text not null ,  
  email text not null ,  


  myosd_id integer PRIMARY KEY check ( myosd_id > 270 ),  
  post_station text not null default '',  
  post_name text not null default '',  
  dhl_id integer null default 0,  
  street_name text not null default '',  
  street_num text not null default '',  
  postal_code text not null default '',  
  city text not null  default '',  
  place_name text not null default '',  
  latitude numeric not null  default 'nan',  
  longitude numeric not null default 'nan',  
  kit_sending_date date not null default 'infinity',  
  sending_num text not null default '0',  	      
  hub text not null  default '',  
  kit_arrival_date date not null default 'infinity',  
  salinity numeric not null default 'nan',  
  ph numeric not null default 'nan'  
  
);  
  
grant select  
   on table myosd.sample_registrations  
   to megx_team, megxuser;  
  
-- for some test queries as user megxuser  
-- SET ROLE megxuser;  
commit;
