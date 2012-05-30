BEGIN;
SET search_path TO core,public;

DROP TRIGGER aa_samples_b_trg ON core.samples;

create table partitions.sample_3 (
      like core.metagenomic_sequences_template including defaults,
      primary key (sample_name, did, did_auth, study),
      FOREIGN KEY (assembly_status)
          REFERENCES cv.assembly_status (term) MATCH SIMPLE
          ON UPDATE CASCADE ON DELETE NO ACTION,
      FOREIGN KEY (own)
          REFERENCES core.logins (logname) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      FOREIGN KEY (project)
          REFERENCES core.projects (id) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      FOREIGN KEY (seq_method)
          REFERENCES cv.seq_methods (term) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      FOREIGN KEY (sample_name)
          REFERENCES core.samples(label) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      FOREIGN KEY (study)
          REFERENCES core.studies(label) MATCH SIMPLE 
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      check (sample_name = 'GS044')
      );
      
create table partitions.pool_1 (
      like core.pooled_metagenomic_sequences_template including defaults,
      primary key (pool_label, did, did_auth, study),
      FOREIGN KEY (assembly_status)
          REFERENCES cv.assembly_status (term) MATCH SIMPLE
          ON UPDATE CASCADE ON DELETE NO ACTION,
      FOREIGN KEY (own)
          REFERENCES core.logins (logname) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      FOREIGN KEY (project)
          REFERENCES core.projects (id) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      FOREIGN KEY (seq_method)
          REFERENCES cv.seq_methods (term) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      FOREIGN KEY (pool_label, study)
          REFERENCES core.sample_pools(label, study) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      check (pool_label = 'GS000b')
      );
COMMIT;