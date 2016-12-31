-- example started(ing) job
-- customer as by authorization or anonymous

--  OSD10
--  OSD15-surf
--  OSD21
-- OSD20-iceland
--  OSD20-20m-depth

-- 00

begin;
INSERT INTO mg_traits.mg_traits_jobs (
    customer, mg_url, sample_label, sample_environment
  ) 
  VALUES (
    'renzo', 
    'file:///bioinf/projects/osd/main/2014/06/analysis-results/mg-traits/input/OSD152-5m-depth.comb.qc.masked.dedup.fasta',
    'OSD152-5m-depth', 'marine'
) RETURNING id;

commit;

/*
select pg_sleep(5);

INSERT INTO mg_traits.mg_traits_jobs (
    customer, mg_url, sample_label, sample_environment
  ) 
  VALUES (
    'renzo', 
    'file:///bioinf/projects/osd/main/2014/06/analysis-results/mg-traits/input/OSD15-surf.comb.qc.masked.dedup.fasta',
    'OSD15-surf', 'marine'
) RETURNING id;

select pg_sleep(5);

INSERT INTO mg_traits.mg_traits_jobs (
    customer, mg_url, sample_label, sample_environment
  ) 
  VALUES (
    'renzo', 
    'file:///bioinf/projects/osd/main/2014/06/analysis-results/mg-traits/input/OSD21.comb.qc.masked.dedup.fasta',
    'OSD21', 'marine'
) RETURNING id;

select pg_sleep(5);

INSERT INTO mg_traits.mg_traits_jobs (
    customer, mg_url, sample_label, sample_environment
  ) 
  VALUES (
    'renzo', 
    'file:///bioinf/projects/osd/main/2014/06/analysis-results/mg-traits/input/OSD20-20m-depth.comb.qc.masked.dedup.fasta',
    'OSD20-20m-depth', 'marine'
) RETURNING id;

select pg_sleep(5);

INSERT INTO mg_traits.mg_traits_jobs (
    customer, mg_url, sample_label, sample_environment
  ) 
  VALUES (
    'renzo', 
    'file:///bioinf/projects/osd/main/2014/06/analysis-results/mg-traits/input/OSD20-iceland.comb.qc.masked.dedup.fasta',
    'OSD20-iceland', 'marine'
) RETURNING id;



commit;
--*/