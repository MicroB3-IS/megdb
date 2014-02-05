BEGIN;

SELECT _v.register_patch('47-mg-traits-ddl', 
                          array[ '45-mg-traits-permission',
'44-auth-user-defaults' ] );

set search_path to mg_traits;

-- first adjust mg_traits schema

ALTER TABLE mg_traits.mg_traits_jobs 
  ADD COLUMN id SERIAL UNIQUE ;

-- select id from mg_traits_jobs limit 10;

-- droping dependent table FKs
ALTER TABLE "mg_traits_aa" 
  DROP CONSTRAINT "mg_traits_aa_sample_label_fkey";
ALTER  TABLE "mg_traits_dinuc" 
  DROP CONSTRAINT "mg_traits_dinuc_sample_label_fkey";
ALTER TABLE "mg_traits_pfam"
  DROP CONSTRAINT "mg_traits_pfam_sample_label_fkey";
ALTER TABLE "mg_traits_results"
  DROP CONSTRAINT "mg_traits_results_sample_label_fkey";

-- adding artificial key 
-- 1. aa
ALTER TABLE "mg_traits_aa" 
  ADD COLUMN id integer;

UPDATE mg_traits_aa a 
  SET id = j.id 
FROM mg_traits_jobs j
  WHERE a.sample_label = j.sample_label;

ALTER TABLE "mg_traits_aa" 
  ALTER COLUMN id SET NOT NULL,
  ADD CONSTRAINT jobs_fk FOREIGN KEY(id) REFERENCES mg_traits_jobs(id);
-- 2. dinuc
ALTER  TABLE "mg_traits_dinuc"
  ADD COLUMN id integer;

UPDATE mg_traits_dinuc d
  SET id = j.id 
FROM mg_traits_jobs j
  WHERE d.sample_label = j.sample_label;

ALTER  TABLE "mg_traits_dinuc"
  ALTER COLUMN id SET NOT NULL,
  ADD CONSTRAINT jobs_fk FOREIGN KEY(id) REFERENCES mg_traits_jobs(id);

-- 2. pfam
ALTER TABLE "mg_traits_pfam"
  ADD COLUMN id integer;

UPDATE mg_traits_pfam p
  SET id = j.id 
FROM mg_traits_jobs j
  WHERE p.sample_label = j.sample_label;

ALTER  TABLE "mg_traits_pfam"
  ALTER COLUMN id SET NOT NULL,
  ADD CONSTRAINT jobs_fk FOREIGN KEY(id) REFERENCES mg_traits_jobs(id);

-- 4. simple results
ALTER TABLE "mg_traits_results"
  ADD COLUMN id integer;

UPDATE mg_traits_results r
  SET id = j.id 
FROM mg_traits_jobs j
  WHERE r.sample_label = j.sample_label;

ALTER  TABLE "mg_traits_results"
  ALTER COLUMN id SET NOT NULL,
  ADD CONSTRAINT jobs_fk FOREIGN KEY(id) REFERENCES mg_traits_jobs(id);


-- changing jobs constraints 
ALTER TABLE mg_traits.mg_traits_jobs
  DROP CONSTRAINT mg_traits_jobs_sample_label_key;

-- changing PK
ALTER TABLE mg_traits.mg_traits_jobs
  DROP CONSTRAINT mg_traits_jobs_pkey;
ALTER TABLE mg_traits.mg_traits_jobs 
  ADD CONSTRAINT customer_sample_label_key PRIMARY KEY (customer,sample_label);

ALTER TABLE mg_traits_jobs
   ALTER COLUMN job_id SET DEFAULT 0,
  ADD CONSTRAINT job_id_chk CHECK ( job_id >= 0 ); 

ALTER TABLE mg_traits_jobs
   ALTER COLUMN cluster_node SET DEFAULT '';



commit;
