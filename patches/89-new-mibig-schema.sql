﻿BEGIN;

SELECT _v.register_patch('89-new-mibig-schema.sql','{}',NULL);

CREATE SCHEMA mibig AUTHORIZATION megdb_admin;

GRANT ALL ON SCHEMA mibig TO megdb_admin;
GRANT ALL ON SCHEMA mibig TO megxuser;
GRANT ALL ON SCHEMA mibig TO selectors;

ALTER DEFAULT PRIVILEGES IN SCHEMA mibig
    GRANT SELECT ON TABLES
    TO megxuser;
    
    
CREATE TABLE mibig.submissions
(
  id SERIAL PRIMARY KEY,
  submitted timestamptz NOT NULL DEFAULT NOW(),
  modified  timestamptz NOT NULL DEFAULT NOW(),
  raw  json NOT NULL DEFAULT '{}',
  version integer check (version > 0) 
);

ALTER TABLE mibig.submissions
  OWNER TO postgres;
GRANT ALL ON TABLE mibig.submissions TO postgres;
GRANT SELECT ON TABLE mibig.submissions TO megxuser;  

commit;