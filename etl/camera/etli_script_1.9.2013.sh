	#! /bin/bash
	set -x
	## Init section ##
	## init: load util functions
	if [ -f ./etli_util_functions.sh ]; then
	  source ./etli_util_functions.sh; # here check for functions script, if missing script is terminated
	else
	  echo "Could not find etli_util_functions.sh must be in same DIR as script.";
	  exit 2;
	fi
	## init 1.1: load configuration
	if [ -f ./megdb_etl.config ]; then
	  source ./megdb_etl.config;# here check for functions script, if missing script is terminated
	else
	  echo "Could not find megdb_etl.config must be in same DIR as script.";
	  exit 2;
	fi
	
	## init: set ETLi workflow name
	declare -r ETLI_NAME="camera_portal"; # stands for the source of data
	declare -r STAGE_SQL_FILE="${ETLI_NAME}-table_creation";# name for the sql table
	declare -r REVERSE_LOAD_SQL_FILE="${ETLI_NAME}-reverse_loading";# name for the sql revers loading file
	
	declare skip_init='y';
	declare skip_download='y'; # y=yes download data from camera portal
	declare skip_post_download='y';#y=yes checks if directorys from download were created and unzips files
	declare skip_transform='y';#y=yes transform downloaded data to csv files
	declare skip_post_transform='y';#y=ye checks if all csv files were created and have a coresponding fa file
	declare skip_reverse_transform='y';#y=yes already existing csv files will be removed
	declare skip_reverse_load='n';#y=yes drops table if they already exist
	declare skip_pre_load='n';#y=yes creates metagenome and metadata table
	declare skip_load='n';#y=yes loads the data into sql
	declare skip_integrate='n';#y=yes integrate data in table
	
	## init: create working envll
	
	
	declare -r TODAY=$(get_iso_date)
	
	declare -r CAMERA_PORTAL_METADATA_LINKS="${ETLI_NAME}-metadata-links-${TODAY}"
	declare -r CAMERA_PORTAL_READS_LINKS="${ETLI_NAME}-reads-links-${TODAY}"
	declare -r CAMERA_PROJECT_DATA_HTML="camera_portal_gridsphere-2012-03-21.htm"
	
	
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
	  grep -o 'ftp://portal.camera.calit2.net/ftp-links/cam_datasets/projects/read.*read\.fa\.gz' ${CAMERA_PROJECT_DATA_HTML} > ${CAMERA_PORTAL_READS_LINKS}
	
	 # head  ${CAMERA_PORTAL_READS_LINKS} > t
	 # mv t  ${CAMERA_PORTAL_READS_LINKS}
	 
	}
	
	function not_implemented(){ # ???
	  echo 'This function is not yet implemented';
	  return 1;
	}
	
	## Download section ##
	
	function download() {
	  skip_check $skip_download && return 0; # the variable is checked if is put on y return 0???
	
	 # wget -P"${DOWN_DIR_METADATA}" -i ${CAMERA_PORTAL_METADATA_LINKS} #downloads files from t5he input file after -i and saves them with the name of variable after -P
	  wget -P"${DOWN_DIR_READS}" -i ${CAMERA_PORTAL_READS_LINKS} #downloads files from t5he input file after -i and saves them with the name of variable after -P
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
	
	### Transformation section ###
	
	reverse_transform() {
	  skip_check $skip_reverse_transform && return 0;#checks if revers transformed should be skipped if y returns 0
	  # if the .csv files already exist, they will be removed
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
	  # produce a TSV (tab-separated file) from every multifasta file; it prodeuces csv files?????
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
	
	### Transformation consitency checks
	
	# check if all csv files were created
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
	sample_volume integer,
	volume_unit text,
	filter_min numeric,
	filter_max numeric,
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
	latitude numeric,
	longitude numeric,
	altitude numeric,
	site_depth numeric,
	site_description text,
	country_name text,
	region text,
	habitat_name text,
	host_taxon_id text,
	host_description text,
	host_organism text,
	library_acc text,
	sequencing_method text,
	DNA_type text,
	num_of_reads int8,
	material_id text
	);
	
	COMMIT;
	EOF
	# execute stage sql script (create the table)
	${PSQL_PROMPT} -f ${STAGE_SQL_FILE} 
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

