
BEGIN;

DO $$
BEGIN

  --INSERT INTO  mg_traits.mg_traits_jobs VALUES ('anonymous', 'http://www.megx.net','test-sample', 'marine');

  PERFORM 1 FROM mg_traits.mg_traits_jobs;
  IF found THEN
     RAISE EXCEPTION 'Cannot delete table mg_traits_jobs. Entries and data already exist';
  END IF;

END
$$;


SELECT _v.unregister_patch('31-mg-traits');

SELECT pgq.drop_queue('clusterjobq');

DROP SCHEMA mg_traits CASCADE;


ROLLBACK;
