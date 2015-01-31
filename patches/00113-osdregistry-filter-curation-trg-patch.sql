
BEGIN;
SELECT _v.register_patch('00113-osdregistry-filter-curation-trg',
                          array['00112-osdregistry-filter-grant'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

SELECT curation.add_audit_trg('osdregistry.filters', true,true, '{raw}');

commit;


