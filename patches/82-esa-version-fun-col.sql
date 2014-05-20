
BEGIN;
SELECT _v.register_patch('82-esa-version-fun-col',
                          array['80-esa-samples-nan-defaults.sql', '81-esa-permissions'] );


ALTER TABLE esa.samples
   ADD COLUMN app_version text DEFAULT '' NOT NULL,
   ADD COLUMN fun boolean DEFAULT true NOT NULL;



commit;
