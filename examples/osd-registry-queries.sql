-- give me all institues where part of name is mpi
select raw_json #>> '{contact, institute}' from osdregistry.osd_raw_samples where (raw_json #>> '{contact, institute}') ilike '%mpi%';

-- jsut all raw with last submitted first
select * from osdregistry.osd_raw_samples order by submitted desc;


-- give me institie and site id last submited first
select submitted, raw_json #>> '{contact, institute}', raw_json #>> '{sampling_site, site_id}' from osdregistry.osd_raw_samples order by submitted desc;

-- give me data, last submmited first
select submitted, -- date submitted 
       raw_json #>> '{contact, institute}', --from which institute 
       raw_json #>> '{sampling_site, site_id}' as osd_id,
       raw_json #>> '{sample, label}' as sample_label,
       raw_json #>> '{sampling_site}',
       raw_json #>> '{comment}' -- was there addtional comment
  from osdregistry.osd_raw_samples order by submitted desc;
