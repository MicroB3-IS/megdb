BEGIN;

SELECT _v.register_patch( '16-changes-from-discussion', ARRAY['15-logging'], NULL );

--see issue MEGX-#190
ALTER TABLE core.samplingsites ADD COLUMN verb_name TEXT;

--see issue MEGX-#192
ALTER TABLE core.samplingsites DROP COLUMN gmslabel;

--see issue MEGX-#193
--A. modify dependencies
CREATE OR REPLACE VIEW web_r8.genome_reports AS 
 SELECT site.label AS site_name, st_y(site.geom) AS lat, st_x(site.geom) AS lon, 
    (st_y(site.geom)::text || ' '::text) || st_x(site.geom)::text AS lat_lon, 
    sam.date_taken AS collection_date, sam.date_res, sam.label AS sample_name, 
    sam.material, sam.hab_lite AS biome, sam.country AS geo_loc_name, 
    i.label AS isolate_name, i.taxid, i.genus, i.species, i.strain, 
        CASE
            WHEN i.type_strain = (-1) THEN 'f'::text
            ELSE 't'::text
        END AS type_strain, 
    i.subspecies, i.serovar, i.num_chromosomes, i.num_plasmids, 
    i.num_chromosomes + i.num_plasmids AS num_replicons, i.oxygen_class, 
    i.cell_shape, i.cell_arrange, i.energy_source, i.temperature_range, 
    i.temperature_class, i.salinity_class, i.motility, i.sporulation, i.dsmz, 
    i.atcc, i.straininfo, i.ph_range, i.gram_stain, i.culture_collection_label, 
    gs.descr_short, gs.abstract, gs.gpid, gs.goldstamp, gs.gcat_id, gs.img_oid, 
    gs.seq_center, gs.resequencing, gs.status AS finishing_strategy, 
    array_to_string(seqs.seq_ids, ','::text) AS seq_ids, 
    'bacteria_archaea'::text AS investigation_type, true AS submitted_to_insdc
   FROM core.samplingsites site
   RIGHT JOIN core.samples sam ON site.geom = sam.geom AND site.max_uncertain = sam.max_uncertain
   JOIN core.isolates i ON sam.study = i.study AND sam.label = i.sample_name
   JOIN core.genome_studies gs ON gs.isolate_name = i.label
   LEFT JOIN ( SELECT genomic_sequences.gpid, array_agg(genomic_sequences.did) AS seq_ids
   FROM core.genomic_sequences
  WHERE genomic_sequences.did_auth <> 'acc'::text
  GROUP BY genomic_sequences.gpid) seqs ON seqs.gpid = gs.gpid;

ALTER TABLE web_r8.genome_reports
  OWNER TO rkottman;
GRANT ALL ON TABLE web_r8.genome_reports TO rkottman;
GRANT SELECT ON TABLE web_r8.genome_reports TO megxuser;
GRANT SELECT ON TABLE web_r8.genome_reports TO selectors;
GRANT SELECT ON TABLE web_r8.genome_reports TO megx_team;
COMMENT ON VIEW web_r8.genome_reports
  IS 'Web view on MIGS consistent genome reports;';

-- View: web.blast_genomes

-- DROP VIEW web.blast_genomes;

CREATE OR REPLACE VIEW web.blast_genomes AS 
 SELECT t.sid, t.jid, t.id, t.hit, t.hsp, t.descr, t.h_length, t.evalue, 
    t.gi AS acc, t.bit_score, t.q_from, t.q_to, t.h_from, t.h_to, t.q_frame, 
    t.h_frame, t.ident, t.pos, t.a_length, i.label AS locdesc, s.date_taken, 
    s.hab_lite, core.encode_uri(s.hab_lite) AS hab_uri, 
        CASE
            WHEN core.pp_geom(s.old_geom) = ''::text THEN '-'::text
            ELSE core.pp_geom(s.old_geom)
        END AS latlon, 
    s.old_geom AS geom, 
    ( SELECT (sm.vals[1]::text || ' '::text) || sm.unit AS vals
           FROM core.sample_measures sm
          WHERE sm.param = 'depth'::text AND sm.sid = s.sid) AS depth, 
    ( SELECT (sm.vals[1]::text || ' '::text) || sm.unit AS vals
           FROM core.sample_measures sm
          WHERE sm.param = 'temperature'::text AND sm.sid = s.sid) AS temperature
   FROM ( SELECT g.sid, g.jid, g.id, g.hit, g.hsp, g.hit_def AS descr, 
            g.h_length, g.evalue, 
                CASE
                    WHEN split_part(g.hit_id, '|'::text, 2) <> ''::text THEN split_part(g.hit_id, '|'::text, 2)::bigint
                    ELSE - 1::bigint
                END AS gi, 
            g.bit_score, g.q_from, g.q_to, g.h_from, g.h_to, g.q_frame, 
            g.h_frame, g.ident, g.pos, g.a_length
           FROM core.blast_hits g
          WHERE g.db = 'genomes'::text) t
   JOIN core.dna_regions dr ON t.gi = dr.gi
   JOIN core.genomic_sequences ds ON dr.did = ds.did AND dr.did_auth = ds.did_auth
   JOIN core.isolates i ON ds.isolate_id = i.id
   JOIN core.samples s ON i.sid = s.sid;

ALTER TABLE web.blast_genomes
  OWNER TO ikostadi;
GRANT ALL ON TABLE web.blast_genomes TO ikostadi;
GRANT SELECT ON TABLE web.blast_genomes TO selectors;
GRANT SELECT ON TABLE web.blast_genomes TO megx_team;

DROP TABLE core.genome_dnas;

COMMIT;