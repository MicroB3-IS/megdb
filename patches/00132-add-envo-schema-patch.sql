
BEGIN;
SELECT _v.register_patch('00132-add-envo-schema',
                          array['00131-envoadd-envo-staging'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;
CREATE SCHEMA envo AUTHORIZATION megdb_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA envo REVOKE ALL ON TABLES FROM PUBLIC;

CREATE TABLE envo.terms (
  id integer PRIMARY KEY,
  term text UNIQUE,
  descr text not null default ''
);


GRANT SELECT ON TABLE envo.terms TO megx_team, megxuser,megxnet;

\dp envo.terms

commit;


