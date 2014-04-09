
BEGIN;
SELECT _v.register_patch('69-move-sample-view',
                          array['68-blast-overview-unknown'] );


ALTER VIEW web_r7.samples OWNER TO megdb_admin;
ALTER VIEW web_r7.samples SET SCHEMA web_r8;


commit;
