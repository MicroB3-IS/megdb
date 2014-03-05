Begin;

SELECT _v.register_patch('57-add-sge-select-perm',
                          array[ '56-enhanced-pca-table'] );

set search_path to mg_traits;



REVOKE ALL ON TABLE mg_traits.mg_traits_aa FROM sge;
GRANT SELECT, INSERT ON TABLE mg_traits.mg_traits_aa TO sge;

REVOKE ALL ON TABLE mg_traits.mg_traits_codon FROM sge;
GRANT SELECT, INSERT ON TABLE mg_traits.mg_traits_codon TO sge;

REVOKE ALL ON TABLE mg_traits.mg_traits_dinuc FROM sge;
GRANT SELECT, INSERT ON TABLE mg_traits.mg_traits_dinuc TO sge;

REVOKE ALL ON TABLE mg_traits.mg_traits_functional FROM sge;
GRANT SELECT, INSERT ON TABLE mg_traits.mg_traits_functional TO sge;

REVOKE ALL ON TABLE mg_traits.mg_traits_taxonomy FROM sge;
GRANT SELECT, INSERT ON TABLE mg_traits.mg_traits_taxonomy TO sge;


commit;
