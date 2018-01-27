
    begin;
    
    
    -- that's the integration part
    select 
           osdregistry.integrate_myosd_sample_submission (
                osdregistry.parse_myosd_sample_submission (
                    raw_json, id, version, submitted, modified
                ),
               'MyOSD-Jun-2015',
                23, -- new myosd id
                null, -- new lat
                null -- new lon
           )
     from osdregistry.osd_raw_samples where id = 688;
    
    select * from myosd.samples where myosd_id = 23;

    
    rollback;

