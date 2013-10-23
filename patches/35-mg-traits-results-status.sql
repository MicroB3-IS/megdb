
BEGIN;

SELECT _v.register_patch('35-mg-traits-results-status', 
                          array['8-authdb','31-mg-traits', '34-new-mg-traits' ] );

ALTER TABLE mg_traits.mg_traits_results
  ADD COLUMN return_code INT NOT NULL DEFAULT 0,
  ADD COLUMN error_message TEXT;

COMMIT;                          