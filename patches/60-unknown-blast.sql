Begin;

SELECT _v.register_patch('60-unknown-blast',
                          array['59-logging-perms'] );

--schema creation
CREATE SCHEMA unknown_blast
  AUTHORIZATION megdb_admin;
GRANT ALL ON SCHEMA unknown_blast TO megdb_admin;
GRANT USAGE ON SCHEMA unknown_blast TO selectors;
GRANT ALL ON SCHEMA unknown_blast TO sge;
ALTER DEFAULT PRIVILEGES IN SCHEMA unknown_blast
    GRANT SELECT ON TABLES
    TO selectors;

--create sequence
CREATE SEQUENCE unknown_blast.blast_hits_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 357646
  CACHE 1;
ALTER TABLE unknown_blast.blast_hits_id_seq OWNER TO rkottman;
GRANT ALL ON TABLE unknown_blast.blast_hits_id_seq TO rkottman;
GRANT USAGE ON TABLE unknown_blast.blast_hits_id_seq TO megxuser;

--create type for job time protocol
CREATE TYPE unknown_blast.time_log_entry AS
   (job_id text,
    "comment" text,
    run_time numeric);
ALTER TYPE unknown_blast.time_log_entry OWNER TO rkottman;

--create table for unknown blast db
CREATE TABLE unknown_blast.unknown_blast_db
(
db_version text NOT NULL,
pfam_release decimal(4,2) NOT NULL
)WITH (
  OIDS=FALSE
);
ALTER TABLE unknown_blast.unknown_blast_db OWNER TO megdb_admin;
GRANT ALL ON TABLE unknown_blast.unknown_blast_db TO megdb_admin;
GRANT SELECT ON TABLE unknown_blast.unknown_blast_db TO selectors;
GRANT ALL ON TABLE unknown_blast.unknown_blast_db TO sge;

--create table for blast jobs
CREATE TABLE unknown_blast.unknown_blast_jobs
(
  sid text NOT NULL,
  jid numeric(16,15) NOT NULL DEFAULT (random())::numeric(16,15),
  customer text NOT NULL,
  num_neighbors smallint NOT NULL DEFAULT 1,
  tool_label text NOT NULL DEFAULT ''::text,
  tool_ver text NOT NULL DEFAULT ''::text,
  program_name text NOT NULL DEFAULT ''::text,,
  db text NOT NULL DEFAULT ''::text,,
  seq text NOT NULL DEFAULT ''::text,,
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
  "stdout" text,
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
  time_protocol unknown_blast.time_log_entry[] NOT NULL DEFAULT ARRAY[ROW(''::text, ''::text, (1)::numeric)::unknown_blast.time_log_entry],
  CONSTRAINT blast_run_pkey PRIMARY KEY (sid, jid),
  CONSTRAINT blast_run_label_fkey FOREIGN KEY (tool_label, tool_ver)
      REFERENCES core.tool_versions (label, ver)
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT unknown_blast_jobs_customer_fkey FOREIGN KEY (customer)
      REFERENCES auth.users (logname)
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT blast_run_filter_check CHECK (filter = ANY (ARRAY['t'::"char", 'f'::"char", ''::"char"])),
  CONSTRAINT unknown_blast_jobs_job_id_check CHECK (job_id > 0),
  CONSTRAINT valid_program_name CHECK (program_name = 'blastp'::text OR program_name = 'blastn'::text),
  CONSTRAINT valid_seq CHECK (seq ~* '[^j,o]+'::text)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE unknown_blast.blast_jobs OWNER TO megdb_admin;
GRANT ALL ON TABLE unknown_blast.blast_jobs TO megdb_admin;
GRANT SELECT ON TABLE unknown_blast.blast_jobs TO selectors;
GRANT ALL ON TABLE unknown_blast.blast_jobs TO sge;

-- Trigger: unknown_blast_jobs_i_to_queue on unknown_blast.unknown_blast_jobs

CREATE TRIGGER unknown_blast_jobs_i_to_queue
  AFTER INSERT
  ON unknown_blast.blast_jobs
  FOR EACH ROW
  EXECUTE PROCEDURE pgq.logutriga('qsubq');

--create table for blast hits
CREATE TABLE unknown_blast.blast_hits
(
  sid text NOT NULL,
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
  graphml_file text NOT NULL DEFAULT ''::text,
  hit_neighborhood text[] NOT NULL DEFAULT '{}'::text[],
  kegg_url text NOT NULL DEFAULT ''::text,
  CONSTRAINT blast_hits_pkey PRIMARY KEY (sid, jid, hit)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE unknown_blast.blast_hits OWNER TO rkottman;
GRANT ALL ON TABLE unknown_blast.blast_hits TO rkottman;
GRANT SELECT ON TABLE unknown_blast.blast_hits TO selectors;
GRANT ALL ON TABLE unknown_blast.blast_hits TO core_admin;
GRANT INSERT ON TABLE unknown_blast.blast_hits TO megxuser;
GRANT ALL ON TABLE unknown_blast.blast_hits TO afernand;
GRANT ALL ON TABLE unknown_blast.blast_hits TO sge;

--create table for PFAM proteomes organisms

CREATE TABLE unknown_blast.pfam_proteomes_organism
(
organism_id integer,
organim_name text NOT NULL DEFAULT ''::text,
organism_domain text NOT NULL DEFAULT ''::text,
pfam_release decimal(4,2) NOT NULL,
CONSTRAINT pfam_proteomes_organism_pkey PRIMARY KEY (organism_id, pfam_release)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE unknown_blast.pfam_proteomes_organism OWNER TO rkottman;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes_organism TO rkottman;
GRANT SELECT ON TABLE unknown_blast.pfam_proteomes_organism TO selectors;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes_organism TO core_admin;
GRANT INSERT ON TABLE unknown_blast.pfam_proteomes_organism TO megxuser;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes_organism TO afernand;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes_organism TO sge;

--create table for PFAM proteomes
CREATE TABLE unknown_blast.pfam_proteomes
(
organism_id integer NOT NULL,
seq_id text NOT NULL DEFAULT ''::text,
pfam_acc text NOT NULL DEFAULT ''::text,
pfam_name text NOT NULL DEFAULT ''::text,
pfam_type text NOT NULL DEFAULT ''::text,
pfam_clan text NOT NULL DEFAULT ''::text,
pfam_release decimal(4,2) NOT NULL,
CONSTRAINT pfam_proteomes_pkey PRIMARY KEY (organism_id, seq_id, pfam_release)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE unknown_blast.pfam_proteomes OWNER TO rkottman;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes TO rkottman;
GRANT SELECT ON TABLE unknown_blast.pfam_proteomes TO selectors;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes TO core_admin;
GRANT INSERT ON TABLE unknown_blast.pfam_proteomes TO megxuser;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes TO afernand;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes TO sge;

--create table for proteomic unknown subnetworks

CREATE TABLE unknown_blast.pfam_proteomes_subnetwork
(
organism_id integer NOT NULL,
nodes NOT NULL DEFAULT '{}'::text[],
graphml_file text NOT NULL DEFAULT ''::text,
kegg_url text NOT NULL DEFAULT ''::text,
pfam_release decimal(4,2) NOT NULL,
CONSTRAINT pfam_proteomes_subnetwork_pkey PRIMARY KEY (organism_id, pfam_release)
WITH (
  OIDS=FALSE
);
ALTER TABLE unknown_blast.pfam_proteomes_subnetwork OWNER TO rkottman;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes_subnetwork TO rkottman;
GRANT SELECT ON TABLE unknown_blast.pfam_proteomes_subnetwork TO selectors;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes_subnetwork TO core_admin;
GRANT INSERT ON TABLE unknown_blast.pfam_proteomes_subnetwork TO megxuser;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes_subnetwork TO afernand;
GRANT ALL ON TABLE unknown_blast.pfam_proteomes_subnetwork TO sge;


rollback;
--commit;
