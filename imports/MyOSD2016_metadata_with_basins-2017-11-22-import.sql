BEGIN;

CREATE TABLE osdregistry_stage.myosd2016_basins (

  myosd_id integer,
  label text,
  place_name text,
  start_lat numeric,
  start_lon numeric,
  River_basin_Sea text

);

\copy osdregistry_stage.myosd2016_basins FROM PROGRAM 'cat  MyOSD2016_metadata_basins.tsv | tr -d \r' (format csv, delimiter '	', header, force_not_null(label) )

commit;
