INSERT INTO core.studies values ('silva','SILVA','http://www.arb-silva.de/','SILVA provides comprehensive, quality checked and regularly updated datasets of aligned small (16S/18S, SSU) and large subunit (23S/28S, LSU) ribosomal RNA (rRNA) sequences for all three domains of life (Bacteria, Archaea and Eukarya).');

BEGIN;

INSERT INTO core.samplingsites (label, locdesc, locshortdesc, max_uncertain, loc_estim, region, project, own, old_geom, verb_coords, verb_coord_sys, verification, georef_validation, georef_prot, georef_source, spatial_fit, georef_by, georef_time, georef_remark, geom)
  SELECT * FROM silva.samplingsites_mat WHERE NOT EXISTS (
    SELECT 1 FROM core.samplingsites WHERE geom = silva.samplingsites_mat.geom AND max_uncertain = silva.samplingsites_mat.max_uncertain
  )
;

INSERT INTO core.samples (sid, max_uncertain, date_taken, date_res, label, material, habitat, hab_lite, country, project, own, old_geom, study, pool, geom, device, biome, feature, attr)
  SELECT * FROM silva.samples_mat WHERE NOT EXISTS (
    SELECT 1 FROM core.samples WHERE study = silva.samples_mat.study AND label = silva.samples_mat.label
  )
;

INSERT INTO core.ribosomal_sequences 
  SELECT * FROM silva.ribosomal_sequences_mat WHERE NOT EXISTS (
    SELECT 1 FROM core.ribosomal_sequences WHERE did = silva.ribosomal_sequences_mat.did AND did_auth = silva.ribosomal_sequences_mat.did_auth
  )
;

INSERT INTO core.sample_measures 
  SELECT * FROM silva.sample_measures_mat WHERE NOT EXISTS (
    SELECT 1 FROM core.sample_measures WHERE sample_name = silva.sample_measures_mat.sample_name
  )
;
 
ROLLBACK; 