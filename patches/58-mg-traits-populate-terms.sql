Begin;

SELECT _v.register_patch('58-mg-traits-populate-terms',
                          array[ '57-add-sge-select-perm'] );

set search_path to mg_traits;

insert into mg_traits.traits_cv (term) VALUES 
('amino-acid-content'),
('codon-usage'),
('di-nucleotide-odds-ratio'),
('functional-table'),
('taxonomic-table');

commit;
