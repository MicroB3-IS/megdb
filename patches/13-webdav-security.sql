begin;

set search_path = auth, pg_catalog;
set default_tablespace = '';
set default_with_oids = false;

SELECT _v.register_patch( '13-webdav-security', ARRAY['12-security-patch'], NULL );

insert into auth.web_resource_permissions(
            url_path, http_method, role)
    values 
        ('/dav*', 'all', 'user'),
        ('/dav*', 'all', 'admin'),
        ('/dav*', 'all', 'cmsAdmin');

commit;