begin;

set search_path = auth, pg_catalog;
set default_tablespace = '';
set default_with_oids = false;

SELECT _v.register_patch( '17-cmsadmin-patch', ARRAY['12-security-patch'], NULL );

insert into has_roles(role, user_login)
	values('cmsAdmin','megx');

commit;