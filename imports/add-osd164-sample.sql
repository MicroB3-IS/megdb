
Begin;

With raw as (
INSERT INTO osdregistry.osd_raw_samples{"version":"6","contact":{"first_name":"Eileen","last_name":"Bresnan","institute":"Marine Scotland Science","email":"e.bresnan@marlab.ac.uk"},"sampling_site":{"site_id":"OSD164","campaign":"OSD-June-2014","objective":"","platform":"unknown","device":"unknown","method":"already described","site_name":"Scalloway","start_coordinates":{"latitude":"60.14333","longitude":"-1.28250"},"stop_coordinates":{"latitude":"60.14333","longitude":"-1.28250"},"marine_region":""},"sample":{"label":"OSD164-06-14-Scalloway","protocol_label":"NPL022","date":"2014-06-23","start_time":"10:08:22","end_time":"10:18:56","depth":5,"description":"CTD cast done to record environmental parameters","filters":[{"filtration_time":5,"container":"already described","content":"already described","treatment_chemicals":"already described","treatment_storage":"already described"}]},"environment":{"water_temperature":21.902,"salinity":38.076,"biome":"ENVO:00000447","feature":"ENVO:00002042","material":"ENVO:00002010","phosphate":{"choice":"measured","measurement":{"value":0.16,"unit":"Âµmol/L"}},"ph":{"choice":"not determined"},"nitrate":{"nitrate-choice":"measured","nitrate-measurement":0.03},"carbon_organic_particulate_poc":{"carbon_organic_particulate_poc-choice":"not determined"},"nitrite":{"nitrite-choice":"measured"},"carbon_organic_dissolved_doc":{"carbon_organic_dissolved_doc-choice":"not determined"},"nano_microplankton":{"nano_microplankton-choice":"not determined"},"downward_par":{"downward_par-choice":"not determined"},"conductivity":{"conductivity-choice":"not determined"},"primary_production_isotope_uptake":{"primary_production_isotope_uptake-choice":"not determined"},"primary_production_oxygen":{"primary_production_oxygen-choice":"not determined"},"dissolved_oxygen_concentration":{"dissolved_oxygen_concentration-choice":"measured","dissolved_oxygen_concentration-measurement":8.707},"nitrogen_organic_particulate_pon":{"nitrogen_organic_particulate_pon-choice":"not determined"},"meso_macroplankton":{"meso_macroplankton-choice":"not determined"},"bacterial_production_isotope_uptake":{"bacterial_production_isotope_uptake-choice":"not determined"},"nitrogen_organic_dissolved_don":{"nitrogen_organic_dissolved_don-choice":"not determined"},"ammonium":{"ammonium-choice":"measured","ammonium-measurement":0.03},"silicate":{"silicate-choice":"measured","silicate-measurement":1.73},"bacterial_production_respiration":{"bacterial_production_respiration-choice":"not determined"},"turbidity":{"turbidity-choice":"measured","turbidity-measurement":2.436},"fluorescence":{"choice":"not determined"},"pigment_concentration":{"choice":"measured","measurement":{"value":2.8,"unit":"mg/m^3"}},"picoplankton_flow_cytometry":{"choice":"not determined"},"other_parameters":[],"comment":""}

)

INSERT INTO osdregistry.samples(
            submission_id, osd_id, label, label_verb, start_lat, start_lon, 
            stop_lat, stop_lon, start_lat_verb, start_lon_verb, stop_lat_verb, 
            stop_lon_verb, start_geog, stop_geog, max_uncertain, water_depth, 
            local_date, local_date_verb, local_start, local_end, protocol, 
            objective, platform, platform_verb, device, description, water_temperature, 
            salinity, biome, feature, material,
            )
    VALUES ();


rollback;