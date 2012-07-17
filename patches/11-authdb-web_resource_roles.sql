begin;

SELECT _v.register_patch( '11-authdb-web_resource_roles', ARRAY['10-improve-samples-studies'], NULL );


update auth.users
	set pass=md5('megx')
		where logname='megx';
		
delete from auth.web_resource_permissions;

insert into auth.web_resource_permissions(
            url_path, http_method, role)
    values 
    	('/apps*', 'all', 'user'),
    	('/apps*', 'all', 'admin'), -- the apps manager
    	('/admin/*', 'all', 'admin'), -- the admin part
    	('/ws/apps*', 'all', 'user'),
    	('/ws/apps*', 'all', 'admin'), -- the apps REST services 
		('/oauth/authorize*','all','admin'),
		('/oauth/authorize*','all','user'), -- Authorization endpoint must be available only for logged in users
		('/security/*','all','admin'), -- Must be admin to access security management interface
		('/ws/filter/*','all', 'admin'); -- must be admin to use the Users/Roles/WebResources admin REST services

commit;