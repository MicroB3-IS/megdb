--reduce partitions schema
--delete metagenomic samples except for GS044;
BEGIN;
CREATE OR REPLACE VIEW core.mg_dnas as select * from core.metagenomic_sequences_template;
create or replace function core.delete_mg_partition(next_id int) returns int as $$
  BEGIN
    EXECUTE 'drop table partitions.sample_' || next_id || ';';
    EXECUTE 'delete from core.metagenomic_partitions where partition_id  = ' ||
      next_id || ';';
    return next_id;
  END;
$$ language plpgsql;
select core.delete_mg_partition(partition_id) from core.metagenomic_partitions where sample_name != 'GS044';
drop function core.delete_mg_partition(int);
select core.rebuild_mg_view();
COMMIT;

--delete pooled metagenomic samples except for GS000a
BEGIN;
CREATE OR REPLACE VIEW core.mg_pooled_dnas as select * from core.pooled_metagenomic_sequences_template;
create or replace function core.delete_pooled_mg_partition(next_id int) returns int as $$
  BEGIN
    EXECUTE 'drop table partitions.pool_' || next_id || ';';
    EXECUTE 'delete from core.pooled_metagenomic_partitions where partition_id  = ' ||
      next_id || ';';
    return next_id;
  END;
$$ language plpgsql;
select core.delete_pooled_mg_partition(partition_id) from core.pooled_metagenomic_partitions where pool_label != 'GS000b';
drop function core.delete_pooled_mg_partition(int);
select core.rebuild_pooled_mg_view();
COMMIT;

--reduce core schema
--delete genomic sequences except for NC_006365
BEGIN;
DELETE FROM core.genomic_sequences WHERE did != 'NC_006365';
DELETE FROM core.dna_regions WHERE rid != '54295844';
DELETE FROM core.blast_hits;
DELETE FROM core.ncbi_tax_nodes where tax_id != 218505;
DELETE FROM core.ncbi_tax_names where tax_id != 218505;
COMMIT;



--delete 
BEGIN;
DELETE FROM elayers.woa05_nitrate_stability;
DELETE FROM elayers.woa05_phosphate_stability;
DELETE FROM elayers.woa05_silicate_stability;
DELETE FROM elayers.woa05_oxygen_dissolved_stability;
DELETE FROM elayers.woa05_oxygen_utilization_stability;
DELETE FROM elayers.woa05_oxygen_saturation_stability;
DELETE FROM elayers.woa05_salinity_stability;
DELETE FROM elayers.woa05_temperature_stability;
DELETE FROM elayers.chlorophyll;
DELETE FROM elayers.woa05_nitrate;
DELETE FROM elayers.woa05_phosphate;
DELETE FROM elayers.woa05_silicate;
DELETE FROM elayers.woa05_oxygen_utilization;
DELETE FROM elayers.woa05_oxygen_dissolved;
DELETE FROM elayers.woa05_oxygen_saturation;
DELETE FROM elayers.woa05_salinity;
DELETE FROM elayers.wod05_osd_all;
DELETE FROM elayers.woa05_temperature;
COMMIT;

BEGIN;
DELETE FROM silva_r102_ssu.straininfo WHERE primaryaccession != 'A16379';
DELETE FROM silva_r102_ssu.taxmap WHERE primaryaccession != 'A16379';
DELETE FROM silva_r102_ssu.taxmap WHERE node_id != 2238;
ALTER TABLE silva_r102_ssu.taxmap DROP CONSTRAINT taxmap_node_id_fkey;
DELETE FROM silva_r102_ssu.taxonomy WHERE node_id != 2238;
ALTER TABLE silva_r102_ssu.taxmap ADD CONSTRAINT taxmap_node_id_fkey FOREIGN KEY (node_id)
      REFERENCES silva_r102_ssu.taxonomy (node_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
DELETE FROM silva_r102_ssu.region WHERE primaryaccession != 'A16379';
DELETE FROM silva_r102_ssu.publication WHERE primaryaccession != 'A16379';
ALTER TABLE silva_r102_ssu.publication DROP CONSTRAINT publication_primaryaccession_fkey;
ALTER TABLE silva_r102_ssu.region DROP CONSTRAINT region_primaryaccession_fkey;
ALTER TABLE silva_r102_ssu.taxmap DROP CONSTRAINT taxmap_primaryaccession_fkey;
DELETE FROM silva_r102_ssu.sequenceentry WHERE primaryaccession != 'A16379';
ALTER TABLE silva_r102_ssu.taxmap ADD CONSTRAINT taxmap_primaryaccession_fkey FOREIGN KEY (primaryaccession)
      REFERENCES silva_r102_ssu.sequenceentry (primaryaccession) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE silva_r102_ssu.region ADD CONSTRAINT region_primaryaccession_fkey FOREIGN KEY (primaryaccession)
      REFERENCES silva_r102_ssu.sequenceentry (primaryaccession) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE silva_r102_ssu.publication ADD CONSTRAINT publication_primaryaccession_fkey FOREIGN KEY (primaryaccession)
      REFERENCES silva_r102_ssu.sequenceentry (primaryaccession) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
COMMIT;

BEGIN;
DELETE FROM silva_r102_lsu.straininfo WHERE si_accession != 'A82710';
DELETE FROM silva_r102_lsu.taxmap WHERE primaryaccession != 'A82710';
DELETE FROM silva_r102_lsu.taxmap WHERE node_id != 1025;
ALTER TABLE silva_r102_lsu.taxmap DROP CONSTRAINT taxmap_taxname_fkey;
DELETE FROM silva_r102_lsu.taxonomy WHERE node_id != 1025;
ALTER TABLE silva_r102_lsu.taxmap ADD CONSTRAINT taxmap_taxname_fkey FOREIGN KEY (taxname, path)
      REFERENCES silva_r102_lsu.taxonomy (taxname, path) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
DELETE FROM silva_r102_lsu.region WHERE primaryaccession != 'A82710';
DELETE FROM silva_r102_lsu.publication WHERE primaryaccession != 'A82710';
ALTER TABLE silva_r102_lsu.publication DROP CONSTRAINT publication_primaryaccession_fkey;
ALTER TABLE silva_r102_lsu.region DROP CONSTRAINT region_primaryaccession_fkey;
ALTER TABLE silva_r102_lsu.taxmap DROP CONSTRAINT taxmap_primaryaccession_fkey;
DELETE FROM silva_r102_lsu.sequenceentry WHERE primaryaccession != 'A82710';
ALTER TABLE silva_r102_lsu.taxmap ADD CONSTRAINT taxmap_primaryaccession_fkey FOREIGN KEY (primaryaccession)
      REFERENCES silva_r102_lsu.sequenceentry (primaryaccession) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE silva_r102_lsu.region ADD CONSTRAINT region_primaryaccession_fkey FOREIGN KEY (primaryaccession)
      REFERENCES silva_r102_lsu.sequenceentry (primaryaccession) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE silva_r102_lsu.publication ADD CONSTRAINT publication_primaryaccession_fkey FOREIGN KEY (primaryaccession)
      REFERENCES silva_r102_lsu.sequenceentry (primaryaccession) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
COMMIT;


