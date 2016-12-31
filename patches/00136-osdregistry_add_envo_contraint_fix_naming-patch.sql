
BEGIN;
SELECT _v.register_patch('00136-osdregistry_add_envo_contraint_fix_naming',
                          array['00135-osdregistry_jambooree_envo_update_table'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

UPDATE osdregistry.jam_corrections_2014
   SET envo_feature = 'surface water' where envo_feature = 'surface water layer'
;

UPDATE osdregistry.jam_corrections_2014
   SET envo_feature = 'bay' where envo_feature = 'sea loch';


UPDATE osdregistry.jam_corrections_2014
   SET envo_feature = 'bay' where envo_feature = 'sea loch';

UPDATE osdregistry.jam_corrections_2014
   SET envo_feature = 'coastal water body' where envo_feature = 'coastal water';

UPDATE osdregistry.jam_corrections_2014
   SET envo_feature = 'surface water'
 WHERE envo_feature = '; mixed surface layer';

UPDATE osdregistry.jam_corrections_2014
   SET envo_feature = 'brackish estuary'
 WHERE envo_feature = 'brackish water habitat';

-- now material
UPDATE osdregistry.jam_corrections_2014
   SET envo_material = 'coastal sea water'
 WHERE envo_material = 'coastal water';

UPDATE osdregistry.jam_corrections_2014
   SET envo_material = 'sea water'
 WHERE envo_material = 'ocean water';

UPDATE osdregistry.jam_corrections_2014
   SET envo_material = 'sea water'
 WHERE envo_material = 'seawater';




ALTER TABLE osdregistry.jam_corrections_2014
      ADD CONSTRAINT envo_feature_terms_fk FOREIGN KEY (envo_feature)
          REFERENCES envo.terms (term) ON UPDATE CASCADE ON DELETE NO ACTION,
      ADD CONSTRAINT envo_material_terms_fk FOREIGN KEY (envo_material)
          REFERENCES envo.terms (term) ON UPDATE CASCADE ON DELETE NO ACTION
;


commit;


