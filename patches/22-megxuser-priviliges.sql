Begin;

SELECT _v.register_patch( '22-megxuser-priviliges', ARRAY['21-md5-sums-for-genomic-sequences'], NULL );

GRANT ALL ON DATABASE megdb_r8 TO megdb_admin WITH GRANT OPTION;

GRANT USAGE ON SCHEMA auth TO megxuser;

GRANT EXECUTE ON FUNCTION auth.email_check(text) TO megxuser;
GRANT SELECT ON TABLE auth.access_tokens TO megxuser;
GRANT SELECT ON TABLE auth.consumers TO megxuser;
GRANT SELECT ON TABLE auth.has_permissions TO megxuser;
GRANT SELECT ON TABLE auth.has_roles TO megxuser;
GRANT SELECT ON TABLE auth.permissions TO megxuser;
GRANT SELECT ON TABLE auth.roles TO megxuser;
GRANT SELECT ON TABLE auth.user_verification TO megxuser;
GRANT SELECT ON TABLE auth.users TO megxuser;
GRANT SELECT ON TABLE auth.web_resource_permissions TO megxuser;

GRANT SELECT, INSERT, DELETE ON TABLE auth.access_tokens TO megxuser;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE auth.consumers TO megxuser;
GRANT SELECT, INSERT, DELETE ON TABLE auth.has_permissions TO megxuser;
GRANT SELECT, INSERT, DELETE ON TABLE auth.has_roles TO megxuser;
GRANT SELECT, DELETE ON TABLE auth.permissions TO megxuser;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE auth.roles TO megxuser;
GRANT SELECT, INSERT, DELETE ON TABLE auth.user_verification TO megxuser;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE auth.users TO megxuser;
GRANT SELECT, INSERT, DELETE ON TABLE auth.web_resource_permissions TO megxuser;

GRANT USAGE ON SCHEMA elayers TO megxuser;
GRANT EXECUTE ON FUNCTION elayers.wod05_idw_ip(real, real, real, real) TO megxuser;
REVOKE ALL ON FUNCTION elayers.wod05_idw_ip(real, real, real, real) FROM public;


GRANT EXECUTE ON FUNCTION web_r8.habitat_lite_distribution(text) TO megxuser;
GRANT EXECUTE ON FUNCTION web_r8.insert_blast_run(core.blast_run) TO megxuser;
GRANT EXECUTE ON FUNCTION web_r8.insert_genome_report(web_r8.genome_reports) TO megxuser;
GRANT EXECUTE ON FUNCTION web_r8.parse_silva_coldate(text) TO megxuser;
GRANT SELECT ON TABLE web_r8.silva_102_regions_sid_seq TO megxuser;
GRANT SELECT ON TABLE web_r8.silva_102_samples_sid_seq TO megxuser;
GRANT SELECT ON TABLE web_r8.silva_102_regions TO megxuser;
GRANT SELECT ON TABLE web_r8.silva_102_samples TO megxuser;
GRANT SELECT ON TABLE web_r8.silva_samples TO megxuser;
GRANT SELECT ON TABLE web_r8.blast_job_details TO megxuser;
GRANT SELECT ON TABLE web_r8.genome_reports TO megxuser;
GRANT SELECT ON TABLE web_r8.genomes TO megxuser;
GRANT SELECT ON TABLE web_r8.longhurst_regions TO megxuser;
GRANT SELECT ON TABLE web_r8.marine_phages TO megxuser;
GRANT SELECT ON TABLE web_r8.metagenomes TO megxuser;
GRANT SELECT ON TABLE web_r8.silva TO megxuser;
GRANT SELECT ON TABLE web_r8.silva_102_regions_view TO megxuser;
GRANT SELECT ON TABLE web_r8.silva_102_samples_view TO megxuser;
GRANT SELECT ON TABLE web_r8.silva_overview TO megxuser;
GRANT SELECT ON TABLE web_r8.tags TO megxuser;
GRANT SELECT ON TABLE web_r8.tools TO megxuser;
GRANT SELECT ON TABLE web_r8.whale_falls TO megxuser;
GRANT SELECT ON TABLE web_r8.woa05_nitrate TO megxuser;
GRANT SELECT ON TABLE web_r8.woa05_oxygen_dissolved TO megxuser;
GRANT SELECT ON TABLE web_r8.woa05_oxygen_saturation TO megxuser;
GRANT SELECT ON TABLE web_r8.woa05_oxygen_utilization TO megxuser;
GRANT SELECT ON TABLE web_r8.woa05_phosphate TO megxuser;
GRANT SELECT ON TABLE web_r8.woa05_salinity TO megxuser;
GRANT SELECT ON TABLE web_r8.woa05_silicate TO megxuser;
GRANT SELECT ON TABLE web_r8.woa05_temperature TO megxuser;
GRANT SELECT ON TABLE web_r8.world_regions TO megxuser;

GRANT SELECT, UPDATE, INSERT ON TABLE logging.errors TO megxuser;



Rollback;