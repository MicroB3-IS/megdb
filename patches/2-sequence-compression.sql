BEGIN;
SELECT _v.register_patch( '2-sequence-compression', ARRAY['1-partitioning','pgmegx'], NULL );

CREATE OR REPLACE FUNCTION compression_migration(tablename text) returns int as $$
  BEGIN
    EXECUTE 'ALTER TABLE ' || tablename ||
      ' ADD COLUMN compressed_dna dna_sequence; ';
    EXECUTE 'UPDATE ' || tablename ||
      ' SET compressed_dna = CAST(dna AS dna_sequence); ';
    EXECUTE 'ALTER TABLE ' || tablename ||
      ' DROP COLUMN dna; ';
    EXECUTE 'ALTER TABLE ' || tablename ||
      ' RENAME COLUMN compressed_dna TO dna; ';
    return next_id;
  END;
$$ LANGUAGE plpgsql;

SELECT compression_migration('core.genomic_sequences');
SELECT compression_migration('partitions.sample_' || CAST(partition_id AS TEXT)) FROM metagenomic_partitions WHERE active = TRUE;
SELECT compression_migration('partitions.clonelib_' || CAST(partition_id AS TEXT)) FROM clonelib_partitions WHERE active = TRUE;
SELECT compression_migration('partitions.pool_' || CAST(partition_id AS TEXT)) FROM pooled_metagenomic_partitions WHERE active = TRUE;

DROP FUNCTION compression_migration(tablename text);

COMMIT;