Begin;

SELECT _v.register_patch('62-mg-traits-update-data',
                          array['62-mg-traits-jobs-extra-columns'] );

--Remove .fasta from sample names
UPDATE mg_traits.mg_traits_jobs SET sample_label = rtrim(sample_label, '.fasta');
UPDATE mg_traits.mg_traits_aa SET sample_label = rtrim(sample_label, '.fasta');
UPDATE mg_traits.mg_traits_codon SET sample_label = rtrim(sample_label, '.fasta');
UPDATE mg_traits.mg_traits_dinuc SET sample_label = rtrim(sample_label, '.fasta');
UPDATE mg_traits.mg_traits_functional SET sample_label = rtrim(sample_label, '.fasta');
UPDATE mg_traits.mg_traits_results SET sample_label = rtrim(sample_label, '.fasta');
UPDATE mg_traits.mg_traits_taxonomy SET sample_label = rtrim(sample_label, '.fasta');

commit;
