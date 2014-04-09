
BEGIN;
SELECT _v.register_patch('73-stage_r8-permissions',
                          array['72-fix-sample-view-permissions'] );


drop table if exists stage_r8.viral_metagenomes;

ALTER TABLE stage_r8.whale_falls OWNER TO megdb_admin;

ALTER TABLE if exists stage_r8.osd_data_201402 OWNER TO megdb_admin;

ALTER TABLE stage_r8.marine_phages OWNER TO megdb_admin;

ALTER TABLE if exists stage_r8.malaspina_stations OWNER TO megdb_admin;

ALTER TABLE if exists stage_r8.ena_samples OWNER TO megdb_admin;
GRANT SELECT ON TABLE  stage_r8.ena_samples TO megxuser;


GRANT USAGE ON SCHEMA osdregistry TO megxuser;
GRANT SELECT ON TABLE osdregistry.osd_participants TO megxuser;



commit;
