Begin;

SELECT _v.register_patch('59-logging-perms',
                          array[ '15-logging', '22-megxuser-priviliges'] );

SET search_path TO mg_traits;

ALTER TABLE logging.errors OWNER TO megdb_admin;

REVOKE ALL ON TABLE logging.errors FROM mschneid;

GRANT USAGE ON SCHEMA logging TO megxuser;

commit;
