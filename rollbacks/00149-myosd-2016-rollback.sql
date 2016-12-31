
BEGIN;

SELECT _v.unregister_patch( '00149-myosd-2016');


drop table myosd.registrations;

DROP schema myosd;


rollback;
