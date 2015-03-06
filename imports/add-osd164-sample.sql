
Begin;

With raw as (
INSERT INTO osdregistry.osd_raw_samples (raw_json,version)
VALUES ( 
translate( '{
    "version": "6",
    "contact": {
        "first_name": "Eileen",
        "last_name": "Bresnan",
        "institute": "Marine Scotland Science",
        "email": "e.bresnan@marlab.ac.uk"
    },
    "sampling_site": {
        "site_id": "OSD164",
        "campaign": "OSD-June-2014",
        "objective": "",
        "platform": "boat",
        "device": "bucket",
        "method": "already described",
        "site_name": "Scalloway",
        "start_coordinates": {
            "latitude": "60.14333",
            "longitude": "-1.28250"
        },
        "stop_coordinates": {
            "latitude": "60.14333",
            "longitude": "-1.28250"
        },
        "marine_region": ""
    },
    "sample": {
        "label": "OSD164-06-14-Scalloway",
        "protocol_label": "NPL022",
        "date": "2014-06-13",
        "start_time": "10:00:00",
        "end_time": "10:00:00",
        "depth": 2,
        "description": "",
        "filters": [
            {
                "filtration_time": 10,
                "quantity": 420,
                "container": "Sterivex cartridge",
                "content": "particulate matter on a 0.22 filter",
                "size-fraction_lower-threshold": 0.22,
                "size-fraction_upper-threshold": 0.22,
                "treatment_chemicals": "none",
                "treatment_storage": "-20 °C"
            },
            {
                "filtration_time": 10,
                "quantity": 360,
                "container": "Sterivex cartridge",
                "content": "particulate matter on a 0.22 filter",
                "size-fraction_lower-threshold": 0.22,
                "size-fraction_upper-threshold": 0.22,
                "treatment_chemicals": "none",
                "treatment_storage": "-20 °C"
            },
            {
                "filtration_time": 10,
                "quantity": 600,
                "container": "Sterivex cartridge",
                "content": "particulate matter on a 0.22 filter",
                "size-fraction_lower-threshold": 0.22,
                "size-fraction_upper-threshold": 0.22,
                "treatment_chemicals": "none",
                "treatment_storage": "-20 °C"
            },
            {
                "filtration_time": 10,
                "quantity": 360,
                "container": "Sterivex cartridge",
                "content": "particulate matter on a 0.22 filter",
                "size-fraction_lower-threshold": 0.22,
                "size-fraction_upper-threshold": 0.22,
                "treatment_chemicals": "none",
                "treatment_storage": "-20 °C"
            },
            {
                "filtration_time": 10,
                "quantity": 600,
                "container": "Sterivex cartridge",
                "content": "particulate matter on a 0.22 filter",
                "size-fraction_lower-threshold": 0.22,
                "size-fraction_upper-threshold": 0.22,
                "treatment_chemicals": "none",
                "treatment_storage": "-20 °C"
            },
            {
                "filtration_time": 10,
                "quantity": 360,
                "container": "Sterivex cartridge",
                "content": "particulate matter on a 0.22 filter",
                "size-fraction_lower-threshold": 0.22,
                "size-fraction_upper-threshold": 0.22,
                "treatment_chemicals": "none",
                "treatment_storage": "-20 °C"
            }
        ]
    },
    "environment": {
        "water_temperature": 12.2,
        "salinity": 35.1354,
        "biome": "ENVO:00000447",
        "feature": "ENVO:00002042",
        "material": "ENVO:00002010",
        "phosphate": {
            "choice": "not determined"
        },
        "ph": {
            "choice": "not determined"
        },
        "nitrate": {
            "nitrate-choice": "not determined"
        },
        "carbon_organic_particulate_poc": {
            "carbon_organic_particulate_poc-choice": "not determined"
        },
        "nitrite": {
            "nitrite-choice": "not determined"
        },
        "carbon_organic_dissolved_doc": {
            "carbon_organic_dissolved_doc-choice": "not determined"
        },
        "nano_microplankton": {
            "nano_microplankton-choice": "not determined"
        },
        "downward_par": {
            "downward_par-choice": "not determined"
        },
        "conductivity": {
            "conductivity-choice": "not determined"
        },
        "primary_production_isotope_uptake": {
            "primary_production_isotope_uptake-choice": "not determined"
        },
        "primary_production_oxygen": {
            "primary_production_oxygen-choice": "not determined"
        },
        "dissolved_oxygen_concentration": {
            "dissolved_oxygen_concentration-choice": "not determined"
        },
        "nitrogen_organic_particulate_pon": {
            "nitrogen_organic_particulate_pon-choice": "not determined"
        },
        "meso_macroplankton": {
            "meso_macroplankton-choice": "not determined"
        },
        "bacterial_production_isotope_uptake": {
            "bacterial_production_isotope_uptake-choice": "not determined"
        },
        "nitrogen_organic_dissolved_don": {
            "nitrogen_organic_dissolved_don-choice": "not determined"
        },
        "ammonium": {
            "ammonium-choice": "not determined"
        },
        "silicate": {
            "silicate-choice": "not determined"
        },
        "bacterial_production_respiration": {
            "bacterial_production_respiration-choice": "not determined"
        },
        "turbidity": {
            "turbidity-choice": "not determined"
        },
        "fluorescence": {
            "choice": "not determined"
        },
        "pigment_concentration": {
            "choice": "not determined"
        },
        "picoplankton_flow_cytometry": {
            "choice": "not determined"
        },
        "other_parameters": [],
        "comment": ""
    }
}', E'\n', '')::json, 6) RETURNING id
) , sam AS (

  INSERT INTO osdregistry.samples(
            submission_id, osd_id, label, label_verb, 
            start_lat,start_lon, 
            stop_lat, stop_lon,
            start_lat_verb, start_lon_verb, stop_lat_verb,stop_lon_verb, 
            water_depth, 
            local_date, local_date_verb, 
            local_start, local_start_verb, local_end,local_end_verb,
            protocol, 
            platform, platform_verb, device, description, water_temperature, 
            salinity, biome, feature, material
            )
  select 
    raw.id, 164, 'Scalloway', 'Scalloway', 
    60.14333,-1.28250,
    60.14333,-1.28250, 
    '60.14333','-1.28250', '60.14333','-1.28250',
    2,
    '2014-06-13','2014-06-13',
    '10:00:00+00:00','10:00:00','10:00:00+00:00','10:00:00',
    'NPL022',
    'boat', 'boat', 'bucket', '', 12.2,
    35.1354, 'ENVO:00000447','ENVO:00002042','ENVO:00002010'
  from raw returning *  
  
), part as (
  insert into osdregistry.participants(email,first_name, last_name) 
  select 'E.Bresnan@MARLAB.AC.UK', 'Eileen', 'Bresnan'
), own as (
  insert into osdregistry.owned_by (sample_id, email, seq_author_order ) 
  select submission_id,'E.Bresnan@MARLAB.AC.UK', 1 from sam returning *
) 
select * from own;

commit;