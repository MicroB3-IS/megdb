
BEGIN;
SELECT _v.register_patch('00131-envoadd-envo-staging',
                          array['00130-osdregistry-fix-deleted-insert-funcs'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

-- for staging data into db
CREATE ROLE envo_stager NOLOGIN NOINHERIT;

GRANT envo_stager TO megx_team, megdb_admin;

CREATE SCHEMA envo_stage AUTHORIZATION megdb_admin;

GRANT ALL ON SCHEMA envo_stage TO GROUP envo_stager;

ALTER DEFAULT PRIVILEGES IN SCHEMA envo_stage REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA envo_stage GRANT ALL ON TABLES TO envo_stager;


SET ROLE envo_stager;


DROP TABLE IF EXISTS envo_stage.terms;

CREATE TABLE envo_stage.terms (
  id text check ( length(id) > 6 AND id ~ E'[0-9]+') PRIMARY KEY,
  term text,
  descr text,
  obsolete boolean NOT NULL default false,
  UNIQUE(term,obsolete)
);


commit;


