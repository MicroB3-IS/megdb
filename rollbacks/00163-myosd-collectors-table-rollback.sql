
BEGIN;

SELECT _v.unregister_patch( '00163-myosd-collectors-table');

drop table myosd.collectors;

commit;
