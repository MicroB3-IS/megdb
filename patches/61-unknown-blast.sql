Begin;

SELECT _v.register_patch('61-unknown-blast',
                          array['60-mg-traits-pk-pca-table'] );

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

-- TODO please add comment to what exactly is db_version

CREATE TABLE megx_blast.blast_db (
  db_version text NOT NULL,
  pfam_release decimal(4,2) NOT NULL --TODO consider creating a domain for this
);

ALTER TABLE megx_blast.blast_db OWNER TO megdb_admin;
GRANT ALL ON TABLE megx_blast.blast_db TO megdb_admin;
GRANT SELECT ON TABLE megx_blast.blast_db TO selectors;
GRANT SELECT ON TABLE megx_blast.blast_db TO megxuser;
GRANT SELECT, INSERT ON TABLE megx_blast.blast_db TO sge;

--create table for blast jobs

CREATE TABLE megx_blast.blast_jobs (
  id numeric(16,15) DEFAULT (random())::numeric(16,15),
  label text NOT NULL DEFAULT '',
  customer text NOT NULL,
  num_neighbors smallint NOT NULL DEFAULT 1,
  tool_label text NOT NULL DEFAULT ''::text,
  tool_ver text NOT NULL DEFAULT ''::text,
  program_name text NOT NULL DEFAULT ''::text,
  db text NOT NULL DEFAULT ''::text,
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
  stdout text, --TODO what's this ?
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
  
  CONSTRAINT blast_run_label_fkey FOREIGN KEY (tool_label, tool_ver)
      REFERENCES core.tool_versions (label, ver)
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT megx_blast_jobs_customer_fkey FOREIGN KEY (customer)
      REFERENCES auth.users (logname)
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT blast_run_filter_check CHECK (filter = ANY (ARRAY['t'::"char", 'f'::"char", ''::"char"])),
  CONSTRAINT megx_blast_jobs_job_id_check CHECK (job_id > 0),

-- TODO does this still hold true?
  CONSTRAINT valid_program_name CHECK (program_name = 'blastp'::text OR program_name = 'blastn'::text),
  CONSTRAINT valid_seq CHECK (seq ~* '[^j,o]+'::text)
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
  EXECUTE PROCEDURE pgq.logutriga('qsubq'); --TODO is this correct queue

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
  graphml_file xml NOT NULL DEFAULT '<e/>'::xml,
  hit_neighborhood text[] NOT NULL DEFAULT '{}'::text[],
  kegg_url_args text[] NOT NULL DEFAULT '{}'::text[],
  PRIMARY KEY (jid, hit)
);

ALTER TABLE megx_blast.blast_hits OWNER TO megdb_admin;
GRANT ALL ON TABLE megx_blast.blast_hits TO megdb_admin;
GRANT SELECT ON TABLE megx_blast.blast_hits TO selectors;
GRANT SELECT ON TABLE megx_blast.blast_hits TO megxuser;
GRANT SELECT, INSERT ON TABLE megx_blast.blast_hits TO sge;

--create table for PFAM proteomes organisms
-- TODO is this a direct import of PFAM ?

CREATE TABLE megx_blast.pfam_proteomes_organism (
  organism_id integer, -- what's the organims id
  organim_name text NOT NULL DEFAULT ''::text,
  organism_domain text NOT NULL DEFAULT ''::text,
  pfam_release decimal(4,2) NOT NULL,
  PRIMARY KEY (organism_id, pfam_release)
);

ALTER TABLE megx_blast.pfam_proteomes_organism OWNER TO megdb_admin;
GRANT ALL ON TABLE megx_blast.pfam_proteomes_organism TO megdb_admin;
GRANT SELECT ON TABLE megx_blast.pfam_proteomes_organism TO selectors;
GRANT SELECT ON TABLE megx_blast.pfam_proteomes_organism TO megxuser;
GRANT SELECT, INSERT ON TABLE megx_blast.pfam_proteomes_organism TO sge;

--create table for PFAM proteomes
CREATE TABLE megx_blast.pfam_proteomes (
  organism_id integer NOT NULL,
  seq_id text NOT NULL DEFAULT ''::text, --TODO which seq_ id ?
  pfam_acc text NOT NULL DEFAULT ''::text,
  pfam_name text NOT NULL DEFAULT ''::text,
  pfam_type text NOT NULL DEFAULT ''::text,
  pfam_clan text NOT NULL DEFAULT ''::text,
  pfam_release decimal(4,2) NOT NULL,
  PRIMARY KEY (organism_id, seq_id, pfam_release)
);

ALTER TABLE megx_blast.pfam_proteomes OWNER TO megdb_admin;
GRANT ALL ON TABLE megx_blast.pfam_proteomes TO megdb_admin;
GRANT SELECT ON TABLE megx_blast.pfam_proteomes TO selectors;
GRANT SELECT ON TABLE megx_blast.pfam_proteomes TO megxuser;
GRANT SELECT, INSERT ON TABLE megx_blast.pfam_proteomes TO sge;

--create table for proteomic unknown subnetworks

CREATE TABLE megx_blast.pfam_proteomes_subnetwork (
  organism_id integer NOT NULL,
  nodes text[] NOT NULL DEFAULT '{}'::text[],
  graphml_file xml NOT NULL DEFAULT '<e/>'::xml, -- TODO isn't it xml? we can use xml datat ype then
  kegg_kos text[] NOT NULL DEFAULT '{}'::text[],
  pfam_release decimal(4,2) NOT NULL,
  PRIMARY KEY (organism_id, pfam_release)
);

ALTER TABLE megx_blast.pfam_proteomes_subnetwork OWNER TO megdb_admin;
GRANT ALL ON TABLE megx_blast.pfam_proteomes_subnetwork TO megdb_admin;
GRANT SELECT ON TABLE megx_blast.pfam_proteomes_subnetwork TO selectors;
GRANT SELECT ON TABLE megx_blast.pfam_proteomes_subnetwork TO megxuser;
GRANT SELECT, INSERT ON TABLE megx_blast.pfam_proteomes_subnetwork TO sge;


rollback;
--commit;
