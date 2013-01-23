#! /bin/bash

## This script stages the tables needed to integrate md5 sums to sequences. Consists of 3 steps
## Step1: extract gff files form Bacterial genomes folder and load them in a table
## Step2: extract fna files from bacterial folder and load them in a table
## Step3-5: load the three tables with meta information about the genomes into megdb
## Further documentation under: 
## https://projects.mpi-bremen.de/megxnet/trac/wiki/MegDb/Staging/NCBIGenomeFolder

## NOTE: http://gmod.org/wiki/GFF3

### Init section ###

## init 1.1: load configuration
if [ -f ./state_config.sh ]; then
  source ./stage_config.sh
else 
  echo "Could not find megdb_etl.config must be in same DIR as script."
  exit 2
fi

## init: set ETLi workflow name
declare -r ETLI_NAME="gprj" # stands for ncbi genome projects

skip_download='y'
skip_transform='n'
skip_stage_prep='n'
skip_load='n'
skip_integrate='y'

## init: create working env
## to do: fix this
create_local_wd ${ETLI_NAME}

## init: set additional variables

# making the LCD=local directory read only for sanity. this variable is gained from call to create_local_wd
declare -r LCD=${LCD:?"ERROR: missing declaration of LCD varibale. Did you call function create_local_wd?"}

declare -r NCBI_BACTERIA_DIR=/megx/databases/ncbi/current/genomes/Bacteria

declare -r blast_fasta=${LCD}/genomes_blast.fasta
declare -r BLAST_FAA=${LCD}/genome_protein_blast.faa

declare -r STAGE_SQL_FILE=${LCD}/${ETLI_NAME}_stage.sql
declare -r STAGE_REVERSE_SQL_FILE=${LCD}/${ETLI_NAME}_stage_reverse.sql

declare -r genome_multi_fasta=${LCD}/genome_multi_fasta.fna
declare -r PROTEIN_MULTI_FASTA=${LCD}/genome_protein_multi_fasta.faa

# The three NCBI Genome Project files 
declare -r GENOME_INFO_FILE=${NCBI_BACTERIA_DIR}/lproks_0.txt
declare -r COMPLETE_GENOMES_FILE=${NCBI_BACTERIA_DIR}/lproks_1.txt
declare -r DRAFT_GENOMES_FILE=${NCBI_BACTERIA_DIR}/lproks_2.txt

# target=the (best csv) file to be created and which gets uploaded
declare -ar TARGET_FILES=(gff genome_md5 genome_info complete_genomes draft_genomes protein_md5)

#Prepare import file
#declare -r md5_import=${LCD}/md5_import.csv
#declare -r gff_import=${LCD}/gff_import.csv
#declare -r genome_info_import=${LCD}/genome_info_import.csv
#Prepare import file
#declare -r complete_genomes_import=${LCD}/complete_genomes_import.csv
# Prepare import file
#declare -r draft_genomes_import=${LCD}/draft_genomes_import.csv


echo "array=${TARGET_FILES[*]}"

declare -ri TARGET_NUM=${#TARGET_FILES[*]}

for (( k = 0; k < TARGET_NUM ; k++ ))
 do
   echo ${TARGET_FILES[k]} =  $k
   declare -r ${TARGET_FILES[k]}_import="${LCD}/${TARGET_FILES[k]}_import.csv"
   echo "${TARGET_FILES[k]}_import"
done

### Download section ###

# download outsite scope of megdb staging see:
# TODO consistency checks
function download() {
  caller 0
  echo "Download done by third party. Data should be in ${NCBI_BACTERIA_DIR}"
  return 0
}


function download_post_check() {
# check availability 
  if [ ! -f ${GENOME_INFO_FILE} ];then
   echo "Genome information file missing: ${GENOME_INFO_FILE}"
   exit 2
  fi
  #check file availability
  if [ ! -f ${COMPLETE_GENOMES_FILE} ];then
   echo "Genome information file missing: ${COMPLETE_GENOMES_FILE}"
   exit 2
  fi
  # check file availability
  if [ ! -f ${DRAFT_GENOMES_FILE} ];then
    echo "Genome information file missing: ${DRAFT_GENOMES_FILE}"
    exit 2
  fi
}

### Transformation section ###

transform_reverse() {
  # Delete file if exists
  # todo this should be part of a revert script
  if [ -f ${gff_import} ]; then
    rm ${gff_import}
  fi
  ##if file already exists, it will be removed
  if [ -f ${genome_multi_fasta} ]; then
    rm ${genome_multi_fasta}
  fi

  if [ -f ${genome_md5_import} ]; then
    rm ${genome_md5_import}
  fi


  # remove any old one
  if [ -f ${blast_fasta} ]; then
    rm ${blast_fasta}
  fi

}


transform() {


  # combine all .gff files into one
  [[ ! -f ${gff_import} ]] && find ${NCBI_BACTERIA_DIR} -type f -name '*.gff' -print0 | xargs -0  sed -e '/^#/d' '{}' >> ${gff_import}; 


if [[ ! -f ${genome_md5_import} ]]; then
  # combine all .fna files into one
  find ${NCBI_BACTERIA_DIR} -type f -name '*.fna' -print0 | xargs -0 cat '{}' >> ${genome_multi_fasta}; 

  # Check if file was created
  if [ ! -f ${genome_multi_fasta} ]; then
   echo "Genome multifasta file missing: ${genome_multi_fasta}"
   exit 2
  fi

  ## reformat the multifasta and add the md5 sums
  cat ${genome_multi_fasta} | ./md5_fasta.awk > ${blast_fasta}

  # check if file was created 
  if [ ! -f ${blast_fasta} ]; then
   echo "Blast fasta file missing: ${blast_fasta}"
   exit 2
  fi
  
  # produce a TSV (tab-separated file) from the fasta file; reformat the blast file to csv
  cat ${blast_fasta} | sed '/^>/N;s/\n/\t/;s/>//;s/\([a-z0-9]\+\) /\1\t/'  > ${genome_md5_import}
fi

## Now transform in protein fasta (=*.faa)

echo "checking if ${protein_md5_import} exists"    
 if [[ ! -f ${protein_md5_import} ]]; then
  echo "Transforming protein fasta into ${PROTEIN_MULTI_FASTA}"
  # combine all .fna files into one
  find ${NCBI_BACTERIA_DIR} -type f -name '*.faa' -print0 | xargs -0 cat '{}' >> ${PROTEIN_MULTI_FASTA}; 

  # Check if file was created
  if [ ! -f ${PROTEIN_MULTI_FASTA} ]; then
   echo "Genome multifasta file missing: ${PROTEIN_MULTI_FASTA}"
   exit 2
  fi

  ## reformat the multifasta and add the md5 sums
  cat ${PROTEIN_MULTI_FASTA} | ./md5_fasta.awk > ${BLAST_FAA}

  # check if file was created 
  if [ ! -f ${BLAST_FAA} ]; then
   echo "Blast fasta file missing: ${blast_faa}"
   exit 2
  fi
  
  # produce a TSV (tab-separated file) from the fasta file; reformat the blast file to csv
  cat ${BLAST_FAA} | sed '/^>/N;s/\n/\t/;s/>//;s/\([a-z0-9]\+\) /\1\t/'  > ${protein_md5_import}
fi



  ## remove the first 2 lines (header), 
  ## change encoding to utf8 ignoring any characters that cannot be translated
  cat ${GENOME_INFO_FILE} | sed -ne '3,$p' | iconv -f us-ascii -t utf8//IGNORE > ${genome_info_import}

  # remove the first 2 lines (header); 
  # remove trailing tab;
  # change encoding to utf8 ignoring any characters that cannot be translated
  if [ ! -f ${complete_genomes_import} ]; then
    cat ${COMPLETE_GENOMES_FILE} | sed -ne '3,$p' | sed -e 's/\t$//g' | iconv -f iso-8859-1 -t utf8//IGNORE > ${complete_genomes_import}
  fi
  ## NOTE: At this point an error in the file might be present that prevents proper handling
  ## (e.g. an extra tab present within one of the fields); 
  ## the only way to fix this by manually removing it or choosing a different fields separator


  ## remove the first 2 lines (header); remove tab before newline;change encoding to utf8 ignoring any characters that cannot be translated
 cat ${DRAFT_GENOMES_FILE} | sed -ne '3,$p' | sed -e 's/\t$//g'| iconv -f us-ascii -t utf8//IGNORE > ${draft_genomes_import}

} # end function transform

### Transformation consitency checks

# check if file was created
transform_post_check() {

  if [ -f ${gff_import} ]; then
    echo "generated=${gff_import}. File exists.";
  else
    echo "GFF import file missing."
    exit 2
  fi

  if [ ! -f ${genome_md5_import} ]; then
    echo "MD5 import file missing: ${genome_md5_import}"
  fi

  if [ ! -f ${protein_md5_import} ]; then
    echo "MD5 import file missing: ${protein_md5_import}"
  fi

  if [ ! -f ${complete_genomes_import} ];then
   echo "Complete genomes import file missing: ${complete_genomes_import}"
   exit 2
  fi
 
  # A possible half-automatic solution (NOT tested YET):
  # get the unique number of fields for this file in a variable
 uniq_line_test=$(cat ${complete_genomes_import} | awk 'BEGIN { FS = "\t" } ; { print NF-1 }' | sort | uniq | wc -l)

  # If all lines in the file have the same number of fields, uniq_test should have only one line
  if [[ ! "$uniq_line_test" -eq "1" ]] ; then 
     echo "Not all lines in this file contain equal number of <TAB> characters:  ${complete_genomes_import}\n Either fix this manually, or choose another Field Separator."; 
  fi

  # check if file was created
  if [ ! -f ${draft_genomes_import} ];then
    echo "Draft genomes import file missing: ${draft_genomes_import}"
    exit 2
  fi



}


### Stage table preparation ###

function stage_reverse () {

drop_stm=""

for (( k = 0; k < TARGET_NUM ; k++ ))
 do
   drop_stm="${drop_stm}
 DROP TABLE IF EXISTS ${ETLI_NAME}_${TARGET_FILES[k]};"
done


cat > ${STAGE_REVERSE_SQL_FILE} <<EOF
BEGIN;
${PSQL_SEARCH_PATH}

${drop_stm}

COMMIT;
EOF

# execute stage sql script (create the table)
${PSQL_PROMPT} -f ${STAGE_REVERSE_SQL_FILE}

}


function stage_prep() {
  caller 0
  echo $0
  cat > ${STAGE_SQL_FILE} <<EOF
BEGIN;
${PSQL_SEARCH_PATH}

CREATE TABLE ${ETLI_NAME}_gff (
  seqid text NOT NULL,
  source text NOT NULL,
  _type text NOT NULL,
  _start integer NOT NULL,
  stop integer NOT NULL,
  score text NOT NULL,
  strand varchar(1) NOT NULL CHECK (strand ~ '(\+|-|\.|\?)'),
  phase text NOT NULL CHECK (phase ~ '(0|1|2|\.)'),
  attributes text NOT NULL
);

CREATE TABLE ${ETLI_NAME}_genome_md5 (
  md5sum text NOT NULL,
  fasta_header text NOT NULL,
  seq text NOT NULL
);

CREATE TABLE ${ETLI_NAME}_protein_md5 (
  md5sum text NOT NULL,
  fasta_header text NOT NULL,
  seq text NOT NULL
);

CREATE TABLE ${ETLI_NAME}_genome_info (
  project_id text NOT NULL,
  taxonomy_id  text, 
  organism_name text NOT NULL,
  super_kingdom  text NOT NULL,
  _group  text,
  sequence_status  text,
  genome_size  text,
  gc_content  text,
  gram_stain  text,
  shape text,
  arrangment  text,
  endospores  text,
  motility  text,
  salinity  text,
  oxygen_req  text,
  habitat  text,
  temp_range  text,
  optimal_temp  text,
  pathogenic_in  text,
  disease  text 
);

CREATE TABLE ${ETLI_NAME}_draft_genomes (
  project_id text,
  taxonomy_id text,
  organism_name text,
  super_kingdom text,
  _group text,
  sequence_availability text,
  accession text,
  number_of_contigs text,
  number_of_cdss_on_contigs text,
  genome_size text,
  gc_content text,
  released_date text,
  center_name text,
  center_url text
);

CREATE TABLE ${ETLI_NAME}_complete_genomes (
  project_id text,
  taxonomy_id text,
  organism_name text, 
  super_kingdom text,
  _group text,
  genome_size text,
  gc_content text,
  number_of_chromosomes text,
  number_of_plasmids text,
  released_date text,
  modified_date text,
  genbank_accessions text,
  refseq_accessions text,
  publications text,
  center_consortium text
);

COMMIT;
EOF

# execute stage sql script (create the table)
${PSQL_PROMPT} -f ${STAGE_SQL_FILE}

} # end function stage_prep


### load section ###

load() {

  #import the file
  cat ${genome_info_import} | ${PSQL_PROMPT} -c "COPY ${PSQL_SCHEMA}.${ETLI_NAME}_genome_info FROM stdin"

  echo "importing ${complete_genomes_import}"
  # import the file
  cat ${complete_genomes_import} | ${PSQL_PROMPT} -c "COPY ${PSQL_SCHEMA}.${ETLI_NAME}_complete_genomes FROM stdin"

  # import the file
  cat ${draft_genomes_import} | ${PSQL_PROMPT} -c "COPY ${PSQL_SCHEMA}.${ETLI_NAME}_draft_genomes FROM stdin"

  echo "importing ${gff_import}"
  # import the protein annotation and coordinates
  ${PSQL_PROMPT} -c "COPY ${PSQL_SCHEMA}.${ETLI_NAME}_gff FROM '${gff_import}'"

  echo "importing ${genome_md5_import}"
  # Import the file
  ${PSQL_PROMPT} -c "COPY ${PSQL_SCHEMA}.${ETLI_NAME}_genome_md5 FROM '${genome_md5_import}'" 

  # import the file
  ${PSQL_PROMPT} -c "COPY ${PSQL_SCHEMA}.${ETLI_NAME}_protein_md5 FROM '${protein_md5_import}'" 


}

### FINALLY running everything

#stage_reverse && cat ${STAGE_REVERSE_SQL_FILE}



skip_check "download" ||  download;
skip_check "transform" || transform;
skip_check "stage_prep" || stage_prep;
skip_check "load" || load;
skip_check "integrate" || integrate;



### END STEP 5
echo success


