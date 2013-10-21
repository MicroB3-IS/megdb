
BEGIN;

SELECT _v.register_patch( '30-esa-db-user-rights', ARRAY['29-esa-citizenapp-fields', '25-esa-additional-settings-fields','14-esa-demo'], NULL );

REVOKE ALL ON TABLE esa.samples FROM megxuser;

GRANT SELECT, UPDATE, INSERT ON TABLE esa.samples TO megxuser;

REVOKE ALL ON TABLE esa.sample_images FROM megxuser;
GRANT SELECT, UPDATE, INSERT ON TABLE esa.sample_images TO megxuser;


commit;
