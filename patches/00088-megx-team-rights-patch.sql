
BEGIN;
SELECT _v.register_patch('00088-megx-team-rights',
                          array['00087-better-fix-myosd-form-data'] );


GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES, TRIGGER ON TABLE esa.oceans_sampled TO GROUP megdb_admin WITH GRANT OPTION;

ALTER TABLE osdregistry.osd_participants OWNER TO megdb_admin;
GRANT ALL ON TABLE osdregistry.osd_participants TO GROUP megdb_admin WITH GRANT OPTION;
REVOKE ALL ON TABLE osdregistry.osd_participants FROM mschneid;

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

-- mainly select rights for esa

GRANT ALL ON SCHEMA esa TO GROUP megx_team;
ALTER DEFAULT PRIVILEGES IN SCHEMA esa
    GRANT SELECT ON TABLES
    TO megx_team;

ALTER DEFAULT PRIVILEGES IN SCHEMA esa
    GRANT SELECT, UPDATE, USAGE ON SEQUENCES
    TO megx_team;

ALTER DEFAULT PRIVILEGES IN SCHEMA esa
    GRANT EXECUTE ON FUNCTIONS
    TO megx_team;

GRANT SELECT ON TABLE esa.gen_config TO GROUP megx_team;
GRANT SELECT ON TABLE esa.sample_images TO GROUP megx_team;
GRANT SELECT ON TABLE esa.samples TO GROUP megx_team;

GRANT SELECT ON TABLE esa.observations TO GROUP megx_team;
GRANT SELECT ON TABLE esa.oceans_sampled TO GROUP megx_team;

-- mainly select rigth for osd-registry

GRANT SELECT ON TABLE osdregistry.osd_raw_samples_id_seq TO GROUP megx_team;
GRANT SELECT ON TABLE osdregistry.test_samples_id_seq TO GROUP megx_team;
GRANT SELECT ON TABLE osdregistry.osd_participants TO GROUP megx_team;
GRANT SELECT ON TABLE osdregistry.osd_raw_samples TO GROUP megx_team;
GRANT SELECT ON TABLE osdregistry.test_samples TO GROUP megx_team;

GRANT ALL ON SCHEMA osdregistry TO GROUP megx_team;
ALTER DEFAULT PRIVILEGES IN SCHEMA osdregistry
    GRANT SELECT ON TABLES
    TO megx_team WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES IN SCHEMA osdregistry
    GRANT SELECT, UPDATE, USAGE ON SEQUENCES
    TO megx_team;

ALTER DEFAULT PRIVILEGES IN SCHEMA osdregistry
    GRANT EXECUTE ON FUNCTIONS
    TO megx_team;

-- for some test queries as user megxuser
-- SET ROLE megxuser


commit;


