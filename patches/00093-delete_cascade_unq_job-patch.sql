
BEGIN;
SELECT _v.register_patch('00093-delete_cascade_unq_job',
                          array['00092-mg-trait-pk-fixes'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

-- first creating new index which allows several succesfull test run via test_label
DROP INDEX mg_traits.successful_jobs_key;

CREATE UNIQUE INDEX successful_jobs_key
  ON mg_traits.mg_traits_jobs
  USING btree
  (mg_url)
  WHERE return_code = 0 AND sample_label != 'test_label';


-- now introducing cascading deletes: 
-- rule if job gets deleted then also all associated results

ALTER TABLE mg_traits.mg_traits_pca DROP CONSTRAINT mg_traits_pca_id_fkey;
ALTER TABLE mg_traits.mg_traits_pca 
  ADD FOREIGN KEY (pca_id) 
       REFERENCES mg_traits.mg_traits_jobs (id) 
   ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE mg_traits.mg_traits_aa DROP CONSTRAINT jobs_fk;
ALTER TABLE mg_traits.mg_traits_aa 
  ADD CONSTRAINT jobs_fkey FOREIGN KEY (id) 
       REFERENCES mg_traits.mg_traits_jobs (id) 
   ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE mg_traits.mg_traits_codon DROP CONSTRAINT jobs_fk;
ALTER TABLE mg_traits.mg_traits_codon 
  ADD CONSTRAINT jobs_fkey FOREIGN KEY (id) 
       REFERENCES mg_traits.mg_traits_jobs (id) 
   ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE mg_traits.mg_traits_dinuc DROP CONSTRAINT jobs_fk;
ALTER TABLE mg_traits.mg_traits_dinuc
  ADD CONSTRAINT jobs_fkey FOREIGN KEY (id) 
       REFERENCES mg_traits.mg_traits_jobs (id) 
   ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE mg_traits.mg_traits_functional DROP CONSTRAINT jobs_fk;
ALTER TABLE mg_traits.mg_traits_functional
  ADD CONSTRAINT jobs_fkey FOREIGN KEY (id) 
       REFERENCES mg_traits.mg_traits_jobs (id) 
   ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE mg_traits.mg_traits_results DROP CONSTRAINT jobs_fk;
ALTER TABLE mg_traits.mg_traits_results
  ADD CONSTRAINT jobs_fkey FOREIGN KEY (id) 
       REFERENCES mg_traits.mg_traits_jobs (id) 
   ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE mg_traits.mg_traits_taxonomy DROP CONSTRAINT jobs_fk;
ALTER TABLE mg_traits.mg_traits_taxonomy
  ADD CONSTRAINT jobs_fkey FOREIGN KEY (id) 
       REFERENCES mg_traits.mg_traits_jobs (id) 
   ON UPDATE NO ACTION ON DELETE CASCADE;

-- for some test queries as user megxuser
-- SET ROLE megxuser


commit;


