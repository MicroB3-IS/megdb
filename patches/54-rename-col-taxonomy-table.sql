Begin;

SELECT _v.register_patch('54-rename-col-taxonomy-table',
                          array[ '53-mg-traits-refined-additional-tables'] );


ALTER TABLE mg_traits.mg_traits_taxonomy RENAME taxonomy_group  TO taxonomy_order;

COMMENT ON COLUMN mg_traits.mg_traits_taxonomy.taxonomy_order IS 'Taxonomic assignment down to order level';


commit;
