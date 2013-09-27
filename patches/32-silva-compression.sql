BEGIN;

SELECT _v.register_patch( '32-silva-compression', ARRAY['28-compress-sequence-data', '19-ribosomal-sequence-table'], NULL );

ALTER TABLE core.ribosomal_sequences ADD COLUMN compressed_sequence dna_sequence NOT NULL DEFAULT ''::dna_sequence;

UPDATE core.ribosomal_sequences SET compressed_sequence = sequence::dna_sequence;

CREATE FUNCTION check_ribosomal_sequences() RETURNS INT AS $$
DECLARE
  rows RECORD;
BEGIN
  FOR rows IN SELECT did, did_auth FROM core.ribosomal_sequences WHERE sequence != compressed_sequence::text LOOP
    RAISE EXCEPTION 'Sequence mismatch for sequence %', rows.did;
  END LOOP;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

SELECT check_ribosomal_sequences();

DROP FUNCTION check_ribosomal_sequences();

ALTER TABLE core.ribosomal_sequences DROP COLUMN sequence;
ALTER TABLE core.ribosomal_sequences RENAME COLUMN compressed_sequence TO sequence;

COMMIT;