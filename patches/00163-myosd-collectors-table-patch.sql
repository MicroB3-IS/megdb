
BEGIN;
SELECT _v.register_patch('00163-myosd-collectors-table',
                          array['00162-myosd-filters-table'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


SET search_path to myosd;

CREATE TABLE myosd.collectors (
  myosd_id integer REFERENCES samples(myosd_id),
  num integer not null check (num > 0),
  first_name text not null default '',
  last_name text not null default '',
  email text not null default ''
);
grant select on table myosd.collectors to megxuser,megx_team;
grant update on table myosd.collectors to megxuser,megx_team;

COMMENT ON TABLE myosd.collectors is 'Collectors of MyOSD samples';
COMMENT ON COLUMN myosd.collectors.num  is 'Order appearing on MyOSD log-sheet';

insert into myosd.collectors (myosd_id, first_name, last_name, email, num)

select (raw_json ->> 'myosd_id')::integer as myosd_id,
       trim ( (raw_json #> '{contact}') ->> 'first_name' ) as first_name,
       trim( raw_json #> '{contact}' ->> 'last_name' ) as last_name,
       trim ( raw_json #> '{contact}' ->> 'email' ) as email,
       1::integer as row_num
  from myosd.samples

union all

select t.myosd_id::integer,
       trim( t.p ->> 'first_name' ) as first_name,
       coalesce ( trim( t.p ->> 'last_name' ), '' ) as last_name,
       coalesce ( trim( t.p ->> 'email' ), '' ) as email,
       1 + row_number() over(partition by row_num) as row_num
  from (
        select raw_json ->> 'myosd_id' as myosd_id,
               json_array_elements (raw_json #> '{participants}') as p,
               row_number() over() as row_num
          from myosd.samples
         where ( raw_json #> '{participants}'->1) is not null
   ) t
 where (t.p ->> 'first_name') is not null

order by myosd_id, row_num
;


-- for some test queries as user megxuser
-- SET ROLE megxuser;

--select '=' || last_name || '=' from myosd.collectors where last_name !~ '^[[:alnum:]][[:alnum:] -]*$';

commit;


