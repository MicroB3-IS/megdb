begin;


ALTER TABLE myosd.samples drop constraint     samples_salinity_check;

ALTER TABLE myosd.samples ADD constraint samples_salinity_check  CHECK (salinity >= -1::numeric);



commit;
