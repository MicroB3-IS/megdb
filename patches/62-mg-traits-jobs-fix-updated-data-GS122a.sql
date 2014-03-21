Begin;

SELECT _v.register_patch('62-mg-traits-jobs-fix-updated-data-GS122a',
                          array['62-mg-traits-jobs-fix-updated-data'] );

UPDATE mg_traits.mg_traits_jobs SET sample_description = 'GS122a - International waters between Madagascar and South Africa', sample_name = 'GS122a', sample_environment = 'Open Ocean', sample_latitude = '-30.898333', sample_longitude = '40.420277', sample_label = 'JCVI_SMPL_GS122a' WHERE sample_label = 'JCVI_SMPL_GS122';

commit;
