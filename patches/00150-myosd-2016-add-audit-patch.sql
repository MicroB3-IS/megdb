
BEGIN;
SELECT _v.register_patch('00150-myosd-2016-add-audit',
                          array['00149-myosd-2016'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


select curation.add_audit_trg('myosd.registrations', true, true);



commit;


