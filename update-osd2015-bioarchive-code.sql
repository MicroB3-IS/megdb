

begin;

update osdregistry.samples s
   set bioarchive_code = ex.si_barcode
  FROM osdregistry_stage.osd_2015_extraction ex
  
 where (ex.osd_id = s.osd_id 
        AND
        ( date_part('year', s.local_date) = '2015')
        AND
        (ex.depth::numeric = s.water_depth)
                 
           )
           and
      (ex.si_barcode IS not NULL      
           AND
           ex.osd_id != 11 
      )
    returning s.osd_id, s.submission_id, s.local_date, s.water_depth,s.bioarchive_code
      ;

commit;