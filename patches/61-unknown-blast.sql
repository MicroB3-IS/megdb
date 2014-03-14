Begin;

SELECT _v.register_patch('61-unknown-blast',
                          array['61-core-biodb-table'] );

--schema creation
CREATE SCHEMA megx_blast
  AUTHORIZATION megdb_admin;
REVOKE ALL ON SCHEMA megx_blast FROM public;

GRANT USAGE ON SCHEMA megx_blast TO selectors;
GRANT ALL ON SCHEMA megx_blast TO sge;
GRANT USAGE ON SCHEMA megx_blast TO megxuser;

ALTER DEFAULT PRIVILEGES IN SCHEMA megx_blast
    GRANT SELECT ON TABLES
    TO selectors, megxuser;

--create type for job time protocol
CREATE TYPE megx_blast.time_log_entry AS
   (job_id text,
    "comment" text,
    run_time numeric);
ALTER TYPE megx_blast.time_log_entry OWNER TO megdb_admin;

--create table for blast jobs
CREATE TABLE megx_blast.blast_jobs (
  id numeric(16,15) DEFAULT (random())::numeric(16,15),
  label text NOT NULL DEFAULT '',
  customer text NOT NULL,
  num_neighbors smallint NOT NULL DEFAULT 1,
  tool_label text NOT NULL DEFAULT ''::text,
  tool_ver text NOT NULL DEFAULT ''::text,
  program_name text NOT NULL DEFAULT ''::text,
  biodb_label text NOT NULL DEFAULT ''::text,
  biodb_version text NOT NULL DEFAULT ''::text,
  seq text NOT NULL DEFAULT ''::text,
  evalue numeric NOT NULL DEFAULT 0.00001,
  gap_open smallint,
  gap_extend smallint,
  x_dropoff smallint,
  gi_defline boolean,
  nuc_mismatch smallint,
  nuc_match smallint,
  num_desc smallint,
  num_align smallint,
  ext_threshold smallint,
  gap_align boolean,
  genetic_code smallint,
  db_gen_code smallint,
  num_processors smallint,
  believe_seq_file boolean,
  matrix text,
  word_size smallint,
  effective_db numeric,
  kept_hits integer,
  effective_space numeric,
  query_strand smallint,
  x_dropoff_ungap numeric,
  x_dropoff_gap numeric,
  multi_hits_win_size smallint,
  concat_queries smallint,
  legacy_engine boolean,
  composition_stat text,
  local_optimum boolean,
  result xml NOT NULL DEFAULT '<e/>'::xml,
  result_raw xml NOT NULL DEFAULT '<e/>'::xml,
  filter "char" DEFAULT ''::"char",
  time_submitted timestamp with time zone NOT NULL DEFAULT now(),
  time_finished timestamp with time zone,
  make_public interval NOT NULL DEFAULT '00:00:00'::interval,
  keep_data interval NOT NULL DEFAULT '7 days'::interval,
  time_started timestamp with time zone,
  cluster_node text,
  job_id integer,
  return_code integer,
  error_message text,
  total_run_time numeric DEFAULT (0)::numeric,
  time_protocol megx_blast.time_log_entry[] NOT NULL DEFAULT ARRAY[ROW(''::text, ''::text, (1)::numeric)::megx_blast.time_log_entry],
  
  FOREIGN KEY (tool_label, tool_ver)
      REFERENCES core.tool_versions (label, ver)
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  FOREIGN KEY (customer)
      REFERENCES auth.users (logname)
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CHECK (filter = ANY (ARRAY['t'::"char", 'f'::"char", ''::"char"])),
  CHECK (job_id > 0),
  CHECK program_name IN ['blastp', 'blastn', 'blastx', 'tblastn', 'tblastx']
);
ALTER TABLE megx_blast.blast_jobs OWNER TO megdb_admin;
GRANT ALL ON TABLE megx_blast.blast_jobs TO megdb_admin;
GRANT SELECT ON TABLE megx_blast.blast_jobs TO selectors;
GRANT SELECT ON TABLE megx_blast.blast_jobs TO megxuser;
GRANT SELECT, INSERT ON TABLE megx_blast.blast_jobs TO sge;

-- Trigger: megx_blast_jobs_i_to_queue on megx_blast.megx_blast_jobs
CREATE TRIGGER megx_blast_jobs_i_to_queue
  AFTER INSERT
  ON megx_blast.blast_jobs
  FOR EACH ROW
  EXECUTE PROCEDURE pgq.logutriga('qsubq');

--create table for blast hits
CREATE TABLE megx_blast.blast_hits (
  jid numeric NOT NULL,
  db text NOT NULL,
  hit smallint NOT NULL DEFAULT (-1),
  hit_id text NOT NULL,
  hit_def text NOT NULL,
  hit_acc text NOT NULL,
  hit_length integer NOT NULL DEFAULT (-1),
  hsp_num smallint NOT NULL DEFAULT (-1),
  hsp_length integer NOT NULL DEFAULT (-1),
  hsp_evalue numeric NOT NULL,
  hsp_bit_score numeric NOT NULL DEFAULT 'NaN'::numeric,
  hsp_q_from integer NOT NULL DEFAULT (-1),
  hsp_q_to integer NOT NULL DEFAULT (-1),
  hsp_h_from integer NOT NULL DEFAULT (-1),
  hsp_h_to integer NOT NULL DEFAULT (-1),
  hsp_q_frame smallint NOT NULL DEFAULT (-1),
  hsp_h_frame smallint NOT NULL DEFAULT (-1),
  hsp_identical numeric NOT NULL DEFAULT (-1),
  hsp_conserved numeric NOT NULL DEFAULT (-1),
  hsp_q_string text NOT NULL DEFAULT ''::text,
  hsp_h_string text NOT NULL DEFAULT ''::text,
  hsp_homology_string text NOT NULL DEFAULT ''::text,
  subnet_graphml xml NOT NULL DEFAULT '<e/>'::xml,
  subnet_json json NOT NULL,
  hit_neighborhood hstore NOT NULL,
  kegg_url_args text[] NOT NULL DEFAULT '{}'::text[],
  PRIMARY KEY (jid, hit)
);

ALTER TABLE megx_blast.blast_hits OWNER TO megdb_admin;
GRANT ALL ON TABLE megx_blast.blast_hits TO megdb_admin;
GRANT SELECT ON TABLE megx_blast.blast_hits TO selectors;
GRANT SELECT ON TABLE megx_blast.blast_hits TO megxuser;
GRANT SELECT, INSERT ON TABLE megx_blast.blast_hits TO sge;
COMMENT ON TABLE megx_blast.blast_hits IS ''; 

rollback;
--commit;
