
BEGIN;
SELECT _v.register_patch('00102-pubmap-add-columns',
                          array['00101-pubmap-raw-table'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;

alter table pubmap.raw_pubmap ADD column world_region text NOT NULL default '';

alter table pubmap.raw_pubmap ADD column place text NOT NULL default '';


commit;


