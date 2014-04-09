
BEGIN;
SELECT _v.register_patch('71-fix-sample-view-permissions',
                          array['70-new-sample-view'] );


ALTER TABLE web_r8.genomes OWNER TO megdb_admin;
ALTER TABLE core.isolates OWNER TO megdb_admin; 

ALTER TABLE core.samples OWNER TO megdb_admin; 

ALTER TABLE core.samplingsites OWNER TO megdb_admin; 

ALTER TABLE web_r8.metagenomes OWNER TO megdb_admin;
ALTER TABLE web_r8.marine_phages OWNER TO megdb_admin;

ALTER TABLE web_r8.silva OWNER TO megdb_admin;
commit;
