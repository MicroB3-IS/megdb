Begin;

SELECT _v.register_patch('62-mg-traits-jobs-extra-columns',
                          array['61-unknown-blast'] );

--Remove .fasta from sample names
UPDATE mg_traits.mg_traits_jobs SET sample_label = rtrim(sample_label, '.fasta');


--Add extra columns to mg_traits.mg_traits_jobs
ALTER TABLE mg_traits.mg_traits_jobs ADD COLUMN sample_description text NOT NULL DEFAULT '';
ALTER TABLE mg_traits.mg_traits_jobs ADD COLUMN sample_name text NOT NULL DEFAULT '';
ALTER TABLE mg_traits.mg_traits_jobs ADD COLUMN sample_site_description text NOT NULL DEFAULT '';
ALTER TABLE mg_traits.mg_traits_jobs ADD COLUMN sample_latitude double precision NOT NULL DEFAULT 0;
ALTER TABLE mg_traits.mg_traits_jobs ADD COLUMN sample_longitude double precision NOT NULL DEFAULT 0;
ALTER TABLE mg_traits.mg_traits_jobs ADD CONSTRAINT sample_latitude_check CHECK (sample_latitude >= (-90)::double precision AND sample_latitude <= 90::double precision);
ALTER TABLE mg_traits.mg_traits_jobs ADD CONSTRAINT sample_longitude_check CHECK (sample_longitude >= (-180)::double precision AND sample_longitude <= 180::double precision);

commit;
