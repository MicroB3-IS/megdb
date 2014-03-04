Begin;

SELECT _v.register_patch('55-add-mg-traits-pca-table',
                          array[ '54-rename-col-taxonomy-table'] );

set search_path to mg_traits;

CREATE TABLE traits_cv (
  term text NOT NULL DEFAULT ''::text PRIMARY KEY,
  descr text NOT NULL DEFAULT ''::text,
  intro text NOT NULL DEFAULT ''::text
);

COMMENT ON table traits_cv IS 'A controlled list of trait names to be used in mg-traits applications';


REVOKE ALL ON traits_cv FROM PUBLIC;

ALTER TABLE traits_cv OWNER TO megdb_admin;

GRANT SELECT ON TABLE traits_cv TO selectors;
GRANT SELECT ON TABLE traits_cv TO megxuser;



CREATE TABLE mg_traits_pca (
  id integer NOT NULL REFERENCES mg_traits_jobs(id),
  trait text NOT NULL REFERENCES traits_cv(term),
  x numeric NOT NULL,
  y numeric NOT NULL,
  PRIMARY KEY (id,trait)
);

COMMENT ON TABLE mg_traits_pca IS 'Principal Component Analysis of each trait per sample calculated based on all sample in the database before before and including this sample.';

REVOKE ALL ON mg_traits_pca FROM PUBLIC;

ALTER TABLE mg_traits_pca OWNER TO megdb_admin;
GRANT ALL ON TABLE mg_traits_pca TO megdb_admin;
GRANT SELECT ON TABLE mg_traits_pca TO selectors;
GRANT INSERT ON TABLE mg_traits_pca TO sge;
GRANT SELECT ON TABLE mg_traits_pca TO megxuser;



commit;
