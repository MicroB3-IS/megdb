
BEGIN;
SELECT _v.register_patch('00112-osdregistry-filter-grant',
                          array['00111-osdregistru-delete-func'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


GRANT UPDATE ( 
 filtration_time,
 quantity,
 container,
 content,
 size_fraction_lower_threshold,
 size_fraction_upper_threshold,
 treatment_chemicals,
 treatment_storage,
 curator,
 curation_remark
)
ON osdregistry.filters TO megx_team;





-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


