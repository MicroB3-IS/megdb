
BEGIN;
SELECT _v.register_patch('00162-myosd-filters-table',
                          array['00159-myosd-samples-table','00161-myosd-insert-sample-func'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path to myosd;

CREATE TABLE myosd.filters (
  myosd_id integer REFERENCES myosd.samples (myosd_id),
  num integer check (num in (1,2)),
  filtration_time integer check (filtration_time >= 0),
  quantity integer check (quantity >= 0)
);
grant select on table myosd.filters to megxuser,megx_team;
grant update on table myosd.filters to megxuser,megx_team;

COMMENT ON TABLE myosd.filters is 'Filters from the sampling kit';
COMMENT ON COLUMN myosd.filters.filtration_time is 'Duration of filtering in minutes';
COMMENT ON COLUMN myosd.filters.quantity is 'Filters from the sampling kit';

/*
select raw_json ->> 'myosd_id' as myosd_id,
	        json_array_elements (raw_json #> '{filters}') as a,
		
                row_number() over() as row_num
           from myosd.samples;
	   --*/

INSERT into myosd.filters  
 select t.myosd_id::integer,
        row_number() over(partition by t.row_num),
	( ceil( (t.a ->> 'filtration_time')::numeric ) )::integer,
        (t.a ->> 'quantity')::integer
   from (
         select raw_json ->> 'myosd_id' as myosd_id,
	        json_array_elements (raw_json #> '{filters}') as a,
                row_number() over() as row_num
           from myosd.samples
   ) t
;

-- for some test queries as user megxuser
--SET ROLE megxuser;

--select * from myosd.filters;


commit;


