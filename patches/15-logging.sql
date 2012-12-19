begin;

SELECT _v.register_patch( '15-logging', '{}', NULL );

drop schema if exists logging cascade;
create schema logging;

alter schema logging OWNER to megdb_admin;
set search_path = logging, public, pg_catalog;
set default_tablespace = '';
set default_with_oids = false;

drop  table if exists errors;
create table errors(
	id text not null primary key, -- nonce
	http_code integer not null default 500,
	"time" timestamp with time zone,
	message text,
	request_uri text,
	stack_trace text,
	java_type text,
	"user" text, -- user id
	remote_ip text,
	feedback text
);



commit;