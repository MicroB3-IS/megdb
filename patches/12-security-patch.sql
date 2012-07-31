begin;

set search_path = auth, pg_catalog;
set default_tablespace = '';
set default_with_oids = false;

SELECT _v.register_patch( '12-security-patch', ARRAY['11-authdb-web_resource_roles'], NULL );

alter table auth.users
	add column external boolean not null default false;

alter table auth.users
	add column provider text;

update auth.users
	set pass='1000:cdf0a18e4bda6f05ed330dee07eecc722f2ddc834333c1fa:711e29e109faa48e4cb715c4c8f286d9f35b85e2585d3aeb'
		where logname='megx';

-- add chon roles...
insert into auth.roles (label, description)
	values('cmsAdmin','CMS Administrator');

	

	
-- user verification
drop table if exists user_verification;
create table user_verification(
	verification_value text not null,
	logname text not null,
	verification_type text not null,
	created timestamp with time zone not null default now(),
	constraint pk_user_verification primary key (verification_value),
	constraint fk_user_verification_users foreign key (logname)
						references users (logname) on update cascade
													on delete cascade
);
	
commit;