begin;

SELECT _v.register_patch( '26-osd-registry', ARRAY['8-authdb'], NULL );

drop schema if exists osdregistry cascade;
create schema osdregistry;

alter schema osdregistry OWNER to megdb_admin;
set search_path = osdregistry, public, pg_catalog;
set default_tablespace = '';
set default_with_oids = false;


drop  table if exists osd_participants;
CREATE TABLE osdregistry.osd_participants
(
  id text NOT NULL,
  site_name text NOT NULL,
  site_lat double precision,
  site_long double precision,
  institution text,
  institution_lat double precision,
  institution_long double precision,
  institution_address text,
  institution_web_address text,
  site_coordinator text,
  coordinator_email text,
  country text,
  CONSTRAINT pk_osd_participants PRIMARY KEY (id)
);

insert into auth.web_resource_permissions(
            url_path, http_method, role)
    values 
    	('/osd/add*', 'all', 'admin'); -- must be admin to access the osd/add* URL as per design requirements for OSD registry

commit;