
BEGIN;
SELECT _v.register_patch('00151-myosd-2016-allow-many-kits-from-one-email',
                          array['00150-myosd-2016-add-audit'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

ALTER TABLE myosd.registrations DROP CONSTRAINT registrations_email_key;
ALTER TABLE myosd.registrations ADD UNIQUE (email,myosd_id);

commit;


