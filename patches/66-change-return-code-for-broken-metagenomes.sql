Begin;

SELECT _v.register_patch('66-change-return-code-for-broken-metagenomes',
                          array['65-mg_traits-robust-pgq-trigger'] );

set search_path to mg_traits;

UPDATE mg_traits.mg_traits_jobs SET return_code = '10' WHERE sample_label = 'JCVI_SMPL_1103283000050';
UPDATE mg_traits.mg_traits_jobs SET return_code = '10' WHERE sample_label = 'JCVI_SMPL_1103283000045';
UPDATE mg_traits.mg_traits_jobs SET return_code = '10' WHERE sample_label = 'JCVI_SMPL_1103283000055';
UPDATE mg_traits.mg_traits_jobs SET return_code = '10' WHERE sample_label = 'JCVI_SMPL_1103283000044';
commit;
