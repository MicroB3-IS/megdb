
BEGIN;
SELECT _v.register_patch('00122-osdregistry-controlled-vocab-fix',
                          array['00121-ena_run_sample_mapping'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

insert into osdregistry.sequencing_centers 
  VALUES ('lgc'),('ramaciotti-gc');

insert into osdregistry.processing_categories
  VALUES ('raw'),('workable');


delete from osdregistry.dataset_categories;
insert into osdregistry.dataset_categories
  VALUES ('shotgun'),('16S'),('18S');

-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


