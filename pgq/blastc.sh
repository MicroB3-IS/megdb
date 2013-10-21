#!/bin/bash
### SGE CONFIGS ###
#$ -o /vol/tmp/megx/
#$ -l ga
#$ -j y
#$ -terse
#$ -P megx.p
#$ -R y
#$ -m sa
#$ -M mschneid@mpi-bremen.de,rkottman@mpi-bremen.de

#set -x
#sleep 30

string=$(echo $1 | sed -e 's/&/|/g' -e 's/%2d/-/g' -e 's/%2e/\./g' -e 's/%5f/_/g' -e 's/%3a/:/g' -e 's/\+/ /g')

IFS="|"

for pair in $string; do
key=${pair%=*}
value=${pair#*=}

echo $key -- $value;

if [ "$key" = "sid" ]; then
	sid=$value;
fi

if [ "$key" = "jid" ]; then
	jid=$value;
fi
if [ "$key" = "program_name" ]; then
	prog=$value;
fi

if [ "$key" = "db" ]; then
	db=$value;
fi

if [ "$key" = "filter" ]; then
	filter="-F $value";
fi

if [ "$key" = "evalue" -a "$key" != "$value" ]; then
	evalue="-e $value";
fi

done

outfile="/tmp/$sid.out"

# variables $db_host, $db_port, $db_name are passed by qsub -v db_host=[host],db_port=[port],db_name=[name]

echo $(psql -U sge -h $db_host -p $db_port -d $db_name -c "COPY(select seq from core.blast_run where sid='$sid' AND jid='$jid'::numeric) TO STDOUT") | eval blastall -p $prog -d /vol/biodb/megx/$db $evalue -m 7 > $outfile
exit_code=$?;

if [ "$exit_code" == 0 ]; then
	oxml_raw=$(cat $outfile | tr -d '\n')
	oxml=$(sed -e '2,1d' $outfile | tr -d '\n')
echo "update core.blast_run set result_raw=XMLPARSE(DOCUMENT '$oxml_raw'),result=XMLPARSE(DOCUMENT '$oxml') where sid='$sid' AND jid='$jid'::numeric" | psql -U sge -h $db_host -p $db_port -d $db_name
else
	echo 'NO RESULT FILE!';
echo "update core.blast_run set result_raw=XMLPARSE(DOCUMENT '<e/>'),result=XMLPARSE(DOCUMENT '<e/>') where sid='$sid' AND jid='$jid'::numeric" | psql -U sge -h $db_host -p $db_port -d $db_name
fi

stdoutput=$(cat $SGE_STDERR_PATH | tr -d '\n')
echo "update core.blast_run set stdout='$stdoutput' where sid='$sid' AND jid='$jid'::numeric" | psql -U sge -h $db_host -p $db_port -d $db_name

#echo "update core.blast_run set result_raw=XMLPARSE(DOCUMENT '$oxml_raw'),result=XMLPARSE(DOCUMENT '$oxml') where sid='$sid' AND jid='$jid'::numeric" | psql -U sge -h reno -p 5444 -d megdb_devel_r6