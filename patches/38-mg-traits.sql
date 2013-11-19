BEGIN;

SELECT _v.register_patch('38-mg-traits', 
                          array['8-authdb','31-mg-traits', '35-mg-traits-results-status' ] );

ALTER TABLE mg_traits.mg_traits_jobs
  ADD COLUMN return_code INT,
  ADD COLUMN error_message TEXT;

ALTER TABLE mg_traits.mg_traits_results
  DROP COLUMN return_code,
  DROP COLUMN error_message;

ALTER TABLE mg_traits.mg_traits_jobs
  ALTER COLUMN time_finished DROP NOT NULL,
  ALTER COLUMN time_finished DROP DEFAULT;

ALTER TABLE mg_traits.mg_traits_pfam
  DROP COLUMN pfam;

ALTER TABLE mg_traits.mg_traits_pfam
  ADD COLUMN pfam INT[] NOT NULL;

COMMIT;                          