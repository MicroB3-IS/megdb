
BEGIN;

SELECT _v.unregister_patch( '00162-myosd-filters-table');

drop table myosd.filters;


commit;
