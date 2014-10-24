
BEGIN;

SELECT _v.unregister_patch( '00091-mibig-megxuser-privs');

REVOKE select, insert ON TABLE mibig.submissions FROM megxuser;

commit;
