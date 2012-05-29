-- during partitioning all references to mg_dnas have been rereferenced to mg_dnas_old
-- -> change in view definitions
-- column did_code of mg_dnas is now called did_auth due to inheritance from dna_seqs
-- -> rename in view definitions

BEGIN;
SELECT _v.register_patch( '5-view-fix', ARRAY['1-partitioning'], NULL );

SET search_path TO core, public; 

-- fix core.mg_all_dnas
CREATE OR REPLACE VIEW core.mg_all_dnas AS 
         SELECT mg_dnas.study, mg_dnas.sample_name AS sample_label, mg_dnas.did, mg_dnas.did_auth as did_code
           FROM core.mg_dnas mg_dnas
UNION ALL 
         SELECT mg_pooled_dnas.study, mg_pooled_dnas.pool_label AS sample_label, mg_pooled_dnas.did, mg_pooled_dnas.did_auth as did_code
           FROM core.mg_pooled_dnas mg_pooled_dnas;

SET search_path TO web, public;

-- fix web.blast_gos
CREATE OR REPLACE VIEW web.blast_gos AS 
 SELECT t.sid, t.jid, t.id, t.hit, t.hsp, 'GOS read '::text || t.hit_acc AS descr, t.hit_acc AS acc, t.h_length, t.evalue, t.bit_score, t.q_from, t.q_to, t.h_from, t.h_to, t.q_frame, t.h_frame, t.ident, t.pos, t.a_length, 'GOS read '::text || t.hit_acc AS locdesc, core.pp_geom(s.old_geom) AS latlon, s.old_geom AS geom, s.hab_lite, mgd.sample_name, ( SELECT (sm.vals[1]::text || ' '::text) || sm.unit AS vals
           FROM core.sample_measures sm
          WHERE sm.param = 'depth'::text AND sm.sid = s.sid) AS depth, ( SELECT (sm.vals[1]::text || ' '::text) || sm.unit AS vals
           FROM core.sample_measures sm
          WHERE sm.param = 'temperature'::text AND sm.sid = s.sid) AS temperature
   FROM core.blast_hits t
   JOIN core.mg_dnas mgd ON mgd.did = t.hit_acc
   JOIN core.samples s ON s.label = mgd.sample_name
  WHERE t.db = 'gos'::text;

COMMIT;

--optional fixes
BEGIN;

SET search_path TO analysis, core, public; 

-- fix analysis.network_gos_na_58_pfams 
 CREATE OR REPLACE VIEW analysis.network_gos_na_58_pfams AS 
 SELECT pfam.target_name, pfam.acc, pfam.tlen, pfam.query_name, pfam.query_id, pfam.query_frame, pfam.acc2, pfam.qlen, pfam.fullevalue, pfam.full_score, pfam.full_bias, pfam.domain_num, pfam.domain_of, pfam.domain_evalue, pfam.domain_ievalue, pfam.domain_score, pfam.domain_bias, pfam.hmm_from, pfam.hmm_to, pfam.ali_from, pfam.ali_to, pfam.env_from, pfam.env_to, pfam.acc3, pfam.descr, mg.study, mg.sample_name, mg.did, mg.did_auth as did_code
   FROM core.mg_dnas mg, analysis.gos_pfam24 pfam
  WHERE pfam.fullevalue < 0.001 AND abs(log(pfam.full_score + 1::double precision) - log(pfam.full_bias + 1::double precision)) > 1::double precision AND mg.did::bigint = pfam.query_id;

-- fix analysis.network_gos_na_58_unknowns
  CREATE OR REPLACE VIEW analysis.network_gos_na_58_unknowns AS 
 SELECT pfam.query_name, mg.study, mg.sample_name, mg.did, mg.did_auth as did_code
   FROM core.mg_dnas mg
   LEFT JOIN analysis.gos_pfam24 pfam ON pfam.fullevalue < 0.001 AND abs(log(pfam.full_score + 1::double precision) - log(pfam.full_bias + 1::double precision)) > 1::double precision AND mg.did::bigint = pfam.query_id
  WHERE pfam.query_name IS NULL;

SET search_path TO rkottman, public; 

-- fix rkottman.network_pfam
CREATE OR REPLACE VIEW rkottman.network_pfam AS 
 SELECT pfam.target_name, pfam.acc, pfam.tlen, pfam.query_name, pfam.acc2, pfam.qlen, pfam.fullevalue, pfam.full_score, pfam.full_bias, pfam.domain_num, pfam.domain_of, pfam.domain_evalue, pfam.domain_ievalue, pfam.domain_score, pfam.domain_bias, pfam.hmm_from, pfam.hmm_to, pfam.ali_from, pfam.ali_to, pfam.env_from, pfam.env_to, pfam.acc3, pfam.descr, mg.did
   FROM core.sample_sets s, core.mg_dnas mg, analysis.gos_pfam24 pfam
  WHERE mg.sample_name = s.sample_name AND mg.did = split_part(pfam.query_name, '_'::text, 1) AND s.label = 'trait-gos-sites'::text AND pfam.fullevalue < 0.001 AND abs(log(pfam.full_score + 1::double precision) - log(pfam.full_bias + 1::double precision)) > 1::double precision;

-- fix rkottman.network_reads
CREATE OR REPLACE VIEW rkottman.network_reads AS 
 SELECT mg.study, mg.sample_name, mg.did, mg.did_auth as did_code
   FROM core.sample_sets s, core.mg_dnas mg
  WHERE mg.sample_name = s.sample_name AND s.label = 'trait-gos-sites'::text;

-- fix rkottman.pfam_trait_gos
CREATE OR REPLACE VIEW rkottman.pfam_trait_gos AS 
 SELECT mg.did, mg.sample_name, pfam.target_name, pfam.target_accession, pfam.tlen, pfam.query_name, pfam.accession, pfam.qlen, pfam.fullevalue, pfam.full_score, pfam.full_bias, pfam.domain_num, pfam.domain_of, pfam.domain_cevalue, pfam.domain_ievalue, pfam.domain_score, pfam.domain_bias, pfam.hmm_from, pfam.hmm_to, pfam.ali_from, pfam.ali_to, pfam.env_from, pfam.env_to, pfam.acc, pfam.descr, pfam.dataset, pfam.pfam_db_version
   FROM core.sample_sets s, core.mg_dnas mg, rkottman.pfam26_vs_gos pfam
  WHERE mg.sample_name = s.sample_name AND mg.did = split_part(pfam.query_name, '_'::text, 1) AND s.label = 'trait-gos-sites'::text AND pfam.fullevalue < 0.001 AND abs(log(pfam.full_score + 1::double precision) - log(pfam.full_bias + 1::double precision)) > 1::double precision;
COMMIT;
