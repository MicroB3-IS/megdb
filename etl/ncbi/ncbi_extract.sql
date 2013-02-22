DROP SCHEMA IF EXISTS ncbi CASCADE;
CREATE SCHEMA ncbi;

\set search_path = ncbi, public;

CREATE TABLE ncbi.genome_info (
  organism_name text,
  bio_project_accession text,
  bio_project_id text,
  main_group text,
  sub_group text,
  size_mb numeric,
  gc_content numeric,
  chromosome_accessions_refseq text,
  chromosome_accessions_insdc text,
  plasmid_accessions_refseq text,
  plasmid_accessions_insdc text,
  wgs text,
  scaffolds int,
  genes int,
  proteins int,
  release_date date,
  modify_date date,
  status text,
  sequencing_centre text
);

CREATE TABLE ncbi.genome_fasta (
  header text,
  sequence text
);
 