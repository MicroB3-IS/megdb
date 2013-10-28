BEGIN;
INSERT INTO core.studies values ('ncbi-bacterial-genomes','NCBI','ftp://ftp.ncbi.nih.gov/genomes/Bacteria/','All bacterial genomes from NCBI');
INSERT INTO core.samples (sid, date_taken, label, old_geom, study, geom, attr)
  SELECT (max(sid) + 1), now()::timestamptz, 'ncbi-bacterial-genomes', NULL, 'ncbi-bacterial-genomes', NULL, NULL
  FROM core.samples as a;
COMMIT;
BEGIN;

INSERT INTO core.isolates (strain, num_chromosomes, num_plasmids, study, sample_name, attr)
  SELECT b.organism_name::text as strain,
         COALESCE(array_length(chr_acc_ref, 1),0) as num_chromosomes,
         COALESCE(array_length(plm_acc_ref, 1),0) as num_plasmids,
         'ncbi-bacterial-genomes' as study,
         'ncbi-bacterial-genomes' as sample_name,
         NULL::hstore as attr
  FROM
  (
    SELECT DISTINCT lower(organism_name) as lab FROM ncbi.sequences_unformatted_mat
    EXCEPT
    SELECT lower(label) as lab FROM core.isolates
  ) AS a
  INNER JOIN
  (
    SELECT organism_name,
           (SELECT ARRAY(SELECT DISTINCT unnest(('{' || string_agg(chromosome_accessions_refseq,',') || '}')::text[]))) as chr_acc_ref,
           (SELECT ARRAY(SELECT DISTINCT unnest(('{' || string_agg(plasmid_accessions_refseq,',') || '}')::text[])))  as plm_acc_ref
    FROM ncbi.sequences_unformatted_mat
    GROUP BY organism_name
  ) AS b
  ON a.lab = lower(b.organism_name)
;

UPDATE core.isolates SET sid = samples.sid FROM core.samples WHERE isolates.sample_name = samples.label;

INSERT INTO core.genome_studies (label, isolate_name, gpid)
  SELECT DISTINCT ON (trim(b.organism_name))
         'ncbi-bacterial-genomes' as label, 
         trim(b.organism_name) as isolate_name,
         0 AS gpid
  FROM
  (
    SELECT DISTINCT lower(trim(organism_name)) AS lowkey FROM ncbi.sequences_unformatted_mat
    EXCEPT
    SELECT DISTINCT lower(isolate_name) AS lowkey FROM core.genome_studies WHERE label = 'ncbi-bacterial-genomes'
  ) AS a
  INNER JOIN
  (
    SELECT organism_name FROM ncbi.sequences_unformatted_mat
  ) AS b
  ON a.lowkey = lower(trim(b.organism_name))
;

INSERT INTO core.genomic_sequences (dna, size, gc, data_source, retrieved, did, did_auth, acc_ver, center, genome_material, study, isolate_name, md5_sum, assembly_status, isolate_id)
  SELECT sequence::dna_sequence AS dna,
         char_length(sequence) AS size,
         gc_content::numeric AS gc,
         'ncbi' AS data_source,
         release_date::timestamp AS retrieved,
         substr(refseq_accession, 1, 9) AS did,
         'ref' AS did_auth,
         substr(refseq_accession, 11, 1) AS acc_ver,
         sequencing_centre AS center,
         CASE 
         WHEN ('{' || refseq_accession || '}')::text[] <@ ('{' || chromosome_accessions_refseq || '}')::text[]
         THEN 'chromosome'
         ELSE 'plasmid'
         END AS genome_material,
         'ncbi-bacterial-genomes',
         trim(organism_name) AS isolate_name,
         md5sum,
         ''::text AS assembly_status,
         0
  FROM ncbi.sequences_unformatted_mat
;

UPDATE core.genomic_sequences SET isolate_id = isolates.id FROM core.isolates WHERE 
  isolate_name = isolates.label;
COMMIT;
