
Begin;

--drop table iso_src_envo, gi_isolation_source;

CREATE TABLE gi (
  id bigint PRIMARY KEY,
  prok boolean NOT NULL
);


CREATE TABLE iso_src_envo (
  src text PRIMARY KEY default '' ,
  biome  text REFERENCES envo.terms(term),
  feature text REFERENCES envo.terms(term),
  material text REFERENCES envo.terms(term),
  biome_ext  text REFERENCES envo.terms(term),
  feature_ext text REFERENCES envo.terms(term),
  material_ext text REFERENCES envo.terms(term)
);

CREATE TABLE gi_isolation_source (
  gi bigint REFERENCES gi(id),
  src text REFERENCES iso_src_envo(src),
  PRIMARY KEY(gi,src)
);


commit;
