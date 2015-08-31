
BEGIN;
SELECT _v.register_patch('00121-ena_run_sample_mapping',
                          array['00120-osdregistry-local_end_time_fix'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;



CREATE view osdregistry.ena_sample_run_mappings AS
select 
   osd_id,
   acc as ena_run_accession, 
   osdregistry.osd_sample_label(
      sam.osd_id::text, sam.local_date::text, 
      sam.water_depth::text, sam.protocol
   ) as sample_label,
   ena_acc as ena_sample_accession
 from osdregistry.ena_runs run
left join osdregistry.samples sam on ( (substring(alias_label from '\d+$')::integer ) = sam.submission_id)
 ;

GRANT select on osdregistry.ena_sample_run_mappings to megx_team;

-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


