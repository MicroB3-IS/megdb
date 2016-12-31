
BEGIN;

--/*
CREATE VIEW mg_traits.osd_kingdoms AS
WITH mg_tax AS ( 
   SELECT jobs.sample_name, 
          (each(taxonomy_raw)).key as tax, 
          (each(taxonomy_raw)).value as num, 
          split_part( (each(taxonomy_raw)).key, ';', 1) as kingdom 
    FROM  mg_traits.mg_traits_taxonomy as tax
          INNER JOIN
          mg_traits.mg_traits_jobs as jobs
          ON (tax.id = jobs.id )
   WHERE jobs.sample_label ilike 'OSD%'
     AND jobs.make_public = '0'::interval 
)
select sample_name, kingdom, sum(num::integer) from mg_tax group by sample_name,kingdom 

;
\copy (select * from  mg_traits.osd_kingdoms) TO '/home/renzo/src/megdb/reports/osd2014-mg-kingdom-counts.csv' CSV;

CREATE VIEW mg_traits.osd_taxa AS
WITH mg_tax AS ( 
   SELECT jobs.sample_name, 
          (each(taxonomy_raw)).key as tax, 
          (each(taxonomy_raw)).value as num

    FROM  mg_traits.mg_traits_taxonomy as tax
          INNER JOIN
          mg_traits.mg_traits_jobs as jobs
          ON (tax.id = jobs.id )
   WHERE jobs.sample_label ilike 'OSD%'
     AND jobs.make_public = '0'::interval 
)
select sample_name, tax, sum(num::integer) from mg_tax group by sample_name, tax 
;


\copy (select * from  mg_traits.osd_taxa) TO '/home/renzo/src/megdb/reports/osd2014-mg-taxa-counts.csv' CSV;

--*/
/*
CREATE MATERIALIZED VIEW mg_traits.osd_function_assignments AS
WITH mg_tax AS ( 
   SELECT jobs.sample_name, 
          (each(functional)).key as tax,
          (each(functional)).value as num

     FROM mg_traits.mg_traits_functional as tax
          INNER JOIN
          mg_traits.mg_traits_jobs as jobs
          ON (tax.id = jobs.id )
   WHERE jobs.sample_label ilike 'OSD%'
     AND jobs.make_public = '0'::interval 
)
select sample_name, tax, sum(num::integer) from mg_tax group by sample_name, tax 
;


\copy (select * from mg_traits.osd_function_assignments) TO '/home/renzo/src/megdb/reports/osd2014-mg-function-counts.csv' CSV;
--*/

rollback;