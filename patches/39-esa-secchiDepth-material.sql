begin;

SELECT _v.register_patch( '39-esa-secchiDepth-material.sql', ARRAY['14-esa-demo'], NULL );

ALTER TABLE esa.samples ADD COLUMN secchi_depth numeric;
ALTER TABLE esa.samples ADD COLUMN material text;

commit;