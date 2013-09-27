begin; 

SELECT _v.register_patch( '30-esa-config-citizen-scientist', ARRAY['14-esa-demo', '25-esa-additional-settings-fields', '29-esa-citizenapp-fields'], NULL );

ALTER TABLE esa.gen_config
   ADD COLUMN available_in_citizen boolean DEFAULT true;
   
ALTER TABLE esa.gen_config
   ADD COLUMN available_in_scientist boolean DEFAULT true;
   
UPDATE esa.gen_config
   SET available_in_citizen=false
WHERE category like 'biomeList';

insert into esa.gen_config
	(category, name, value, available_in_citizen, available_in_scientist)
values
	('biomeList', 'Coastal sea area', 'Coastal sea area', true, true),
	('biomeList', 'Estuary', 'Estuary', true, true),
	('biomeList', 'Inland sea', 'Inland sea', true, true),
	('biomeList', 'Intertidal area', 'Intertidal area', true, true),
	('biomeList', 'Lake', 'Lake', true, true),
	('biomeList', 'Open sea', 'Open sea', true, true),
	('biomeList', 'River', 'River', true, true);

commit;