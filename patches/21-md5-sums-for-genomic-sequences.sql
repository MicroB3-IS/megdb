BEGIN;

SELECT _v.register_patch( '21-md5-sums-for-genomic-sequences', ARRAY['19-ribosomal-sequence-table'], NULL );

alter table core.genomic_sequences add column md5_sum text;
update core.genomic_sequences set md5_sum = md5(dna);

COMMIT;  
