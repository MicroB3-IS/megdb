
BEGIN;
SELECT _v.register_patch('00149-myosd-2016',
                          array['00148-osdregistry-better-sample-data-view.sql'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


CREATE schema myosd
  AUTHORIZATION megdb_admin;

GRANT ALL ON SCHEMA myosd TO megdb_admin;
GRANT USAGE ON SCHEMA myosd TO megxuser;
GRANT ALL ON SCHEMA myosd TO megx_team;

ALTER DEFAULT PRIVILEGES IN SCHEMA myosd
    GRANT SELECT ON TABLES
    TO megx_team WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES IN SCHEMA myosd
    GRANT SELECT, UPDATE, USAGE ON SEQUENCES
    TO megx_team;

ALTER DEFAULT PRIVILEGES IN SCHEMA myosd
    GRANT EXECUTE ON FUNCTIONS
    TO megx_team;

CREATE TABLE myosd.registrations (
  id serial PRIMARY KEY,
  myosd_id integer UNIQUE check (myosd_id > 270 ),
  email text NOT NULL UNIQUE,
  user_name text NOT NULL UNIQUE check ( char_length(user_name) > 1 ),
  
  submitted timestamp with time zone NOT NULL DEFAULT now(),
  modified timestamp with time zone NOT NULL DEFAULT now(),
  raw json NOT NULL DEFAULT '{}'::json,
  schema_version integer check(schema_version > 0)	
);

GRANT select, insert on myosd.registrations to megxuser;
GRANT SELECT,USAGE ON SEQUENCE  myosd.registrations_id_seq TO megxuser;


rollback;


