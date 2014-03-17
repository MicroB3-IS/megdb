Begin;

SELECT _v.register_patch('61-megx-blast-fix-hit-scores',
                          array['61-megx-blast-fix-query-id'] );

ALTER TABLE megx_blast.blast_hits ADD COLUMN hit_bits numeric;
ALTER TABLE megx_blast.blast_hits ADD COLUMN hit_significance numeric;
ALTER TABLE megx_blast.blast_hits ADD COLUMN hit_hsp_num smallint;

commit;
