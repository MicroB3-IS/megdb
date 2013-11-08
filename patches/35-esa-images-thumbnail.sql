begin;

SELECT _v.register_patch( '35-esa-images-thumbnail', ARRAY['14-esa-demo'], NULL );

ALTER TABLE esa.sample_images ADD COLUMN thumbnail bytea;

commit;