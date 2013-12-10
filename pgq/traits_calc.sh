#!/bin/bash

START_TIME=`date +%s.%N`

echo "Environment variables:"

echo -e "\tJob ID: $JOB_ID"
echo -e "\tTarget database: $target_db_user@$target_db_host:$target_db_port/$target_db_name"
echo -e "\tCD-HIT-DUP: $cd_hit_dup"
echo -e "\tCD-HIT-EST: $cd_hit_est"
echo -e "\tCD-HIT-MMS: $cd_hit_mms"
echo -e "\tFragGeneScan: $frag_gene_scan"
echo -e "\tUPro: $upro"
echo -e "\tGNU Parallel: $gnuparallel"
echo -e "\tR: $r_interpreter"
echo -e "\tTemp dir: $temp_dir"
echo -e "\tTraits calc dir: $traits_calc_dir"
echo -e "\tJob out dir: $job_out_dir"
echo -e "\tTC admin mail: $tc_admin_mail"

PFAM_ACCESSIONS=$traits_calc_dir/pfam26_acc.txt
TFFILE=$traits_calc_dir/TF.txt
RUNNING_JOBS_DIR=$temp_dir/running_jobs/
FAILED_JOBS_DIR=$temp_dir/failed_jobs/
THIS_JOB_TMP_DIR=$(readlink -m "$RUNNING_JOBS_DIR/job-$JOB_ID")
RAW_DOWNLOAD="01-raw-download"
RAW_FASTA="01-raw-fasta"
UNIQUE="02-unique-sequences"
UNIQUE_LOG="02-unique-sequences.log"
CLUST95="03-clustered-sequences"
CLUST95_LOG=$CLUST95".log"
CLUST95_CLSTR=$CLUST95".clstr"
INFOSEQ_TMPFILE="04-stats-tempfile"
INFOSEQ_MGSTATS="04-mg_stats"
NSEQ=10000
JOBARRAYID="tc-$JOB_ID-fgs"
FINISHJOBID="tc-$JOB_ID-finish"


###########################################################################################################
# Parse parameters
###########################################################################################################

# urldecode input
string=$(echo $1 | sed -e 's/&/|/g' -e 's/%2b/\+/g' -e 's/%2d/-/g' -e 's/%2f/\//g' -e 's/%2e/\./g' -e 's/%5f/_/g' -e 's/%3a/:/g' -e 's/\+/ /g')

# set delimiter
IFS="|"

# parse input
echo "Input parameters:"
for pair in $string; do
key=${pair%=*}
value=${pair#*=}

printf "\t$key=$value\n";

if [ "$key" = "sample_label" ]; then
	SAMPLE_LABEL=$value;
fi

if [ "$key" = "mg_url" ]; then
	MG_URL=$value;
fi

if [ "$key" = "customer" ]; then
	CUSTOMER=$value;
fi

if [ "$key" = "sample_environment" ]; then
	SAMPLE_ENVIRONMENT=$value;
fi

if [ "$key" = "time_submitted" ]; then
	SUBMIT_TIME=$value;
fi

if [ "$key" = "make_public" ]; then
	MAKE_PUBLIC=$value;
fi

if [ "$key" = "keep_data" ]; then
	KEEP_DATA=$value;
fi

done

###########################################################################################################
# write JobID and Hostname to database
###########################################################################################################

echo "UPDATE mg_traits.mg_traits_jobs SET time_started = now(), job_id = $JOB_ID, cluster_node = '$HOSTNAME' WHERE sample_label = '$SAMPLE_LABEL';"
DB_RESULT=`echo "UPDATE mg_traits.mg_traits_jobs SET time_started = now(), job_id = $JOB_ID, cluster_node = '$HOSTNAME' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name`
if [ "$?" -ne "0" ]; then
  echo "Cannot connect to database"
  mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
Cannot connect to database. Output:
$DB_RESULT
EOF
  exit 2
fi

if [ "$DB_RESULT" != "UPDATE 1" ]; then
	echo "sample name '$SAMPLE_LABEL' is not in database"
	mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
sample name '$SAMPLE_LABEL' is not in database
Result: $DB_RESULT
EOF
	exit 2
fi

###########################################################################################################
# Check for utilities and directories
###########################################################################################################

if [ ! -d $temp_dir ]; then
	ERROR_MESSAGE="temp directory '$temp_dir' does not exist"
elif [ ! -w $temp_dir ]; then
	ERROR_MESSAGE="no permission to write to temp directory '$temp_dir'"
elif [ ! -d $RUNNING_JOBS_DIR ]; then
	ERROR_MESSAGE="running jobs directory '$RUNNING_JOBS_DIR_calc_dir' does not exist"
elif [ ! -w $RUNNING_JOBS_DIR ]; then
	ERROR_MESSAGE="no permission to write to running jobs directory '$RUNNING_JOBS_DIR_calc_dir'"
elif [ ! -d $FAILED_JOBS_DIR ]; then
	ERROR_MESSAGE="failed jobs directory '$FAILED_JOBS_DIR' does not exist"
elif [ ! -w $FAILED_JOBS_DIR ] ; then
	ERROR_MESSAGE="no permission to write to failed jobs directory '$FAILED_JOBS_DIR'"
elif [ ! -d $traits_calc_dir ]; then
	ERROR_MESSAGE="traits_calc directory '$traits_calc_dir' does not exist"
elif [ ! -r $traits_calc_dir ]; then
	ERROR_MESSAGE="no permission to read from traits_calc directory '$traits_calc_dir'"
elif [ ! -d $job_out_dir ]; then
	ERROR_MESSAGE="job out directory '$job_out_dir' does not exists"
elif [ ! -w $job_out_dir ]; then
	ERROR_MESSAGE="no permission to write to job out directory '$job_out_dir'"
elif [ ! -f $cd_hit_dup ]; then
	ERROR_MESSAGE="cannot find CD-HIT-DUP at '$cd_hit_dup'"
elif [ ! -f $cd_hit_est ]; then
	ERROR_MESSAGE="cannot find CD-HIT-EST at '$cd_hit_est'"
elif [ ! -f $cd_hit_mms ]; then
	ERROR_MESSAGE="cannot find CD-HIT-MMS at '$cd_hit_mms'"
elif [ ! -f $upro ]; then
	ERROR_MESSAGE="cannot find UPro '$upro'"
elif [ ! -f $gnuparallel ]; then
	ERROR_MESSAGE="cannot find GNU Parallel at '$gnuparallel'"
elif [ ! -f $r_interpreter ]; then
	ERROR_MESSAGE="cannot find R at '$r_interpreter'"
elif [ ! -f $PFAM_ACCESSIONS ]; then
	ERROR_MESSAGE="cannot find PFAM accessions at '$PFAM_ACCESSIONS'"
elif [ ! -f $TFFILE ]; then
	ERROR_MESSAGE="cannot find TF file at '$TFFILE'"
elif [ ! -x $cd_hit_dup ]; then
	ERROR_MESSAGE="no permission to execute CD-HIT-DUP '$cd_hit_dup'"
elif [ ! -x $cd_hit_est ]; then
	ERROR_MESSAGE="no permission to execute CD-HIT-EST '$cd_hit_est'"
elif [ ! -x $cd_hit_mms ]; then
	ERROR_MESSAGE="no permission to execute CD-HIT-MMS  '$cd_hit_mms'"
elif [ ! -x $upro ]; then
	ERROR_MESSAGE="no permission to execute UPro '$upro'"
elif [ ! -x $gnuparallel ]; then
	ERROR_MESSAGE="no permission to execute GNU Parallel '$gnuparallel'"
elif [ ! -x $r_interpreter ]; then
	ERROR_MESSAGE="no permission to find R '$r_interpreter'"
elif [ ! -r $PFAM_ACCESSIONS ]; then
	ERROR_MESSAGE="no permission to read PFAM accessions from '$PFAM_ACCESSIONS'"
elif [ ! -r $TFFILE ]; then
	ERROR_MESSAGE="no permission to read TF file from '$TFFILE'"
fi

if [ -n "$ERROR_MESSAGE" ]; then
	echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = '$ERROR_MESSAGE' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
	mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
$ERROR_MESSAGE
EOF
	exit 2
fi

###########################################################################################################
# Create job directory
###########################################################################################################

echo "This job tmp dir: $THIS_JOB_TMP_DIR"
mkdir $THIS_JOB_TMP_DIR
cd $THIS_JOB_TMP_DIR
echo "Logs and temp files will be written to:$(pwd)"

if [ "$(pwd)" != "$THIS_JOB_TMP_DIR" ]; then
	echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'could not access job temp dir' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
	mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
could not access job temp dir $THIS_JOB_TMP_DIR
EOF
	exit 2
fi

###########################################################################################################
# Download file
###########################################################################################################

# validate URL
echo "$MG_URL"
regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
if [[ ! "$MG_URL" =~ $regex ]]; then
  echo "Not a valid URL"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 1, error_message = 'Not a valid URL' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  rm -rf $THIS_JOB_TMP_DIR
  exit 1
fi

printf "Downloading $MG_URL to $RAW_DOWNLOAD..."
curl -s $MG_URL > $RAW_DOWNLOAD
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 1, error_message = 'Could not retrieve $MG_URL' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  rm -rf $THIS_JOB_TMP_DIR
  exit 1
fi
echo "OK"

gunzip -qc $RAW_DOWNLOAD > $RAW_FASTA
if [ "$?" -ne "0" ]; then
  echo "File was uncompressed"
  rm $RAW_FASTA
  mv $RAW_DOWNLOAD $RAW_FASTA
fi

###########################################################################################################
# Validate file
###########################################################################################################

printf "Validating file..."
perl <<PERLSCRIPT
use Bio::SeqIO;
\$in = Bio::SeqIO->new(-file => '$RAW_FASTA', '-format' => 'Fasta');
while (my \$seq = \$in->next_seq) {
  if (\$seq->validate_seq(\$seq->seq) == 0) {
  	exit 1;
  }
}
PERLSCRIPT
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 1, error_message = '$MG_URL is not a valid FASTA file' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  rm -rf $THIS_JOB_TMP_DIR
  exit 1
fi
echo "OK"

###########################################################################################################
# Check for duplicates
###########################################################################################################
printf "Removing duplicated sequences..."
$cd_hit_dup -i $RAW_FASTA -o $UNIQUE > $UNIQUE_LOG
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = '$MG_URL could not be processed by cd-hit-dup' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
$cd_hit_dup -i $RAW_FASTA -o /dev/null > $UNIQUE_LOG
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
  exit 2
fi
echo "OK"

NUM_READS=$(grep 'Total number of sequences:'  $UNIQUE_LOG|awk '{print $(NF)}')
NUM_UNIQUE=$(grep 'Number of clusters found:'  $UNIQUE_LOG|awk '{print $(NF)}')

echo "Number of sequences: "$NUM_READS
echo "Number of unique sequences: "$NUM_UNIQUE
if [ "$NUM_READS" -ne "$NUM_UNIQUE" ]; then
  echo "We found duplicates. Please provide a pre-processed metagenome."
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 1, error_message = '$MG_URL contains duplicates. Please provide a pre-processed metagenome.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  rm -rf $THIS_JOB_TMP_DIR
  exit 1
fi

# ###########################################################################################################
# # Cluster
# ###########################################################################################################
# printf 'Clustering at 95%%...'

# $cd_hit_est -i $RAW_FASTA -o $CLUST95 -c 0.95 -T 8 -M 50000 -d 0 > $CLUST95_LOG
# if [ "$?" -ne "0" ]; then
#   echo "failed"
#   echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = '$MG_URL cannot be processed by cd-hit-est' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
#   cd ..
#   mv $THIS_JOB_TMP_DIR $tFAILED_JOBS_DIR
#   mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
# $cd_hit_est -i $UNIQUE -o $CLUST95 -c 0.95 -T 8 -M 50000 -d 0 > $CLUST95_LOG
# exited with RC $? in job $JOB_ID.
# Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
# EOF
#   exit 2
# fi
# echo "OK"

# NUM_CLUST95=$(grep -c '^>' $CLUST95_CLSTR)

# ###########################################################################################################
# # Remove singletons
# ###########################################################################################################
# printf "Removing singletons..."

# $cd_hit_mms $CLUST95 $CLUST95_CLSTR tmp_seqs 2
# if [ "$?" -ne "0" ]; then
#   echo "failed"
#   echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = '$MG_URL cannot be processed by cd-hit' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
#   cd ..
#   mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
#   mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
# $cd_hit_mms $CLUST95 $CLUST95_CLSTR tmp_seqs 2
# exited with RC $? in job $JOB_ID.
# Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
# EOF
#   exit 2
# fi
# echo "OK"

###########################################################################################################
# Calculate sequence statistics
###########################################################################################################
printf "Calculating sequence statistics..."

infoseq $RAW_FASTA -only -pgc -length -noheading -auto > $INFOSEQ_TMPFILE
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'Cannot calculate sequence statistics. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
infoseq $RAW_FASTA -only -pgc -length -noheading -auto > $INFOSEQ_TMPFILE
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
  exit 2
fi

$r_interpreter --vanilla --slave <<RSCRIPT
t<-read.table(file = "$INFOSEQ_TMPFILE", header = F)
bp<-sum(t[,1])
meanGC<-mean(t[,2])
varGC<-var(t[,2])
res<-paste(bp, meanGC, varGC, sep = ' ')
write(res, file = "$INFOSEQ_MGSTATS")
RSCRIPT

if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'Cannot process sequence statistics. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
$r_interpreter --vanilla --slave
exited with RC $? in job $JOB_ID.
Infoseq script!
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
  exit 2
fi
echo "OK"

NUM_BASES=$(cut -f1 $INFOSEQ_MGSTATS -d ' ')
GC=$(cut -f2 $INFOSEQ_MGSTATS -d ' ')
VARGC=$(cut -f3 $INFOSEQ_MGSTATS -d ' ')
printf "Number of bases: %d\nGC content: %f\nGC variance: %f\n" $NUM_BASES $GC $VARGC

###########################################################################################################
# Get ORFS
###########################################################################################################

#Split original
printf "Splitting file ($NSEQ seqs file)..."
awk -vO=$NSEQ 'BEGIN {n_seq=0;partid=1;} /^>/ {if(n_seq%O==0){file=sprintf("05-part-%d.fa",partid);partid++;} print >> file; n_seq++; next;} { print >> file; }' < $RAW_FASTA
SUBJOBS=$(ls -1 05-part*.fa | wc -l)
echo "OK"
echo "Split into $SUBJOBS sub jobs..."

# write out variables for sub jobs
echo frag_gene_scan=$frag_gene_scan >> 00-environment
echo upro=$upro >> 00-environment
echo r_interpreter=$r_interpreter >> 00-environment
echo target_db_host=$target_db_host >> 00-environment
echo target_db_port=$target_db_port >> 00-environment
echo target_db_user=$target_db_user >> 00-environment
echo target_db_name=$target_db_name >> 00-environment
echo tc_admin_mail=$tc_admin_mail >> 00-environment
echo THIS_JOB_TMP_DIR=$THIS_JOB_TMP_DIR >> 00-environment
echo TFFILE=$TFFILE >> 00-environment
echo PFAM_ACCESSIONS=$PFAM_ACCESSIONS >> 00-environment
echo SAMPLE_LABEL=$SAMPLE_LABEL >> 00-environment
echo RAW_FASTA=$RAW_FASTA >> 00-environment
echo GC=$GC >> 00-environment
echo VARGC=$VARGC >> 00-environment
echo NUM_BASES=$NUM_BASES >> 00-environment
echo NUM_READS=$NUM_READS >> 00-environment
echo THIS_JOB_ID=$JOB_ID >> 00-environment
echo temp_dir=$temp_dir >> 00-environment
echo FAILED_JOBS_DIR=$FAILED_JOBS_DIR >> 00-environment
echo RUNNING_JOBS_DIR=$RUNNING_JOBS_DIR >> 00-environment
echo SUBJOBS=$SUBJOBS >> 00-environment

echo "Submitting job array..."
echo qsub -t 1-$SUBJOBS -o $job_out_dir -e $job_out_dir -l ga -j y -terse -P megx.p -R y -m sa -M $tc_admin_mail -N $JOBARRAYID $traits_calc_dir/traits_calc_fgs.sh $THIS_JOB_TMP_DIR
qsub -t 1-$SUBJOBS -o $job_out_dir -e $job_out_dir -l ga -j y -terse -P megx.p -R y -m sa -M $tc_admin_mail -N $JOBARRAYID $traits_calc_dir/traits_calc_fgs.sh $THIS_JOB_TMP_DIR

echo "Submitting finishing job..."
echo qsub -pe threaded 8-16 -N $FINISHJOBID -o $job_out_dir -e $job_out_dir -l ga -j y -terse -P megx.p -R y -m sa -M $tc_admin_mail -hold_jid $JOBARRAYID $traits_calc_dir/traits_calc_finish.sh $THIS_JOB_TMP_DIR
qsub -pe threaded 8-16 -N $FINISHJOBID -o $job_out_dir -e $job_out_dir -l ga -j y -terse -P megx.p -R y -m sa -M $tc_admin_mail -hold_jid $JOBARRAYID $traits_calc_dir/traits_calc_finish.sh $THIS_JOB_TMP_DIR

END_TIME=`date +%s.%N`
RUN_TIME=`echo $END_TIME-$START_TIME | bc -l`

# update mg_traits_jobs
echo "UPDATE mg_traits.mg_traits_jobs SET total_run_time = total_run_time + $RUN_TIME, time_protocol = time_protocol || ('$JOB_ID', 'traits_calc', $RUN_TIME)::mg_traits.time_log_entry WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
