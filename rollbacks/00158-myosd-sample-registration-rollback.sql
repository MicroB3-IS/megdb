
BEGIN;

SELECT _v.unregister_patch( '00158-myosd-sample-registration');

SET ROLE megdb_admin;

set search_path = myosd,public;

DROP TABLE myosd.sample_registrations;

commit;
