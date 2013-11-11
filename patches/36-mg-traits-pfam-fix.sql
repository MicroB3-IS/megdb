
BEGIN;

SELECT _v.register_patch('36-mg-traits-pfam-fix', 
                          array['8-authdb','31-mg-traits', '34-new-mg-traits' ] );

ALTER TABLE mg_traits.mg_traits_pfam
  ALTER COLUMN pfam TYPE text[][];

COMMIT;    