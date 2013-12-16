#!/bin/bash

START_TIME=`date +%s.%N`

echo "Environment variables:"

echo -e "\tJob ID: $JOB_ID"
echo -e "\tTarget database: $target_db_user@$target_db_host:$target_db_port/$target_db_name"
echo -e "\tTemp dir: $temp_dir"
echo -e "\tJob out dir: $job_out_dir"
echo -e "\tTC admin mail: $tc_admin_mail"
echo -e "\tPorfs: $porfs"
echo -e "\tGenDB: $gendb"

RUNNING_JOBS_DIR=$temp_dir/running_jobs/
FAILED_JOBS_DIR=$temp_dir/failed_jobs/
THIS_JOB_TMP_DIR=$(readlink -m "$RUNNING_JOBS_DIR/job-$JOB_ID")
GENDB_CREATE_PROJECT="$gendb/bin/create_project"
GENDB_IMPORT_EMBL="$gendb/bin/import_EMBL_GBK"
GENDB_CREATE_TOOLS="$gendb/bin/tool_creator"
GENDB_SUBMIT_JOB="$gendb/bin/submit_job"
GENDB_EXPORT_EMBL="$gendb/bin/export_EMBL_GBK"
GENDB_PID="MEGX_$JOB_ID"

RAW_DOWNLOAD="01-raw-download"
RAW_FASTA="01-raw-fasta"

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

if [ "$key" = "url" ]; then
	INPUT_URL=$value;
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

echo "UPDATE gendbpipe.gendbpipe_jobs SET time_started = now(), job_id = $JOB_ID, cluster_node = '$HOSTNAME' WHERE sample_label = '$SAMPLE_LABEL';"
DB_RESULT=`echo "UPDATE gendbpipe.gendbpipe_jobs SET time_started = now(), job_id = $JOB_ID, cluster_node = '$HOSTNAME' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name`
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
	ERROR_MESSAGE="temp directory $temp_dir does not exist"
elif [ ! -w $temp_dir ]; then
	ERROR_MESSAGE="no permission to write to temp directory $temp_dir"
elif [ ! -d $RUNNING_JOBS_DIR ]; then
	ERROR_MESSAGE="running jobs directory $RUNNING_JOBS_DIR does not exist"
elif [ ! -w $RUNNING_JOBS_DIR ]; then
	ERROR_MESSAGE="no permission to write to running jobs directory $RUNNING_JOBS_DIR_calc_dir"
elif [ ! -d $FAILED_JOBS_DIR ]; then
	ERROR_MESSAGE="failed jobs directory $FAILED_JOBS_DIR does not exist"
elif [ ! -w $FAILED_JOBS_DIR ] ; then
	ERROR_MESSAGE="no permission to write to failed jobs directory $FAILED_JOBS_DIR"
elif [ ! -d $job_out_dir ]; then
	ERROR_MESSAGE="job out directory $job_out_dir does not exists"
elif [ ! -w $job_out_dir ]; then
	ERROR_MESSAGE="no permission to write to job out directory $job_out_dir"
elif [ ! -f $porfs ]; then
	ERROR_MESSAGE="cannot find porfs at $porfs"
elif [ ! -f $GENDB_CREATE_PROJECT ]; then
	ERROR_MESSAGE="cannot find create_project at $GENDB_CREATE_PROJECT"
elif [ ! -f $GENDB_IMPORT_EMBL ]; then
	ERROR_MESSAGE="cannot find import_EMBL_GBK at $GENDB_IMPORT_EMBL"
elif [ ! -f $GENDB_CREATE_TOOLS ]; then
	ERROR_MESSAGE="cannot find tool_creator at $GENDB_CREATE_TOOLS"
elif [ ! -f $GENDB_SUBMIT_JOB ]; then
	ERROR_MESSAGE="cannot find submit_job at $GENDB_SUBMIT_JOB"
elif [ ! -f $GENDB_EXPORT_EMBL ]; then
	ERROR_MESSAGE="cannot find export_EMBL_GBK at $GENDB_EXPORT_EMBL"
elif [ ! -x $porfs ]; then
	ERROR_MESSAGE="cannot execute porfs at $porfs"
elif [ ! -x $GENDB_CREATE_PROJECT ]; then
	ERROR_MESSAGE="cannot execute create_project at $GENDB_CREATE_PROJECT"
elif [ ! -x $GENDB_IMPORT_EMBL ]; then
	ERROR_MESSAGE="cannot execute import_EMBL_GBK at $GENDB_IMPORT_EMBL"
elif [ ! -x $GENDB_CREATE_TOOLS ]; then
	ERROR_MESSAGE="cannot execute tool_creator at $GENDB_CREATE_TOOLS"
elif [ ! -x $GENDB_SUBMIT_JOB ]; then
	ERROR_MESSAGE="cannot execute submit_job at $GENDB_SUBMIT_JOB"
elif [ ! -x $GENDB_EXPORT_EMBL ]; then
	ERROR_MESSAGE="cannot execute export_EMBL_GBK at $GENDB_EXPORT_EMBL"
fi

if [ -n "$ERROR_MESSAGE" ]; then
	echo $ERROR_MESSAGE
	echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = '$ERROR_MESSAGE' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
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
	echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'could not access job temp dir' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
	mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
could not access job temp dir $THIS_JOB_TMP_DIR
EOF
	exit 2
fi

###########################################################################################################
# Download file
###########################################################################################################

# validate URL
regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
if [[ ! "$INPUT_URL" =~ $regex ]]; then
  echo "Not a valid URL"
  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 1, error_message = 'Not a valid URL' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  rm -rf $THIS_JOB_TMP_DIR
  exit 1
fi

printf "Downloading $INPUT_URL to $RAW_DOWNLOAD..."
curl -s $INPUT_URL > $RAW_DOWNLOAD
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 1, error_message = 'Could not retrieve $INPUT_URL' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
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
  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 1, error_message = '$INPUT_URL is not a valid FASTA file' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  rm -rf $THIS_JOB_TMP_DIR
  exit 1
fi
echo "OK"

###########################################################################################################
# Split file
###########################################################################################################

printf "Splitting file..."
NUM_FILES=`csplit -f "$RAW_FASTA.contig_" -z $RAW_FASTA '/^>/' '{*}' | wc -l`
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could not split file. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
csplit -f "$RAW_FASTA.contig_" -z $RAW_FASTA '/^>/' '{*}'
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
  exit 2
fi
echo -e "split to $NUM_FILES files"

###########################################################################################################
# Porfs
###########################################################################################################

PATH=$PATH:/usr/local/software/glimmer/bin
echo "porfs..."
for file in *.contig_*; do
	printf "working on file $file..."
	$porfs -s $file -t 001 &> $file.porfs.log
	if [ "$?" -ne "0" ]; then
	  echo "failed"
	  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could porf file. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
	  cd ..
	  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
	  mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
$porfs -s $file -t 001 &> $file.porfs.log
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
	  exit 2
	fi
	echo "OK"
done

###########################################################################################################
# GenDB
###########################################################################################################

###########################################################################################################
# GenDB - Create project
###########################################################################################################
printf "Creating GenDB Project..."
ssh mg-dispatcher "echo -e '\n' | $GENDB_CREATE_PROJECT -p $GENDB_PID -m"
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could not create GenDB project. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
ssh mg-dispatcher "$GENDB_CREATE_PROJECT -p GDBP_$JOB_ID -m"
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
  exit 2
fi
echo "OK"

###########################################################################################################
# GenDB - Import files
###########################################################################################################
printf "Importing Files..."
for file in *.glimmer3.embl; do
	echo $gendbpw | $GENDB_IMPORT_EMBL -p $GENDB_PID -f $file
	if [ "$?" -ne "0" ]; then
	  echo "failed"
	  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could not import files to GenDB. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
	  cd ..
	  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
	  mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
$GENDB_IMPORT_EMBL -p $GENDB_PID -f $file
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
	  exit 2
	fi
done
echo "OK"

###########################################################################################################
# GenDB - Add tools
###########################################################################################################
printf "Adding tools..."
echo $gendbpw | $GENDB_CREATE_TOOLS -p $GENDB_PID -F
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could not create GenDB tools. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
$GENDB_CREATE_TOOLS -p $GENDB_PID -F
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
  exit 2
fi
echo "OK"

###########################################################################################################
# GenDB - Submit jobs
###########################################################################################################
printf "Submitting jobs..."
echo $gendbpw | $GENDB_SUBMIT_JOB -p $GENDB_PID -F -rsf
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could not submit GenDB project. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
$GENDB_SUBMIT_JOB -p $GENDB_PID -F -rsf
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
  exit 2
fi
echo "OK"

###########################################################################################################
# GenDB - Wait
###########################################################################################################
echo "Waiting for GenDB to finish..."
FINISHED=0
while [ $FINISHED -eq "0" ]; do
	INPROGRESS=`mysql -s -s -h mg-mysql -u megxnet --password=$gendbpw ${GENDB_PID}_G22 -e "select count(*) from Job where state = 1 or state = 3;"`
	ERRORSTATE=`mysql -s -s -h mg-mysql -u megxnet --password=$gendbpw ${GENDB_PID}_G22 -e "select count(*) from Job where state != 1 and state != 3 and state != 5;"`
	if [ "$ERRORSTATE" -ne "0" ]; then
	  echo "failed"
	  echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'A GenDB job failed. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
	  cd ..
	  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
	  mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
$ERRORSTATE jobs are in error state.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
	  exit 1
	fi
	if [ "$INPROGRESS" -eq "0" ]; then
		echo "finished"
		FINISHED=1
	fi
	echo "$INPROGRESS jobs still in progress..."
	sleep 60
done

###########################################################################################################
# GenDB - Import results to database
###########################################################################################################
ALL_CONTIGS=`mysql -s -s -h mg-mysql -u megxnet --password=pyYPrJWtinrD ${GENDB_PID}_G22 -e "select name from Sequence;"`
printf "All contigs:\n$ALL_CONTIGS"
echo
IFS=`echo -e '\n'`
for contig in $ALL_CONTIGS; do
	echo "Working on contig $contig..."
	echo $gendbpw | $GENDB_EXPORT_EMBL -p $GENDB_PID -c $contig -f ${contig}.contig.embl
	if [ "$?" -ne "0" ]; then
		echo "failed"
		echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could not export from GenDB project. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
		cd ..
		mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
		mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
$GENDB_EXPORT_EMBL -p $GENDB_PID -c $contig -f ${contig}.contig.embl
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
		exit 2
	fi
	seqret ${contig}.contig.embl -sformat embl -offormat2 gff3 -ofname2 ${contig}.contig.gff -osformat2 fasta -feature -auto
	if [ "$?" -ne "0" ]; then
		echo "failed"
		echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could not reformat GenDB output. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
		cd ..
		mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
		mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
seqret ${contig}.contig.embl -sformat embl -offormat2 gff3 -ofname2 ${contig}.contig.gff -osformat2 fasta -feature -auto
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
		exit 2
	fi

	cat ${contig}.contig.gff | grep -v '^#' | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name -c "\COPY gendbpipe.gendbpipe_results FROM STDIN"
	if [ "$?" -ne "0" ]; then
		echo "failed"
		echo "UPDATE gendbpipe.gendbpipe_jobs SET return_code = 2, error_message = 'Could not import GenDB output. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
		cd ..
		mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
		mail -s "gendbpipe:$JOB_ID failed" "$tc_admin_mail" <<EOF
cat ${contig}.contig.gff | grep -v '^#' | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name -c "\COPY gendbpipe.gendbpipe_results FROM STDIN"
exited with RC $? in job $JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
		exit 2
	fi
done

END_TIME=`date +%s.%N`
RUN_TIME=`echo $END_TIME-$START_TIME | bc -l`

echo "UPDATE gendbpipe.gendbpipe_jobs SET time_finished = now(), total_run_time = $RUN_TIME, return_code = 0 WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name

cd ..
rm -rf "job-$THIS_JOB_ID"