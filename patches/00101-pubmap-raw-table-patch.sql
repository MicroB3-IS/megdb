
BEGIN;
SELECT _v.register_patch('00101-pubmap-raw-table',
                          array['00100-mibig-seq-perms'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

CREATE SCHEMA pubmap AUTHORIZATION megdb_admin;

GRANT USAGE ON SCHEMA pubmap TO megxuser;
GRANT USAGE ON SCHEMA pubmap TO selectors;

CREATE TABLE pubmap.raw_pubmap
(
  pmid integer NOT NULL,
  geom geometry,
  article_xml xml DEFAULT '<e/>'::xml,
  user_name text,
  megxbar json,
  created timestamp with time zone,
  CONSTRAINT raw_pubmap_pkey PRIMARY KEY (pmid)
);

GRANT SELECT,insert ON TABLE pubmap.raw_pubmap TO megxuser;  


-- for some test queries as user megxuser
-- SET ROLE megxuser;

commit;


