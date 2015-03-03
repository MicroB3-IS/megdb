
BEGIN;
SELECT _v.register_patch('00115-osdregistry-ena-management',
                          array['00114-osdregistry-samples-delete-dups'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


-- for some test queries as user megxuser
-- SET ROLE megxuser;

SET search_path to osdregistry,public;


select osdregistry.deletesample( f.i ) 
  FROM (values (187),(171) ) as f(i);  



CREATE OR REPLACE FUNCTION osdregistry.osd_sample_label (
     osd_id text, 
     local_date text,
     water_depth text,
     protocol text,
     dataset_type text) 
  RETURNS text AS $$
   SELECT 'OSD' || osd_id || '_' 
             || local_date || '_'
             || water_depth::text || 'm_'
             || protocol::text || '_'
             || dataset_type
         ;    
$$ LANGUAGE SQL; 


CREATE OR REPLACE FUNCTION osdregistry.osd_sample_label (
     osd_id text, 
     local_date text,
     water_depth text,
     protocol text) 
  RETURNS text AS $$
   SELECT 'OSD' || osd_id || '_' 
             || local_date || '_'
             || water_depth::text || 'm_'
             || protocol::text
         ;    
$$ LANGUAGE SQL; 


CREATE TABLE iho_tagging (
  submission_id integer PRIMARY KEY REFERENCES samples(submission_id),
  osd_id integer REFERENCES sites(id),
  iho_label text,
  iho_id text,
  mrgid integer,
  distance_degrees double precision 
);


INSERT INTO iho_tagging (submission_id, osd_id, iho_label, iho_id, mrgid, distance_degrees)
WITH iho AS (
SELECT DISTINCT ON (submission_id)
    submission_id,
    osd_id,
    iho.label as iho_label,
    iho.id as iho_id,
    iho.gazetteer as mrgid,
  --ST_AsText(
    ---st_closestpoint(iho.geom, osd.start_geom)
  --) as point_on_iho,
   ST_Distance(iho.geom, osd.start_geom) as dist

  FROM
     -- lines/polygones
     marine_regions_stage.iho AS iho
  INNER JOIN
     -- points
     osdregistry.samples osd
  ON
    (ST_DWithin(osd.start_geom,iho.geom, 1))
ORDER BY
 submission_id, ST_Distance(osd.start_geom, iho.geom) 

)
select * from iho order by dist desc
;
--*/

CREATE TABLE dataset_categories (
  label text PRIMARY KEY,
  descr text NOT NULL DEFAULT ''
);
INSERT INTO dataset_categories VALUES ('16S'),('18S'),('shotgun');


CREATE TABLE processing_categories (
  label text PRIMARY KEY,
  descr text NOT NULL DEFAULT ''
);
INSERT INTO dataset_categories VALUES ('raw'),('workable');


CREATE TABLE sequencing_centers (
  label text PRIMARY KEY,
  descr text NOT NULL DEFAULT ''
);
INSERT INTO dataset_categories VALUES ('lgc'),('ramaciotti-gc'),('lifewatch-italy');


CREATE TABLE ena_submissions (
  acc text NOT NULL PRIMARY KEY,
  alias_label text NOT NULL,
  submission_file text NOT NULL,
  receipt_date text NOT NULL,
  created timestamp NOT NULL DEFAULT NOW()
);


CREATE TABLE ena_experiments (
  submission  text NOT NULL REFERENCES ena_submissions(acc),
  acc text NOT NULL PRIMARY KEY,
  alias_label text NOT NULL,
  created timestamp NOT NULL DEFAULT NOW()
);



CREATE TABLE ena_runs (
  submission  text NOT NULL REFERENCES ena_submissions(acc),
  acc text NOT NULL PRIMARY KEY,
  alias_label text NOT NULL,
  created timestamp NOT NULL DEFAULT NOW()
);


CREATE TABLE ena_datafiles (
  file_name text CHECK (file_name ~ '^OSD') PRIMARY KEY,
  md5 text UNIQUE,
  full_path text UNIQUE CHECK (full_path ~ '/bioinf/projects/osd/main')
);

CREATE TABLE ena_datasets (
  sample_id integer REFERENCES samples (submission_id),
  file_name_prefix text check (file_name_prefix ~ '^OSD') PRIMARY KEY,
  osd_id integer,
  sequencing_center text NOT NULL REFERENCES sequencing_centers(label) ON UPDATE CASCADE,
  cat text NOT NULL REFERENCES dataset_categories(label) ON UPDATE CASCADE,
  processing_status text NOT NULL REFERENCES processing_categories(label) ON UPDATE CASCADE,
  create_time timestamp NOT NULL DEFAULT now()

);

ALTER TABLE osdregistry.samples
  ADD COLUMN bioarchive_code text NOT NULL DEFAULT '';

ALTER TABLE osdregistry.samples
  ADD COLUMN ena_acc text NOT NULL DEFAULT '';

ALTER TABLE osdregistry.samples
  ADD COLUMN biosample_acc text NOT NULL DEFAULT '';

--select submission_id, osd_id, ena_acc, biosample_acc from osdregistry.samples

commit;


