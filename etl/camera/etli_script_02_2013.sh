#! /bin/bash
set -x
# Init section
# init: load util functions
if [ -f ./etli_util_functions.sh ]; then
source ./etli_util_functions.sh; # here check for functions script, if missing script is terminated
else
echo "Could not find etli_util_functions.sh must be in same DIR as script.";
exit 2;
fi

# init 1.1: load configuration
if [ -f ./megdb_etl.config ]; then
source ./megdb_etl.config;# here check for functions script, if missing script is terminated
else
echo "Could not find megdb_etl.config must be in same DIR as script.";
exit 2;
fi

# init: set ETLi workflow name
declare -r ETLI_NAME="camera_portal"; # stands for the source of data
declare -r STAGE_SQL_FILE="${ETLI_NAME}-table_creation";# name for the sql table
declare -r REVERSE_LOAD_SQL_FILE="${ETLI_NAME}-reverse_loading";# name for the sql revers loading file

declare skip_init='n';
declare skip_download='y'; # y=yes download data from camera portal
declare skip_post_download='y';#y=yes checks if directorys from download were created and unzips files
declare skip_transform='y';#y=yes transform downloaded data to csv files
declare skip_post_transform='y';#y=ye checks if all csv files were created and have a coresponding fa file
declare skip_reverse_transform='y';#y=yes already existing csv files will be removed
declare skip_reverse_load='y';#y=yes drops table if they already exist
declare skip_pre_load='y';#y=yes creates metagenome and metadata table
declare skip_load='y';#y=yes loads the data into sql
declare skip_integrate='y';#y=yes integrate data in table

# init: create working envll

declare -r TODAY=$(get_iso_date)
declare -r CAMERA_PORTAL_METADATA_LINKS="${ETLI_NAME}-metadata-links-${TODAY}"
declare -r CAMERA_PORTAL_READS_LINKS="${ETLI_NAME}-reads-links-${TODAY}"
declare -r CAMERA_PROJECT_DATA_HTML="camera_portal_gridsphere-2013-02-25.htm"


function init() {
skip_check $skip_init && return 0; # the variable is checked if is put on y return 0???

create_local_wd ${ETLI_NAME} # working directory is created with etli_util_funtions.sh
WORKING_DIR=${LCD:?"ERROR: missing declaration of LCD variable. Did you call function create_local_wd?"};# call working_dir like LCD if LCD is missing error message will be echoed
DOWN_DIR_READS=${WORKING_DIR}/${DOWN_DIR_NAME}/reads;# defines the dir for the downloaded reads
DOWN_DIR_METADATA=${WORKING_DIR}/${DOWN_DIR_NAME}/metadata;# defines the dir for the downloaded metadata

if [[ ! -f ${CAMERA_PROJECT_DATA_HTML} ]];then
echo "The neccesary HTML file having all links to metadata and reads not avaialble, consider manual dowload from https://portal.camera.calit2.net/gridsphere/gridsphere?cid=sampledownloadtab";
exit 2;
fi

grep -o 'ftp://portal.camera.calit2.net/ftp-links/cam_datasets/projects/metadata.*\.csv' ${CAMERA_PROJECT_DATA_HTML} > ${CAMERA_PORTAL_METADATA_LINKS}
#grep -o 'ftp://portal.camera.calit2.net/ftp-links/cam_datasets/projects/read.*read\.fa\.gz' ${CAMERA_PROJECT_DATA_HTML} > ${CAMERA_PORTAL_READS_LINKS}
}

function not_implemented(){ # ???
echo 'This function is not yet implemented';
return 1;
}

# Download section

function download() {
skip_check $skip_download && return 0; # the variable is checked if is put on y return 0???

wget -P"${DOWN_DIR_METADATA}" -i ${CAMERA_PORTAL_METADATA_LINKS} #downloads files from t5he input file after -i and saves them with the name of variable after -P
#wget -P"${DOWN_DIR_READS}" -i ${CAMERA_PORTAL_READS_LINKS} #downloads files from t5he input file after -i and saves them with the name of variable after -P
return 0;
}

function post_download() {
skip_check $skip_post_download && return 0;# checks variable value if y function will be skipped and return 0
# check if the download directories were created this happens in function download
if [[ ! -d ${DOWN_DIR_READS} ]];then
echo "Metagenomes folder missing: ${DOWN_DIR_READS}";
exit 2;
fi

if [[ ! -d ${DOWN_DIR_METADATA} ]];then
echo "Metagenomes folder missing: ${DOWN_DIR_METADATA}";
exit 2;
fi
# unzip metagenome files in the ./downloads/reads directory
current_path=${WORKING_DIR}; #set path on variable working dir
cd ${DOWN_DIR_READS}; #goes to variable file
dir_content=$(ls *.gz);# shows all files ith ending .gz
for i in $dir_content;do # unzips all files listed by ls
gunzip $i;
done
cd $current_path;#goes back to working dir
}

# Transformation section #

reverse_transform() {
skip_check $skip_reverse_transform && return 0;#checks if revers transformed should be skipped if y returns 0; if the .csv files already exist, they will be removed
current_path=${WORKING_DIR};# set path on variable working dir
cd ${DOWN_DIR_READS};# goes to file with now unzip reads
dir_content=$(ls *.csv);# sets variable on all files ending with .csv
for i in $dir_content;do # remove all the csv files ????
rm -f $i;
done
cd $current_path;
}

transform() {
skip_check $skip_transform && return 0;# check if transform should be skipped if y return 0
#produce a TSV (tab-separated file) from every multifasta file; it prodeuces csv files?????
current_path=${WORKING_DIR};# set path on variable working directory
cd ${DOWN_DIR_READS};# goes to reads file
dir_content=$(ls *.fa);# set variable on al files ending with .fa
for i in $dir_content;do # this transforms the files in csv format and deleting double length specification ?
# problem: in some of the genome files the length is specified twice
# the following command solves this using regular expressions but takes forever to do that
#cat $i | sed '/^>/N;s/\n/\t/;s/>//;s/\(.*length=[0-9]*.*\)\(\/length=[0-9]*\)\(.*\)/\1\3/g;s/\([a-z0-9]\+\) /\1\t/'>"$i".csv;
cat $i | sed '/^>/N;s/\n/\t/;s/>//;s/\([a-z0-9]\+\) /\1\t/'>"$i".csv;
done
cd $current_path;
} # end function transform

# Transformation consitency checks

#check if all csv files were created
post_transform() {
skip_check $skip_post_transform && return 0;# check if post_transform should be skipped if y dont let function run
# every multifasta file should have a corresponding .csv file
current_path=${WORKING_DIR}; #set path on variable working dir
cd ${DOWN_DIR_READS};# go to variable reads file
dir_content=$(ls *.fa);# sets variable on al files ending with .fa
for i in $dir_content;do # for each file
if [[ ! -f $i.csv ]];then # ???
echo "Missing .csv file: $i.csv";
exit 2;
fi
done
cd $current_path;
}


### Stage table preparation ###
# drop the metagenomes and metadata tables from the database if they already exist
function reverse_load () {
skip_check $skip_reverse_load && return 0;# if skip is on y function is nor executed
cat > ${REVERSE_LOAD_SQL_FILE} <<EOF
BEGIN;
${PSQL_SEARCH_PATH}
DROP TABLE IF EXISTS ${ETLI_NAME}_metagenomes;
DROP TABLE IF EXISTS ${ETLI_NAME}_metadata;

COMMIT;
EOF
# execute stage sql script (create the table)
${PSQL_PROMPT} -f  ${REVERSE_LOAD_SQL_FILE}
}

# create the metagenomes and metadata tables
function pre_load() {
skip_check $skip_pre_load && return 0;
caller 0 #????
echo $0 # echo vairable 0
cat > ${STAGE_SQL_FILE} <<EOF
BEGIN;
${PSQL_SEARCH_PATH}

CREATE TABLE ${ETLI_NAME}_metagenomes(
sequence_id text NOT NULL,
fasta_header text NOT NULL,
sequence text NOT NULL
);

CREATE TABLE ${ETLI_NAME}_metadata(
sample_acc text NOT NULL,
sample_type text NOT NULL,
sample_volume text,
volume_unit text,
filter_min text,
filter_max text,
sample_description text,
sample_name text,
comments text,
taxon_id text,
collection_start_time text,
collection_stop_time text,
biomaterial_name text,
description text,
material_acc text,
site_name text,
latitude text,
longitude text,
altitude text,
site_depth text,
site_description text,
country_name text,
region text,
habitat_name text,
host_taxon_id text,
host_description text,
host_organism text,
library_acc text,
sequencing_method text,
dna_type text,
num_of_reads text,
material_id text,
sample_depth_m text,
temperature_c text,
salinity_psu text,
oxygen_umol_kg text,
nitrate_no3_umol_l text,
filter_type text,
water_depth_m text,
chlorophyll_density_ug_kg text,
nutrients_po3_microm text,
pressure_atm text,
nitrite_mol_l text,
phosphate_umol_kg text,
dissolved_organic_carbon_umol_kg text,
abundance_bacterial_cells_ml text,
carbon_dioxide_co2_umol_kg text,
particulate_organic_carbon_umol_kg text,
alkalinity_alk_mm text,
dissolved_organic_nitrogen_mol_kg text,
particulate_nigrogen_mol_kg text,
ph text,
sodium_um text,
potassium_k_um text,
comment text,
dissolved_oxygen_umol_kg text,
other_habitat text,
water_depth text,
sample_depth text,
temperature text,
treatment text,
time_hour text,
chloropigment text,
ammonia_nh4_um text,
sulfate_so4_mm text,
chla_mg_1000l text,
filter_type_null text,
other_habitat_null text,
methane_um text,
h2_um text,
lithium_li_um text,
strontium_sr_um text,
barium_ba_um text,
manganese_mn_um text,
iron_fe_um text,
volume_filtered_l text,
nutrients_nox_microm text,
volume_l text,
altitude_m text,
health_status text,
host_name text,
host_species text,
silica_h4sio4_um_l text,
leg text,
oxygen text,
nitrate_nitrite_nmol_kg text,
dissolved_oxygen_nmol_kg text,
fluorescence_ug_l text,
silicate_umol_kg text,
abundance_synechococcus_cells_ml text,
nutrients_po4_microm text,
viral_abundance_viruses_ml text,
nutrients_nh4_microm text,
nitrate_no3_mol_l text,
method_of_isolation text,
phage_type text,
atmospheric_wind_speed_m_s text,
wave_height_m text,
atmospheric_pressure_atm text,
turbidity_ntu text,
atmospheric_general_weather text,
mean_annual_precipitation_cm text,
host_taxon_id_1 text,
host_tissue text,
phosphate_mol_l text,
silicon_si_mol_l text,
dissolved_inorganic_nitrogen_mol_l text,
chlorophyll_density_psu text,
urea_mol_l text,
sample_depth_m_x text,
template_preparation_method text,
sample_depth_m_y text,
nutrients_spermidine_c7h19n3_nm text,
nutrients_putrescine_c4h12n2_nm text,
abundance_bacterial_cells_ml_h text,
bacterial_production_cells_ml_h text,
viral_production_viruses_ml_h text,
cfu_c_jejuni_cfu text,
glucose_mg text,
nutrients_sodium_nitrate_um text,
nutrients_potassium_phosphate_um text,
oxygen_mass_um text,
biomass_mass_g text,
chlorophyll_density_sample_month_ug_kg text,
chlorophyll_density_annual_ug_l text,
chlorophyll_density_annual_ug_kg text,
transmission text,
gene_name text,
theta_its_90 text,
biomass_concentration_ug_kg text,
dissolved_inorganic_carbon_umol_kg text,
dissolved_inorganic_phosphate_nmol_kg text,
sigma_kg_1000l text,
biofilm_g text,
ammonium_umol_kg text,
leucine_umol_kg text,
turbidity_umol_kg text,
number_of_stations_sampled text,
number_of_samples_pooled text,
isolation text,
dissolved_inorg_c_dic_mm text,
chlorinity_cl_mm text,
nutrients_dmsp_nm text,
nutrients_so4_microm text,
silicon_si_um text,
magnesium_mg_um text,
chlorinity_cl_um text,
sulfur_s2_um text,
zinc_zn_um text,
charge_pos_mmol text,
dissolved_inorg_c_dic_um text,
tungsten_w_um text,
molybdenum_mo_um text,
antimony_sb_um text,
caesium_cs_um text,
oxygen_um text,
boron_b_um text,
arsenic_as_um text,
fluorine_f_um text,
calcium_ca_um text,
nitrate_no3_um text,
aluminium_al_um text,
charge_neg_mmol text,
vanadium_v_um text,
rubidium_rb_um text,
sulfate_so4_um text,
carbon_dioxide_co2_um text,
dissolved_organic_carbon_um text,
soil_depth_m text,
potassium_null text,
sodium_null text,
ph_null text,
salinity_ppm text,
sulfate_so4_m text,
sodium_silicate_sio3_mol_kg text,
particulate_carbon_mol_kg text,
particulate_phosphate_mol_kg text,
time_count text,
light text,
filter_type_m text,
plant_cover text,
current_land_use text,
rain_fall text,
soil_type text
);

COMMIT;
EOF


# CREATE TABLE ${ETLI_NAME}_metadata(
# sample_acc text NOT NULL,
# sample_type text NOT NULL,
# sample_volume integer,
# volume_unit text,
# filter_min numeric,
# filter_max numeric,
# sample_description text,
# sample_name text,
# comments text,
# taxon_id text,
# collection_start_time text,
# collection_stop_time text,
# biomaterial_name text,
# description text,
# material_acc text,
# site_name text,
# latitude numeric,
# longitude numeric,
# altitude numeric,
# site_depth numeric,
# site_description text,
# country_name text,
# region text,
# habitat_name text,
# host_taxon_id text,
# host_description text,
# host_organism text,
# library_acc text,
# sequencing_method text,
# DNA_type text,
# num_of_reads int8,
# material_id text
# );

# execute stage sql script (create the table)
#${PSQL_PROMPT} -f ${STAGE_SQL_FILE}
} # end function pre_load


### load section ###

# load the data from the csv files
# for the metagenomes use loading as text
# for the metadata use loading as csv
# problem: the metadata files have different number of columns; the first 32 columns are common
# atm: just drop the other columns
# to do: find a way to import the non-common columns too; try key-value pairs (hstore)
load() {
skip_check $skip_load && return 0; # if skip load is on y function is not executed
# load the metagenome .csv files
echo 'importing the metagenomes';
current_path=${WORKING_DIR}; # set path on working dir
cd ${DOWN_DIR_READS}; # go to dir with reads
dir_content=$(ls *.csv); # set variable on all files ending .csv
for i in $dir_content;do # every file is put in standartin and via a pipe copyed in metagenome table
cat $i | ${PSQL_PROMPT} -c "COPY ${PSQL_SCHEMA}.${ETLI_NAME}_metagenomes FROM stdin"
done
cd $current_path;
# load the metadata files
echo 'importing the metadata';
current_path=${WORKING_DIR}; # set path on working dir
cd ${DOWN_DIR_METADATA};# go to metadata
dir_content=$(ls *.csv);# set variable to all files ending with .csv
for i in $dir_content;do # cuts all tabs and replace them with delimiters, cuts all lines after 32, the rest is in standartin and is via a pipe copyed in the metadata table
cut -d, -f -32 $i | ${PSQL_PROMPT} -c "COPY ${PSQL_SCHEMA}.${ETLI_NAME}_metadata FROM stdin CSV HEADER"
done
cd $current_path;
}

integrate() {
skip_check $skip_integrate && return 0; # if skip_integrate is set on y function is not executed
not_implemented
}

### FINALLY running everything
init
download
post_download
reverse_transform
transform;
post_transform
reverse_load
pre_load;
load;
integrate;


### END STEP 5
echo success
