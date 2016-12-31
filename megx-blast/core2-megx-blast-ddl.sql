
-- this is to kick-start new core schema
-- inlcudes full curation support
-- and also new megx-blast
BEGIN;


-- Table: core.biodb

-- DROP TABLE core.biodb;

CREATE TABLE megx-blast.biodb (
  label text NOT NULL,
  cat text NOT NULL DEFAULT ''::text,
  remark text NOT NULL DEFAULT ''::text,
  descr text NOT NULL DEFAULT ''::text,
  ctime timestamp with time zone NOT NULL DEFAULT now(),
  mtime timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT biodb_pkey PRIMARY KEY (label)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE megx-blast.biodb
  OWNER TO megdb_admin;
  GRANT SELECT ON TABLE megx-blast.biodb TO selectors;
  GRANT SELECT ON TABLE megx-blast.biodb TO megxuser;
  GRANT SELECT, INSERT ON TABLE megx-blast.biodb TO sge;

COMMENT ON TABLE megx-blast.biodb
      IS 'List of name databases as distributed in the cluster.';
    

-- Table: megx-blast.biodb_version

-- DROP TABLE megx-blast.biodb_version;

CREATE TABLE megx-blast.biodb_version
(
  label text NOT NULL,
  ver text NOT NULL,
  descr text NOT NULL DEFAULT ''::text,
  CONSTRAINT biodb_version_pkey PRIMARY KEY (label, ver),
  CONSTRAINT biodb_version_label_fkey FOREIGN KEY (label)
 REFERENCES megx-blast.biodb (label) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION
      )
      WITH (
        OIDS=FALSE
);
ALTER TABLE megx-blast.biodb_version
  OWNER TO megdb_admin;
  GRANT ALL ON TABLE megx-blast.biodb_version TO megdb_admin;
  GRANT SELECT ON TABLE megx-blast.biodb_version TO selectors;
  GRANT SELECT ON TABLE megx-blast.biodb_version TO megxuser;
  GRANT SELECT, INSERT ON TABLE megx-blast.biodb_version TO sge;
  COMMENT ON TABLE megx-blast.biodb_version
    IS 'List of versions for databases distributed in the cluster.';



-- Table: megx-blast.blast_hits

-- DROP TABLE megx-blast.blast_hits;

CREATE TABLE megx-blast.blast_hits
(
  sid text NOT NULL, -- sample identifier
    jid numeric NOT NULL,
      db text NOT NULL,
        hit smallint NOT NULL DEFAULT (-1), -- <Hit_num>
  hit_id text NOT NULL, -- hit identifier
    hit_def text NOT NULL,
      hit_acc text NOT NULL,
        hsp smallint NOT NULL DEFAULT (-1), -- high-scoring segment pairs
  h_length integer NOT NULL DEFAULT (-1), -- length of the HSP
    evalue numeric NOT NULL, -- <Hsp_evalue>
      bit_score numeric NOT NULL DEFAULT 'NaN'::numeric, -- <Hsp_bit-score>
        q_from integer NOT NULL DEFAULT (-1), -- <Hsp_query-from>
  q_to integer NOT NULL DEFAULT (-1), -- <hsp_query-to>
    h_from integer NOT NULL DEFAULT (-1),
      h_to integer NOT NULL DEFAULT (-1),
        q_frame smallint NOT NULL DEFAULT (-1),
  h_frame smallint NOT NULL DEFAULT (-1),
    ident integer NOT NULL DEFAULT (-1), -- identity percentage
      pos integer NOT NULL DEFAULT (-1), -- position
        a_length integer NOT NULL DEFAULT (-1),
  id bigserial NOT NULL, -- only needed for mapserver getfeature request. Pure artificial key
    CONSTRAINT blast_hits_pkey PRIMARY KEY (sid, jid, hit),
      CONSTRAINT blast_hits_key FOREIGN KEY (sid, jid)
            REFERENCES megx-blast.blast_run (sid, jid) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION
  )
  WITH (
    OIDS=FALSE
    );
    ALTER TABLE megx-blast.blast_hits
      OWNER TO rkottman;
      GRANT ALL ON TABLE megx-blast.blast_hits TO rkottman;
      GRANT SELECT ON TABLE megx-blast.blast_hits TO selectors;
      GRANT ALL ON TABLE megx-blast.blast_hits TO core_admin;
      GRANT INSERT ON TABLE megx-blast.blast_hits TO megxuser;
      GRANT ALL ON TABLE megx-blast.blast_hits TO afernand;
      COMMENT ON TABLE megx-blast.blast_hits
        IS 'Blast results and search parameters.';
COMMENT ON COLUMN megx-blast.blast_hits.sid IS 'sample identifier';
COMMENT ON COLUMN megx-blast.blast_hits.hit IS '<Hit_num>';
COMMENT ON COLUMN megx-blast.blast_hits.hit_id IS 'hit identifier';
COMMENT ON COLUMN megx-blast.blast_hits.hsp IS 'high-scoring segment pairs';
COMMENT ON COLUMN megx-blast.blast_hits.h_length IS 'length of the HSP';
COMMENT ON COLUMN megx-blast.blast_hits.evalue IS '<Hsp_evalue>';
COMMENT ON COLUMN megx-blast.blast_hits.bit_score IS '<Hsp_bit-score>';
COMMENT ON COLUMN megx-blast.blast_hits.q_from IS '<Hsp_query-from>';
COMMENT ON COLUMN megx-blast.blast_hits.q_to IS '<hsp_query-to>';
COMMENT ON COLUMN megx-blast.blast_hits.ident IS 'identity percentage';
COMMENT ON COLUMN megx-blast.blast_hits.pos IS 'position';
COMMENT ON COLUMN megx-blast.blast_hits.id IS 'only needed for mapserver getfeature request. Pure artificial key';


-- Index: megx-blast.blast_hits_id_idx

-- DROP INDEX megx-blast.blast_hits_id_idx;

CREATE UNIQUE INDEX blast_hits_id_idx
  ON megx-blast.blast_hits
    USING btree
      (id);



-- Table: megx-blast.blast_run

-- DROP TABLE megx-blast.blast_run;

CREATE TABLE megx-blast.blast_run
(
  sid text NOT NULL, -- session id
    jid numeric(16,15) NOT NULL DEFAULT (random())::numeric(16,15), -- job identifier
      time_submitted timestamp without time zone NOT NULL DEFAULT now(), -- date and time of job submission
        time_finished timestamp without time zone NOT NULL DEFAULT 'infinity'::timestamp without time zone, -- date and time of job finished
  who text NOT NULL, -- who submitted the job
    tool_label text NOT NULL DEFAULT ''::text, -- name of the tool
      tool_ver text NOT NULL DEFAULT ''::text, -- version of the tool
        program_name text NOT NULL, -- name of the used program
  db text NOT NULL, -- name of the database used
    seq text NOT NULL, -- sequence used for the job
      evalue numeric, -- obtained evalue
        gap_open smallint, -- number of gap openings
  gap_extend smallint, -- number of gap extensions
    x_dropoff smallint, -- value for evalue dropoff???
      gi_defline boolean,
        nuc_mismatch smallint, -- number of nucleotide mismatches
  nuc_match smallint, -- number of nucleotide matches
    num_desc smallint,
      num_align smallint,
        ext_threshold smallint, -- extension threshold
  gap_align boolean,
    genetic_code smallint, -- genetic code used for protein translation
      db_gen_code smallint,
        num_processors smallint, -- number of processors used to run the job
  believe_seq_file boolean,
    matrix text, -- used matrix
      word_size smallint, -- minimum word size
        effective_db numeric,
  kept_hits integer, -- hits kept with the drop off criteria
    effective_space numeric,
      query_strand smallint,
        x_dropoff_ungap numeric,
  x_dropoff_gap numeric,
    multi_hits_win_size smallint,
      concat_queries smallint,
        legacy_engine boolean,
  composition_stat text,
    local_optimum boolean,
      result xml NOT NULL DEFAULT '<e/>'::xml, -- results after filtering
        result_raw xml NOT NULL DEFAULT '<e/>'::xml, -- all results
  filter "char" DEFAULT ''::"char", -- filter used
    stdout text,
      CONSTRAINT blast_run_pkey PRIMARY KEY (sid, jid),
        CONSTRAINT blast_run_label_fkey FOREIGN KEY (tool_label, tool_ver)
      REFERENCES megx-blast.tool_versions (label, ver) MATCH SIMPLE
            ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT blast_run_filter_check CHECK (filter = ANY (ARRAY['t'::"char", 'f'::"char", ''::"char"])),
        CONSTRAINT valid_program_name CHECK (program_name = 'blastp'::text OR program_name = 'blastn'::text),
  CONSTRAINT valid_seq CHECK (seq ~* '[^j,o]+'::text)
  )
  WITH (
    OIDS=FALSE
    );
    ALTER TABLE megx-blast.blast_run
      OWNER TO ikostadi;
      GRANT ALL ON TABLE megx-blast.blast_run TO ikostadi;
      GRANT SELECT ON TABLE megx-blast.blast_run TO selectors;
      GRANT INSERT ON TABLE megx-blast.blast_run TO megxuser;
      GRANT SELECT, UPDATE ON TABLE megx-blast.blast_run TO sge;
      GRANT ALL ON TABLE megx-blast.blast_run TO afernand;
      COMMENT ON TABLE megx-blast.blast_run
        IS 'Parameters for Blast run and spended time';
COMMENT ON COLUMN megx-blast.blast_run.sid IS 'session id';
COMMENT ON COLUMN megx-blast.blast_run.jid IS 'job identifier';
COMMENT ON COLUMN megx-blast.blast_run.time_submitted IS 'date and time of job submission';
COMMENT ON COLUMN megx-blast.blast_run.time_finished IS 'date and time of job finished';
COMMENT ON COLUMN megx-blast.blast_run.who IS 'who submitted the job';
COMMENT ON COLUMN megx-blast.blast_run.tool_label IS 'name of the tool';
COMMENT ON COLUMN megx-blast.blast_run.tool_ver IS 'version of the tool';
COMMENT ON COLUMN megx-blast.blast_run.program_name IS 'name of the used program';
COMMENT ON COLUMN megx-blast.blast_run.db IS 'name of the database used';
COMMENT ON COLUMN megx-blast.blast_run.seq IS 'sequence used for the job';
COMMENT ON COLUMN megx-blast.blast_run.evalue IS 'obtained evalue';
COMMENT ON COLUMN megx-blast.blast_run.gap_open IS 'number of gap openings';
COMMENT ON COLUMN megx-blast.blast_run.gap_extend IS 'number of gap extensions';
COMMENT ON COLUMN megx-blast.blast_run.x_dropoff IS 'value for evalue dropoff???';
COMMENT ON COLUMN megx-blast.blast_run.nuc_mismatch IS 'number of nucleotide mismatches';
COMMENT ON COLUMN megx-blast.blast_run.nuc_match IS 'number of nucleotide matches';
COMMENT ON COLUMN megx-blast.blast_run.ext_threshold IS 'extension threshold';
COMMENT ON COLUMN megx-blast.blast_run.genetic_code IS 'genetic code used for protein translation';
COMMENT ON COLUMN megx-blast.blast_run.num_processors IS 'number of processors used to run the job';
COMMENT ON COLUMN megx-blast.blast_run.matrix IS 'used matrix';
COMMENT ON COLUMN megx-blast.blast_run.word_size IS 'minimum word size';
COMMENT ON COLUMN megx-blast.blast_run.kept_hits IS 'hits kept with the drop off criteria';
COMMENT ON COLUMN megx-blast.blast_run.result IS 'results after filtering';
COMMENT ON COLUMN megx-blast.blast_run.result_raw IS 'all results in raw form from blast output';
COMMENT ON COLUMN megx-blast.blast_run.filter IS 'filter used';


-- Trigger: blast_result_timestamp on megx-blast.blast_run

-- DROP TRIGGER blast_result_timestamp ON megx-blast.blast_run;

CREATE TRIGGER blast_result_timestamp
  BEFORE UPDATE
    ON megx-blast.blast_run
      FOR EACH ROW
        EXECUTE PROCEDURE megx-blast.update_date_finished();

-- Trigger: i_to_queue on megx-blast.blast_run

-- DROP TRIGGER i_to_queue ON megx-blast.blast_run;

CREATE TRIGGER i_to_queue
  AFTER INSERT
    ON megx-blast.blast_run
      FOR EACH ROW
        EXECUTE PROCEDURE pgq.logutriga('qsubq');





ROLLBACK;
