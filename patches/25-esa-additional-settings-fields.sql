begin; 

SELECT _v.register_patch( '25-esa-additional-settings-fields', ARRAY['14-esa-demo'], NULL );

alter table esa.samples
add column boat_manufacturer text;

alter table esa.samples
add column boat_model text;

alter table esa.samples
add column boat_length numeric default 0;

alter table esa.samples
add column homeport text;

commit;