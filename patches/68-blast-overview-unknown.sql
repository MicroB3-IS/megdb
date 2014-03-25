
BEGIN;
SELECT _v.register_patch('68-blast-overview-unknown',
                          array['67-fix-sample-label-traits'] );


SET search_path TO megx_blast, public;

CREATE VIEW unknown_overview AS 
  SELECT 
    id as job_id,
    label,
    query_id,
    biodb_label,
    biodb_version,
    time_submitted,
    program_name,
    hit,
    db,
    hit_id,
    hit_def,
    hit_acc,
    hit_length,
    hsp_num,
    hsp_length,
    hsp_evalue,
    hsp_bit_score,
    hsp_q_from,
    hsp_q_to,
    hsp_h_from,
    hsp_h_to,
    hsp_q_frame,
    hsp_h_frame,
    hsp_identical,
    hsp_conserved,
    hsp_q_string,
    hsp_h_string,
    hsp_homology_string,
    subnet_graphml,
    subnet_json,
    hit_neighborhood,
    array_length( akeys(hit_neighborhood), 1) as hit_neighborhood_count,
    kegg_url_args,
    hit_bits,
    hit_significance,
    hit_hsp_num
  FROM 
    blast_jobs as j 
  LEFT JOIN
    blast_hits as h
  ON (j.id = h.jid ) 
  WHERE 
    return_code = 0;

commit;
