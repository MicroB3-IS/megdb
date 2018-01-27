BEGIN;

set search_path = osdregistry_stage;


CREATE TABLE osdregistry_stage.osd_2015_extraction (

osd_id integer,
site_name text,
number_filters integer,
received text,
remarks text,
rnalater_brand text,
filter_used text,
dna_conc text,
volume_approx text,
depth text,
depth_logsheet text,
remarks_extraction text,
sample_name_lgc text,
si_barcode text,
metadata_submission text

);

-- only interested in specific columsn and lines 
\copy osdregistry_stage.osd_2015_extraction FROM PROGRAM 'cut -f 1,2,6,7,10,11,12,13,14,15,16,18,19,20,21  osd-2015-extraction.tsv | sed -n 2,153p' (format csv, delimiter '	' )


commit;
