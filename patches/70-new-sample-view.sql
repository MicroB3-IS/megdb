
BEGIN;
SELECT _v.register_patch('70-new-sample-view',
                          array['69-move-sample-view'] );



ALTER VIEW web_r7.gms_samples OWNER TO megdb_admin;
ALTER VIEW web_r7.gms_samples SET SCHEMA web_r8;


CREATE OR REPLACE VIEW web_r8.samples AS 
        (        (         SELECT g.sid, 
                            g.geom, 
                            g.site_name, 
                            g.lat, 
                            g.lon, 
                            g.latlon, 
                            g.depth, 
                            g.date_taken, 
                            g.hab_lite, 
                            g.hab_uri, 
                            g.study_type, 
                            g.entity_name, 
                            g.entity_url, 
                            g.entity_country, 
                            g.entity_iho, 
                            g.entity_region, 
                            g.entity_descr, 
                            g.temperature, 
                            g.salinity, 
                            g.oxygen, 
                            g.chlorophyll
                           FROM web_r8.genomes g
                UNION 
                         SELECT silva.sid, 
                            silva.geom, 
                            silva.site_name, 
                            silva.lat, 
                            silva.lon, 
                            silva.latlon, 
                            silva.depth, 
                            silva.date_taken, 
                            silva.hab_lite, 
                            silva.hab_uri, 
                            silva.study_type, 
                            silva.entity_name, 
                            silva.entity_url, 
                            silva.entity_country, 
                            silva.entity_iho, 
                            silva.entity_region, 
                            silva.entity_descr, 
                            silva.temperature, 
                            silva.salinity, 
                            silva.oxygen, 
                            silva.chlorophyll
                           FROM web_r8.silva)
        UNION 
                 SELECT marine_phages.id AS sid, 
                    marine_phages.geom, 
                    marine_phages.site_name, 
                    marine_phages.lat, 
                    marine_phages.lon, 
                    marine_phages.latlon, 
                    marine_phages.depth, 
                    marine_phages.date_taken, 
                    marine_phages.hab_lite, 
                    marine_phages.hab_uri, 
                    marine_phages.study_type, 
                    marine_phages.entity_name, 
                    marine_phages.entity_url, 
                    marine_phages.entity_country, 
                    marine_phages.entity_iho, 
                    marine_phages.entity_region, 
                    marine_phages.entity_descr, 
                    marine_phages.temperature, 
                    marine_phages.salinity, 
                    marine_phages.oxygen, 
                    marine_phages.chlorophyll
                   FROM web_r8.marine_phages)
UNION 
         SELECT metagenomes.sid, 
            metagenomes.geom, 
            metagenomes.site_name, 
            metagenomes.lat, 
            metagenomes.lon, 
            metagenomes.latlon, 
            metagenomes.depth, 
            metagenomes.date_taken, 
            metagenomes.hab_lite, 
            metagenomes.hab_uri, 
            metagenomes.study_type, 
            metagenomes.entity_name, 
            metagenomes.entity_url, 
            metagenomes.entity_country, 
            metagenomes.entity_iho, 
            metagenomes.entity_region, 
            metagenomes.entity_descr, 
            metagenomes.temperature, 
            metagenomes.salinity, 
            metagenomes.oxygen, 
            metagenomes.chlorophyll
           FROM web_r8.metagenomes;

ALTER TABLE web_r8.samples OWNER TO megdb_admin;

GRANT SELECT ON TABLE web_r8.samples TO selectors;
GRANT SELECT ON TABLE web_r8.samples TO megxuser;
GRANT SELECT ON TABLE web_r8.samples TO megx_team;


commit;
