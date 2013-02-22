\set search_path = ncbi, public;

ALTER TABLE ncbi.genome_fasta ADD COLUMN md5sum text;
UPDATE ncbi.genome_fasta SET md5sum = md5(sequence);
ALTER TABLE ncbi.genome_fasta ADD COLUMN refseq_accession text;
UPDATE ncbi.genome_fasta SET refseq_accession = substr(array_to_string(regexp_matches(header, 'ref\|[^|]+?\|'),''), 5,11);

CREATE OR REPLACE VIEW ncbi.sequences_unformatted AS
  SELECT *
  FROM
  (SELECT substr(refseq_accession, 1, 9) AS did FROM ncbi.genome_fasta EXCEPT SELECT did from core.genomic_sequences) AS a
  INNER JOIN
  ncbi.genome_fasta ON a.did = substr(ncbi.genome_fasta.refseq_accession, 1, 9)
  INNER JOIN
  ncbi.genome_info ON ('{' || chromosome_accessions_refseq || '}')::text[] @> ('{' || ncbi.genome_fasta.refseq_accession || '}')::text[]
                   OR ('{' || plasmid_accessions_refseq || '}')::text[] @> ('{' || ncbi.genome_fasta.refseq_accession || '}')::text[]
;

CREATE TABLE ncbi.sequences_unformatted_mat (like ncbi.sequences_unformatted);
INSERT INTO ncbi.sequences_unformatted_mat SELECT * FROM ncbi.sequences_unformatted;



