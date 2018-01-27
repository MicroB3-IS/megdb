
BEGIN;

update osdregistry.samples 
  SET bioarchive_code = regexp_replace( bioarchive_code, '^ABO', 'AB0') 
where bioarchive_code ~ '^ABO' 

returning bioarchive_code;   


commit;