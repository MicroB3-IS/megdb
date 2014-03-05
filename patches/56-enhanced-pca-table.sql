Begin;

SELECT _v.register_patch('56-enhanced-pca-table',
                          array[ '55-add-mg-traits-pca-table'] );

set search_path to mg_traits;


-- we need to add a column to say which metagenome triggered the pca calculation

ALTER TABLE mg_traits_pca ADD COLUMN pca_id integer REFERENCES mg_traits_jobs(id);

ALTER TABLE mg_traits.mg_traits_pca DROP CONSTRAINT mg_traits_pca_pkey;

ALTER TABLE mg_traits.mg_traits_pca ADD CONSTRAINT mg_traits_pca_pkey PRIMARY KEY (pca_id,id);


COMMENT ON TABLE mg_traits_pca IS 'Results of a PCA triggered by a new metagenome (pca_id) giving x,y of the PCA per trait per all previous metagenomes (id)';

COMMENT ON COLUMN mg_traits_pca.id IS 'the metagenome for which x and y are calculated';

COMMENT ON COLUMN mg_traits.mg_traits_pca.pca_id IS 'the metagenome which triggered the PCA';

COMMENT ON CONSTRAINT mg_traits_pca_pkey ON mg_traits.mg_traits_pca IS 'For a given metagenome (id) all PCAs (x,y) for all other metagenomes including this one';


commit;
