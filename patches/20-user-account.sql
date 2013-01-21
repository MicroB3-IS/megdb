begin;

set search_path = auth, pg_catalog;
set default_tablespace = '';
set default_with_oids = false;

SELECT _v.register_patch( '18-user-account', ARRAY['12-security-patch'], NULL );

alter table auth.users add column external_id text;

insert into auth.web_resource_permissions(
            url_path, http_method, role)
    values 
        ('/settings/*', 'all', 'user'),
        ('/settings/*', 'all', 'admin'),
        ('/settings/*', 'all', 'cmsAdmin');

commit;