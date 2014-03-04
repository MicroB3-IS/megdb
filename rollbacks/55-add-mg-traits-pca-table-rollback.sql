
BEGIN;

SELECT _v.unregister_patch( '55-add-mg-traits-pca-table');

set search_path to mg_traits;

DROP TABLE IF EXISTS mg_traits_pca;
DROP TABLE IF EXISTS traits_cv;



COMMIT;
