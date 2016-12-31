
BEGIN;
SELECT _v.register_patch('00133-add-envo-term-id-constraint',
                          array['00132-add-envo-schema'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

-- for some test queries as user megxuser
-- SET ROLE megxuser;
ALTER TABLE envo.terms
   ALTER COLUMN id TYPE text;

ALTER TABLE envo.terms
  ADD CONSTRAINT terms_id_check CHECK (id ~ '^[0-9]{7,8}$'::text);
  
ALTER TABLE envo.terms
   ALTER COLUMN term SET NOT NULL;
   
commit;
