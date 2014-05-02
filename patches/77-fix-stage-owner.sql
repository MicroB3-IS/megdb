
BEGIN;
SELECT _v.register_patch('77-fix-stage-owner',
                          array['76-faster-esa-observation-view'] );


REVOKE ALL ON SCHEMA stage_r8 FROM GROUP curation_admin;
GRANT ALL ON SCHEMA stage_r8 TO GROUP curation_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA stage_r8 TO GROUP megdb_admin WITH GRANT OPTION;

commit;
