BEGIN;
SELECT _v.register_patch( '6-drop-sequence-storage-legacy', ARRAY['5-view-fix'], NULL );

DROP TABLE core.dna_seqs;
DROP TABLE core.mg_dnas_old;
DROP TABLE core.mg_pooled_dnas_old;
DROP TABLE core.clonelib_dnas_old;

COMMIT;