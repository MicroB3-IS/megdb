
BEGIN;

SELECT _v.register_patch( '10-improve-samples-studies', ARRAY['9-improve-article-table'], NULL );

set client_encoding = 'UTF8';

INSERT INTO core.studies(
            label, full_name)
    VALUES ('unknown', 'nothing is known about the study at the time the entry was created'),
            ('metagenome', 'an anonymous metagenome study')
    ;


ALTER TABLE core.samples
   ALTER COLUMN study SET DEFAULT 'unknown'::text;
COMMENT ON COLUMN core.samples.study IS 'the study this sample primarily belongs to';

ALTER TABLE core.samples DROP CONSTRAINT samples_own_fkey;
ALTER TABLE core.samples DROP CONSTRAINT samples_project_fkey;


commit;