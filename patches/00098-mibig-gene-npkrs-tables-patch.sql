
BEGIN;
SELECT _v.register_patch('00098-mibig-gene-npkrs-tables',
                          array['00097-mg-traits-test-friendly-cnstrnt-patch'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


CREATE TABLE gene_submissions (
  id SERIAL PRIMARY KEY,
  bgc_id text NOT NULL default 'BGC00000',
  submitted timestamp with time zone NOT NULL default now(),
  modified  timestamp with time zone NOT NULL default now(),
  raw json NOT NULL,
  v integer NOT NULL DEFAULT 0
);


CREATE TABLE nrps_submissions (
  id SERIAL PRIMARY KEY,
  bgc_id text NOT NULL default 'BGC00000',
  submitted timestamp with time zone NOT NULL default now(),
  modified  timestamp with time zone NOT NULL default now(),
  raw json NOT NULL,
  v integer NOT NULL DEFAULT 0
);





-- for some test queries as user megxuser
-- SET ROLE megxuser


rollback;


