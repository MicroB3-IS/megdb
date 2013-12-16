BEGIN;

SELECT _v.register_patch( '42-ena-samples-stage', ARRAY['42-parse-ena-latlon'], NULL );

CREATE TABLE stage_r8.ena_samples (
  accession text PRIMARY KEY,
  bio_material text,
  collected_by text,
  collection_date text,
  country text, 
  isolation_source text,
  location text
);



COPY  stage_r8.ena_samples FROM PROGRAM 'curl -s ''http://www.ebi.ac.uk/ena/data/warehouse/search?query=&result=sample&fields=accession,bio_material,collected_by,collection_date,country,isolation_source,location&display=report'' | sed 1d | cut -f1-7'  FREEZE ;

SELECT AddGeometryColumn('stage_r8','ena_samples', 'geom', 4326, 'POINT', 2);

UPDATE stage_r8.ena_samples SET geom =  core.parse_ena_latlon(location, 4326);

commit;
