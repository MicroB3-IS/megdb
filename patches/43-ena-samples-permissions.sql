BEGIN;

SELECT _v.register_patch( '43-ena-samples-permissions', ARRAY['42-ena-samples-stage'], NULL );

GRANT select ON TABLE stage_r8.ena_samples to megxuser;


commit;
