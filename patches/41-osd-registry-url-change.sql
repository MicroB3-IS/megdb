begin;

SELECT _v.register_patch( '41-osd-registry-url-change.sql', ARRAY['8-authdb'], NULL );

UPDATE auth.web_resource_permissions
SET url_path='/osd-registry/add*'
WHERE url_path='/osd/add*';

commit;
