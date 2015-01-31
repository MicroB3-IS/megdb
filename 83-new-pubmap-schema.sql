BEGIN;

SELECT _v.register_patch('83-new-pubmap-schema.sql','{}',NULL);

CREATE SCHEMA pubmap AUTHORIZATION megdb_admin;

GRANT ALL ON SCHEMA pubmap TO megdb_admin;
GRANT ALL ON SCHEMA pubmap TO megxuser;
GRANT ALL ON SCHEMA pubmap TO selectors;

ALTER DEFAULT PRIVILEGES IN SCHEMA pubmap
    GRANT SELECT ON TABLES
    TO megxuser;
    
    
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

GRANT SELECT ON TABLE pubmap.raw_pubmap TO megxuser;  

commit;
