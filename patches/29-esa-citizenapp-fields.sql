begin; 

SELECT _v.register_patch( '29-esa-citizenapp-fields', ARRAY['14-esa-demo'], NULL );

alter table esa.samples
ADD COLUMN phosphate numeric;

alter table esa.samples
ADD COLUMN nitrate numeric;

alter table esa.samples
ADD COLUMN nitrite numeric;

alter table esa.samples
ADD COLUMN ph numeric;

commit;