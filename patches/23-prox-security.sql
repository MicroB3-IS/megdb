begin;

SELECT _v.register_patch( '23-prox-security', ARRAY['8-authdb'], NULL );

insert into auth.roles(label, description)
	values
		('prox_user', 'Group for prox users');

insert into auth.has_roles (role, user_login)
	values
		('prox_user', 'megx');
		
insert into auth.web_resource_permissions(
            url_path, http_method, role)
    values 
    	('/prox/browse*', 'all', 'prox_user');

commit;