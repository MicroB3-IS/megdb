Begin;

SELECT _v.register_patch('60-mg-traits-pk-pca-table.sql',
                          array[ '58-mg-traits-populate-terms'] );

set search_path to mg_traits;

ALTER TABLE mg_traits.mg_traits_pca DROP CONSTRAINT mg_traits_pca_pkey;
ALTER TABLE mg_traits.mg_traits_pca ADD PRIMARY KEY (id, pca_id, trait);

commit;
