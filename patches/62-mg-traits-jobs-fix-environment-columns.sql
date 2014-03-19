Begin;

SELECT _v.register_patch('62-mg-traits-jobs-fix-environment-columns',
                          array['62-mg-traits-jobs-fix-updated-data'] );

ALTER TABLE mg_traits.mg_traits_jobs RENAME COLUMN sample_environment TO sample_env_ontology;
ALTER TABLE mg_traits.mg_traits_jobs RENAME COLUMN sample_site_description TO sample_environment;

commit;
