--set statement_timeout = 0;
--set client_encoding = 'UTF8';
--set standard_conforming_strings = off;
--set check_function_bodies = false;
--set client_min_messages = warning;
--set escape_string_warning = off;
begin;

drop schema if exists auth cascade; 
create schema auth;

alter schema auth OWNER to postgres;
set search_path = auth, pg_catalog;
set default_tablespace = '';
set default_with_oids = false;

drop table if exists users;
create table users(
    logname text not null,
    first_name text,
    initials text,
    last_name text,
    description text,
    join_date timestamp with time zone not null,
    pass text,
    diabled boolean not null,
    email text not null,
    constraint pk_users primary key (logname)
);

drop table if exists roles;
create table roles(
    label text not null,
    description text,
    constraint pk_roles primary key (label)
);

drop table if exists consumers;
create table consumers(
    key text not null,
    secret text not null,
    name text not null,
    description text,
    oob boolean not null default false,
    trusted boolean not null default false,
    expiration timestamp with time zone not null,
    logname text not null,
    callback_url text,
    constraint pk_consumers primary key (key),
    constraint fk_consumers_users foreign key (logname)
            references users(logname) on update cascade
                                      on delete cascade
);

drop table if exists access_tokens;
create table access_tokens(
    token text not null,
    secret text not null,
    verifier text,
    callback_url text,
    consumer_key text not null,
    user_log text not null,
    token_created timestamp with time zone,
    constraint pk_access_tokens primary key (token),
    constraint fk_access_tokens_consumers foreign key (consumer_key)
                                references consumers(key) on update cascade
                                                          on delete cascade,
    constraint fk_access_tokens_users foreign key (user_log) 
                                references users(logname) on update cascade
                                                            on delete cascade
                    
);


drop table if exists permissions;
create table permissions(
    label text not null,
    description text,
    constraint pk_permissions primary key (label)
);

drop table if exists web_resource_permissions;
create table web_resource_permissions(
    url_path text not null,
    http_method text not null,
    role text not null,
    constraint pk_web_resource_permissions 
            primary key (url_path, http_method, role),
    constraint fk_web_resource_permissions_roles
        foreign key (role) references roles(label) on update cascade
                                                   on delete cascade
);


-- ref permissions M---M roles
drop table if exists  has_permissions;
create table has_permissions(
    role text not null,
    permission text not null,
    constraint pk_has_permissions primary key (role, permission),
    constraint fk_has_permissions_permissions 
            foreign key (permission) references permissions(label)
                    on update cascade
                    on delete cascade,
                    
    constraint fk_has_permissions_roles foreign key (role)
        references roles(label) on update cascade
                                on delete cascade
);

-- ref users M---M roles
drop table if exists has_roles;
create table has_roles(
    role text not null,
    user_login text not null,
    constraint pk_has_roles primary key (role, user_login),
    constraint fk_has_roles_roles foreign key(role) 
                references roles (label) on update cascade
                                         on delete cascade,
    constraint fk_has_roles_users foreign key (user_login)
                references users (logname) on update cascade
                                           on delete cascade
);


-- data dump 

-- users table

insert into auth.users(
            logname, first_name, initials, last_name, description, join_date, 
            pass, diabled)
    values ('megx', 'Megx.net', 'MN', '', 'No description', now(), 'megx', false);

-- consumers
insert into auth.consumers(
            key, secret, name, description, oob, trusted, expiration, logname, 
            callback_url)
    values ('NzA1NDZhMTktZmMwOC00NmI2LTg0ZTUtNDg4ZWRmODE0ZjYx',
    		'NIaWgKMJOkAYm6vdFpgGHpPOfF4mXFmvqL-pb698hsiD3y-bZ5FyGGMD7z0pqFk0w7Ol2qD7n-GdJ-HeW3Srqg',
    		'MegxBar', 'MegxBar firefox extension', false, false, now()+interval '3 years', 'megx', null);
    		
-- roles
insert into auth.roles(label, description)
	values('admin','Administrator'),
	      ('user', 'User');

-- permissions
insert into auth.permissions(label, description)
	values('read','Read permisssion'),
			('write', 'Write permission');
			
-- roles <-> users
insert into has_roles(role, user_login)
	values('admin','megx');
	
	
-- roles <-> permissions
insert into has_permissions(role, permission)
	values ('admin', 'read'),
			('admin', 'write'),
			('user', 'read');

			
-- web resources

insert into auth.web_resource_permissions(
            url_path, http_method, role)
    values ('/security/*', 'all', 'admin'), -- the security management
    	('/apps*', 'all', 'user'),
    	('/apps*', 'all', 'admin'); -- the apps manager

commit;