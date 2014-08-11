BEGIN;
SELECT _v.register_patch('83-new-pubmap-schema.sql');

CREATE TABLE auth.contact
(
  id serial NOT NULL,
  created timestamp with time zone,
  email text NOT NULL DEFAULT ''::text,
  name text NOT NULL DEFAULT ''::text,
  comment text NOT NULL DEFAULT ''::text,
  CONSTRAINT contact_pkey PRIMARY KEY (id)
);

ALTER TABLE auth.contact
  OWNER TO postgres;
  
commit;