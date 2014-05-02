
BEGIN;
SELECT _v.register_patch('78-fix-spatial-table-perms',
                          array['77-fix-stage-owner'] );

GRANT ALL ON TABLE geometry_columns TO GROUP megdb_admin WITH GRANT OPTION;
GRANT ALL ON TABLE spatial_ref_sys TO GROUP megdb_admin WITH GRANT OPTION;

commit;
