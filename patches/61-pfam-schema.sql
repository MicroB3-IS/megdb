Begin;

SELECT _v.register_patch('61-pfam-schema',
                          array['61-unknown-blast'] );

--schema creation
CREATE SCHEMA pfam
  AUTHORIZATION megdb_admin;
REVOKE ALL ON SCHEMA pfam FROM public;

GRANT USAGE ON SCHEMA pfam TO selectors;
GRANT ALL ON SCHEMA pfam TO sge;
GRANT USAGE ON SCHEMA pfam TO megxuser;

ALTER DEFAULT PRIVILEGES IN SCHEMA pfam
    GRANT SELECT ON TABLES
    TO selectors, megxuser;

--create table for PFAM proteomes organisms
CREATE TABLE pfam.proteomes_organism (
  organism_taxid integer, -- what's the organims id
  organism_name text NOT NULL DEFAULT ''::text,
  organism_domain text NOT NULL DEFAULT ''::text,
  biodb_label text NOT NULL CHECK biodb_label = 'pfam',
  biodb_version text NOT NULL,
  PRIMARY KEY (organism_taxid, biodb_version)
  FOREIGN KEY (biodb_label, biodb_version)
     REFERENCES core.biodb_version (label, ver)
);
ALTER TABLE pfam.proteomes_organism OWNER TO megdb_admin;
GRANT ALL ON TABLE pfam.proteomes_organism TO megdb_admin;
GRANT SELECT ON TABLE pfam.proteomes_organism TO selectors;
GRANT SELECT ON TABLE pfam.proteomes_organism TO megxuser;
GRANT SELECT, INSERT ON TABLE pfam.proteomes_organism TO sge;
COMMENT ON TABLE pfam.proteomes_organism.organism_taxid 'NCBI tax_id'

--create table for PFAM proteomes
CREATE TABLE pfam.proteomes (
  organism_taxid integer NOT NULL,
  uniprot_id text NOT NULL DEFAULT ''::text, --TODO which seq_ id ?
  pfam_acc text NOT NULL DEFAULT ''::text,
  pfam_name text NOT NULL DEFAULT ''::text,
  pfam_type text NOT NULL DEFAULT ''::text,
  pfam_clan text NOT NULL DEFAULT ''::text,
  biodb_label text NOT NULL CHECK biodb_label = 'pfam',
  biodb_version text NOT NULL,
  PRIMARY KEY (organism_taxid, uniprot_id, biodb_version)
  FOREIGN KEY (biodb_label, biodb_version)
     REFERENCES core.biodb_version (label, ver)
);

ALTER TABLE .proteomes OWNER TO megdb_admin;
GRANT ALL ON TABLE pfam.proteomes TO megdb_admin;
GRANT SELECT ON TABLE pfam.proteomes TO selectors;
GRANT SELECT ON TABLE pfam.proteomes TO megxuser;
GRANT SELECT, INSERT ON TABLE pfam.proteomes TO sge;

--create table for proteomic unknown subnetworks

-- CREATE TABLE pfam.proteomes_subnetwork (
--   organism_taxid integer NOT NULL,
--   nodes text[] NOT NULL DEFAULT '{}'::text[],
--   graphml_file xml NOT NULL DEFAULT '<e/>'::xml,
--   kegg_kos text[] NOT NULL DEFAULT '{}'::text[],
--   biodb_label text NOT NULL CHECK biodb_label = 'pfam',
--   biodb_version text NOT NULL,
--   PRIMARY KEY (organism_taxid, biodb_version)
--   FOREIGN KEY (biodb_label, biodb_version)
--      REFERENCES core.biodb_version (label, ver)
-- );

-- ALTER TABLE pfam.proteomes_subnetwork OWNER TO megdb_admin;
-- GRANT ALL ON TABLE pfam.proteomes_subnetwork TO megdb_admin;
-- GRANT SELECT ON TABLE pfam.proteomes_subnetwork TO selectors;
-- GRANT SELECT ON TABLE pfam.proteomes_subnetwork TO megxuser;
-- GRANT SELECT, INSERT ON TABLE pfam.proteomes_subnetwork TO sge;

rollback;
--commit;
