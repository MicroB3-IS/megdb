
BEGIN;
SELECT _v.register_patch('00097-mg-traits-test-friendly-cnstrnt',
                          array['00096-mg-traits-sge-user-perm'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

DROP INDEX mg_traits.sample_label_per_customer_key;

CREATE UNIQUE INDEX sample_label_per_customer_key
  ON mg_traits.mg_traits_jobs
  USING btree
  (customer, sample_label)
  WHERE return_code = 0 AND sample_label != 'test_label';


-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


