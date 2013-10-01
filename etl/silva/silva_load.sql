BEGIN;
INSERT INTO core.studies values ('silva','SILVA','http://www.arb-silva.de/','SILVA provides comprehensive, quality checked and regularly updated datasets of aligned small (16S/18S, SSU) and large subunit (23S/28S, LSU) ribosomal RNA (rRNA) sequences for all three domains of life (Bacteria, Archaea and Eukarya).');
insert into core.id_codes values ('silva','','','','',FALSE);
COMMIT;
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

INSERT INTO core.ribosomal_sequences (sequence, size, gc, data_source, retrieved, project, own, did, did_auth, mol_type, acc_ver, isolate_id, gpid, center, status, seq_platform, seq_approach, seq_method, study, sample_name, isolate_name, estimated_error_rate, calculation_method)
  SELECT sequence::dna_sequence, size, gc, data_source, retrieved, project, own, did, did_auth, mol_type, acc_ver, isolate_id, gpid, center, status, seq_platform, seq_approach, seq_method, study, sample_name, isolate_name, estimated_error_rate, calculation_method FROM silva.ribosomal_sequences_mat WHERE NOT EXISTS (
    SELECT 1 FROM core.ribosomal_sequences WHERE did = silva.ribosomal_sequences_mat.did AND did_auth = silva.ribosomal_sequences_mat.did_auth
  )
;

INSERT INTO core.sample_measures (sid, material, param, unit, vals, mcode, conducted, conducted_res, device, project, own, min, max, std, meas_tot, study, sample_name)
  SELECT sid, material, param, unit, vals, mcode, conducted, conducted_res, device, project, own, min, max, std, meas_tot, study, sample_name FROM silva.sample_measures_mat WHERE NOT EXISTS (
    SELECT 1 FROM core.sample_measures WHERE sample_name = silva.sample_measures_mat.sample_name
  )
;
 
ROLLBACK; 