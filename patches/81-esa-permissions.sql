
BEGIN;
SELECT _v.register_patch('81-esa-permissions',
                          array['80-esa-samples-nan-defaults.sql'] );



ALTER TABLE esa.gen_config OWNER TO megdb_admin;

ALTER TABLE esa.gen_config OWNER TO megdb_admin;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE esa.sample_images TO megxuser;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE esa.sample_images TO megxuser;

GRANT USAGE ON SCHEMA esa TO megxuser;

GRANT SELECT ON TABLE esa.observations TO megxuser;

GRANT SELECT ON TABLE esa.oceans_sampled TO megxuser;


GRANT SELECT ON TABLE esa.oceans_sampled TO megxuser;


commit;
