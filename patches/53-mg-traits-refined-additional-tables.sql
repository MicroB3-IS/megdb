Begin;

SELECT _v.register_patch('53-mg-traits-refined-additional-tables',
                          array[ '52-mg-traits-jobs-insert-permission'] );


CREATE DOMAIN codon_relative 
  AS numeric DEFAULT 'NaN' NOT NULL check ( VALUE BETWEEN 0 and 1 );

-- Table for codon
CREATE TABLE mg_traits.mg_traits_codon (
id integer NOT NULL,
sample_label text NOT NULL,

GCC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GCG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GCT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TGC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TGT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GAC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GAT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GAA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GAG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TTC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TTT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GGA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GGC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GGG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GGT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CAC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CAT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
ATA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
ATC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
ATT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
AAA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
AAG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CTA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CTC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CTG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CTT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TTA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TTG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
ATG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
AAC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
AAT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CCA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CCC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CCG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CCT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CAA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CAG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
AGA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
AGG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CGA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CGC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CGG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
CGT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
AGC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
AGT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TCA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TCC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TCG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TCT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
ACA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
ACC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
ACG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
ACT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GTA codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GTC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GTG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
GTT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TGG codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TAC codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,
TAT codon_relative NOT NULL DEFAULT 'NaN'::codon_relative,

 CONSTRAINT mg_traits_codon_pkey PRIMARY KEY (id),

 CONSTRAINT jobs_fk FOREIGN KEY (id)
     REFERENCES mg_traits.mg_traits_jobs (id)
     ON DELETE CASCADE
);
REVOKE ALL ON mg_traits.mg_traits_codon FROM PUBLIC;

ALTER TABLE mg_traits.mg_traits_codon OWNER TO megdb_admin;
GRANT ALL ON TABLE mg_traits.mg_traits_codon TO megdb_admin;

GRANT SELECT ON TABLE mg_traits.mg_traits_codon TO selectors;
GRANT insert ON TABLE mg_traits.mg_traits_codon TO sge;
GRANT SELECT ON TABLE mg_traits.mg_traits_codon TO megxuser;


-- Table for functional

CREATE TABLE mg_traits.mg_traits_functional
(
  id integer NOT NULL,
  sample_label text NOT NULL,
  functional hstore NOT NULL,

  CONSTRAINT mg_traits_fucntional_pkey PRIMARY KEY (id),
  
  CONSTRAINT jobs_fk FOREIGN KEY (id)
      REFERENCES mg_traits.mg_traits_jobs (id) 
      ON DELETE CASCADE
);
REVOKE ALL ON mg_traits.mg_traits_functional FROM PUBLIC;

ALTER TABLE mg_traits.mg_traits_functional OWNER TO megdb_admin;
GRANT ALL ON TABLE mg_traits.mg_traits_functional TO megdb_admin;

GRANT SELECT ON TABLE mg_traits.mg_traits_functional TO selectors;
GRANT INSERT ON TABLE mg_traits.mg_traits_functional TO sge;
GRANT SELECT ON TABLE mg_traits.mg_traits_functional TO megxuser;


-- Table for taxonomy

CREATE TABLE mg_traits.mg_traits_taxonomy
(
  id integer NOT NULL,
  sample_label text NOT NULL,
  taxonomy_group hstore NOT NULL,
  taxonomy_raw hstore NOT NULL,

  CONSTRAINT mg_traits_taxonomy_pkey PRIMARY KEY (id),
  CONSTRAINT jobs_fk FOREIGN KEY (id)
      REFERENCES mg_traits.mg_traits_jobs (id)
      ON DELETE CASCADE
);
REVOKE ALL ON mg_traits.mg_traits_taxonomy FROM PUBLIC;

ALTER TABLE mg_traits.mg_traits_taxonomy OWNER TO megdb_admin;
GRANT ALL ON TABLE mg_traits.mg_traits_taxonomy TO megdb_admin;
GRANT SELECT ON TABLE mg_traits.mg_traits_taxonomy TO selectors;
GRANT INSERT ON TABLE mg_traits.mg_traits_taxonomy TO sge;
GRANT SELECT ON TABLE mg_traits.mg_traits_taxonomy TO megxuser;

commit;
