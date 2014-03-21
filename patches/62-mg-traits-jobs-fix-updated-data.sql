Begin;

SELECT _v.register_patch('62-mg-traits-jobs-fix-updated-data',
                          array['62-mg-traits-update-jobs-data'] );
UPDATE mg_traits.mg_traits_jobs SET sample_description = 'GS110a - Indian Ocean', sample_name = 'GS110a', sample_environment = 'Open Ocean', sample_latitude = '-10.446111', sample_longitude = '88.30278', sample_label = 'JCVI_SMPL_GS110a' WHERE sample_label = 'JCVI_SMPL_GS110';
UPDATE mg_traits.mg_traits_jobs SET sample_description = 'GS108a - Coccos Keeling , Inside Lagoon', sample_name = 'GS108a', sample_environment = 'Lagoon Reef', sample_latitude = '-12.0925', sample_longitude = '96.88167', sample_label = 'JCVI_SMPL_GS108a' WHERE sample_label = 'JCVI_SMPL_GS108';
UPDATE mg_traits.mg_traits_jobs SET sample_description = 'GS108b - Coccos Keeling , Inside Lagoon', sample_name = 'GS108b', sample_environment = 'Lagoon Reef', sample_latitude = '-12.0925', sample_longitude = '96.88167', sample_label = 'JCVI_SMPL_GS108b' WHERE sample_label = 'JCVI_SMPL_GS108b_';
UPDATE mg_traits.mg_traits_jobs SET sample_description = 'GS112a - Indian Ocean', sample_name = 'GS112a', sample_environment = 'Open Ocean', sample_latitude = '-8.505', sample_longitude = '80.37556', sample_label = 'JCVI_SMPL_GS112a' WHERE sample_label = 'JCVI_SMPL_GS112';
UPDATE mg_traits.mg_traits_jobs SET sample_description = 'GS117a - St. Anne Island, Seychelles', sample_name = 'GS117a', sample_environment = 'Coastal sample', sample_latitude = '-4.613611', sample_longitude = '55.50861', sample_label = 'JCVI_SMPL_GS117' WHERE sample_label = 'JCVI_SMPL_GS117';
UPDATE mg_traits.mg_traits_jobs SET sample_description = 'GS048b - Inside Cook''s Bay, Moorea, French Polynesia', sample_name = 'GS048b', sample_environment = 'Coral Reef', sample_latitude = '-17.475834', sample_longitude = '-149.81223', sample_label = 'JCVI_SMPL_GS048b' WHERE sample_label = 'JCVI_SMPL_GS048b_';

commit;
