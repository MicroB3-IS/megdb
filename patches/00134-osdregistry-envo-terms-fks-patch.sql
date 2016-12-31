
BEGIN;
SELECT _v.register_patch('00134-osdregistry-envo-terms-fks',
                          array['00133-add-envo-term-id-constraint'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;

ALTER TABLE osdregistry.samples
      ADD CONSTRAINT envo_biome_terms_fk FOREIGN KEY (biome)
          REFERENCES envo.terms (term) ON UPDATE CASCADE ON DELETE NO ACTION
	  NOT VALID,
      ADD CONSTRAINT envo_feature_terms_fk FOREIGN KEY (feature)
          REFERENCES envo.terms (term) ON UPDATE CASCADE ON DELETE NO ACTION
	  NOT VALID,
      ADD CONSTRAINT envo_material_terms_fk FOREIGN KEY (material)
          REFERENCES envo.terms (term) ON UPDATE CASCADE ON DELETE NO ACTION
	  NOT VALID
;

ALTER TABLE osdregistry.samples
      ALTER COLUMN biome SET DEFAULT 'biome'::text,
      ALTER COLUMN feature SET DEFAULT 'environmental feature'::text,	
      ALTER COLUMN material SET DEFAULT 'environmental material'::text
;

commit;


