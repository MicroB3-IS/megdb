
BEGIN;
SELECT _v.register_patch('00157-esa-myosd-patch',
                          array['00156-myosd-perm-ongsheet-view'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


ALTER TABLE esa.samples
  ADD COLUMN sampling_kit boolean NOT NULL DEFAULT false,
  ADD COLUMN myosd_number numeric NOT NULL DEFAULT 0,
  ADD COLUMN filter_one numeric NOT NULL DEFAULT 'NaN'::numeric,
  ADD COLUMN filter_two numeric NOT NULL DEFAULT 'NaN'::numeric;

-- for some test queries as user megxuser
-- SET ROLE megxuser;

--\d esa.samples


commit;


