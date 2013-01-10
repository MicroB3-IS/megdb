BEGIN;

SELECT _v.register_patch( '19-ribosomal-sequence-table', ARRAY['18-blast-run-stdout'], NULL );

CREATE TABLE core.ribosomal_sequences (
  sequence text NOT NULL DEFAULT ''::text,
  size integer NOT NULL DEFAULT 0,
  gc numeric NOT NULL DEFAULT 'NaN'::numeric,
  data_source text,
  retrieved timestamp without time zone NOT NULL DEFAULT now(),
  project integer DEFAULT 0,
  own text DEFAULT 'megdb'::text,
  did text NOT NULL DEFAULT ''::text,
  did_auth text NOT NULL DEFAULT ''::text,
  mol_type text DEFAULT ''::text,
  acc_ver text NOT NULL DEFAULT ''::text,
  isolate_id integer NOT NULL,
  gpid integer,
  center text,
  status text DEFAULT ''::text,
  seq_platform text NOT NULL DEFAULT ''::text,
  seq_approach text NOT NULL DEFAULT ''::text,
  seq_method text NOT NULL DEFAULT ''::text,
  study text NOT NULL DEFAULT ''::text,
  sample_name text,
  isolate_name text NOT NULL DEFAULT ''::text,
  estimated_error_rate text NOT NULL DEFAULT ''::text,
  calculation_method text NOT NULL DEFAULT ''::text,
  CONSTRAINT ribosomal_sequences_pkey PRIMARY KEY (did, did_auth),
  CONSTRAINT ribosomal_sequences_id_auth_fkey FOREIGN KEY (did_auth)
      REFERENCES core.id_codes (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ribosomal_sequences_own_fkey FOREIGN KEY (own)
      REFERENCES core.logins (logname) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ribosomal_sequences_project_fkey FOREIGN KEY (project)
      REFERENCES core.projects (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ribosomal_sequences_seq_approach_fkey FOREIGN KEY (seq_approach)
      REFERENCES cv.seq_approaches (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT ribosomal_sequences_seq_method_fkey FOREIGN KEY (seq_method)
      REFERENCES cv.seq_methods (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT ribosomal_sequences_seq_platform_fkey FOREIGN KEY (seq_platform)
      REFERENCES cv.seq_platforms (term) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT ribosomal_sequences_status_check CHECK (status = ANY (ARRAY['draft'::text, 'complete'::text, ''::text]))
);

COMMIT;  