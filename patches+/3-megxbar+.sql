BEGIN;
SELECT _v.register_patch( '3-megxbar', ARRAY['1-partitioning'], NULL );
SET search_path TO core, cv, public;

ALTER TABLE core.articles ADD COLUMN date_published timestamptz;
ALTER TABLE core.articles ADD COLUMN date_res core.date_resolution;
UPDATE core.articles SET date_published = CAST(yr || '-' || mon || '-01' as timestamptz), date_res = 'month'::date_resolution;   
ALTER TABLE core.articles DROP COLUMN yr;
ALTER TABLE core.articles DROP COLUMN mon;

ROLLBACK;