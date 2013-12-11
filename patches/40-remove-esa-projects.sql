begin;

SELECT _v.register_patch( '40-remove-esa-projects.sql', ARRAY['14-esa-demo'], NULL );

DELETE FROM esa.gen_config
WHERE category='projects' AND name='biovel';

commit;
