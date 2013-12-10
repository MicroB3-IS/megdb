#!/bin/bash

START_TIME=`date +%s.%N`

GENEAA="05-gene-aa-seqs"
GENENT="05-gene-nt-seqs"
PFAMDB="06-pfamdb"
PFAMFILE="06-pfam"
FUNCTIONALTABLE="06-pfam-functional-table"
CODONCUSP="06-codon.cusp"
TFPERC="06-tfperc"
AA_TABLE="07-aa-table"
ABRATIO_FILE="07-ab-ratio"
NUC_FREQS="07-nuc-freqs"
DINUC_FREQS="07-dinuc-freqs"
ODDS_TABLE="07-odds-table"

WORK_DIR=$1

echo "Work dir: $WORK_DIR"

cd $WORK_DIR

if [ ! -e ./00-environment ]; then
	echo "00-environment is missing from work dir: $WORK_DIR"
	exit 2
else
	cat 00-environment
	source ./00-environment
fi

###########################################################################################################
# Check job array results
###########################################################################################################

FAA_RESULTS=$(ls -1 05-part*.faa | wc -l)
FFN_RESULTS=$(ls -1 05-part*.ffn | wc -l)

echo "subjobs: $SUBJOBS"
echo "FAA results found: $FAA_RESULTS"
echo "FFN results found: $FFN_RESULTS"

if [ "$FAA_RESULTS" -ne "$SUBJOBS" ] || [ "$FFN_RESULTS" -ne "$SUBJOBS" ]; then
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'At least one of the subjobs did not yield results. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$JOB_ID failed" "$tc_admin_mail" <<EOF
At least one of the subjobs did not yield results.
Files are at: $FAILED_JOBS_DIR/job-$JOB_ID
EOF
  exit 2
fi

cat 05-part*.faa > $GENEAA
cat 05-part*.ffn > $GENENT

NUM_GENES=$(grep -c '>' $GENENT)
printf "Number of genes: %d\n" $NUM_GENES

###########################################################################################################
# Functional annotation
###########################################################################################################

echo "Getting functional profile..."
echo "Running UPro on $NSLOTS cores..."
$upro "$WORK_DIR/$GENENT" | awk '{FS=",";printf("PF%05d\n", $4)}' > $PFAMFILE
if [ "$?" -ne "0" ]; then
  mail -s "traits_calc:$THIS_JOB_ID subtask $SGE_TASK_ID failed" "$tc_admin_mail" <<EOF
$upro < $GENENT | awk '{FS=",";printf("PF%05d\n", $4)}' > $PFAMFILE
exited with RC $? in job $JOB_ID.
EOF
  exit 2
fi

$r_interpreter --vanilla --slave <<RSCRIPT
t<-read.table(file = '$PFAMFILE', header = F, stringsAsFactors=F)
p<-read.table(file = '$PFAM_ACCESSIONS', header = F, stringsAsFactors=F)
tf<-read.table(file = '$TFFILE', header = F, stringsAsFactors=F)
colnames(tf)<-'t'
t.t<-as.data.frame(table(t))
colnames(p)<-'t'
t.m<-merge(t.t, p, all = T, by= "t")
t.m[is.na(t.m)]<-0
tf.m<-merge(t.t, tf, all = F, by= "t")
perc.tf<-(sum(tf.m[,2])/sum(t.m[,2]))*100
write.table(t.m, file = '$FUNCTIONALTABLE', sep = "\t", row.names = F, quote = F, col.names = F)
write.table(perc.tf, file = '$TFPERC', sep = "\t", row.names = F, quote = F, col.names = F)
RSCRIPT
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'Could not process UPro output. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$THIS_JOB_ID failed" "$tc_admin_mail" <<EOF
$r_interpreter --vanilla --slave
exited with RC $? in job $THIS_JOB_ID.
Functional table script!
Files are at: $FAILED_JOBS_DIR/job-$THIS_JOB_ID
EOF
  exit 2
fi

sort -k1 $FUNCTIONALTABLE | cut -f 2 | tr '\n' ',' | sed -e 's/^/\{/' -e 's/,$/}/' > $PFAMDB

cusp --auto -stdout $GENENT |awk '{if ($0 !~ "*" && $0 !~ /[:alphanum:]/ && $0 !~ /^$/){ print $1,$2,$5}}' > $CODONCUSP
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'cusp failed. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$THIS_JOB_ID failed" "$tc_admin_mail" <<EOF
cusp --auto -stdout $GENENT |awk '{if ($0 !~ "*" && $0 !~ /[:alphanum:]/ && $0 !~ /^$/){ print $1,$2,$5}}' > $CODONCUSP
exited with RC $? in job $THIS_JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$THIS_JOB_ID
EOF
  exit 2
fi

echo "OK"

$r_interpreter --vanilla --slave <<RSCRIPT
codon<-read.table(file = "$CODONCUSP", header = F, stringsAsFactors = F, sep = ' ')
codon<-cbind(codon, codon\$V3/sum(codon\$V3))
colnames(codon)<-c("codon", "aa", "raw", "prop")
aa<-aggregate(raw ~ aa, data = codon, sum)
aa<-cbind(aa, (aa\$raw/sum(aa\$raw)*100))
colnames(aa)<-c("aa", "raw", "prop")
aa2<-as.data.frame(t(aa\$prop))
colnames(aa2)<-aa\$aa
ab<-(aa2\$D + aa2\$E)/(aa2\$H + aa2\$R + aa2\$K)
write.table(aa2, file = "$AA_TABLE", sep = "\t", row.names = F, quote = F, col.names  = F)
write(ab, file = "$ABRATIO_FILE")
RSCRIPT

if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'AB-Ratio script failed. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$THIS_JOB_ID failed" "$tc_admin_mail" <<EOF
$r_interpreter --vanilla --slave
exited with RC $? in job $THIS_JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$THIS_JOB_ID
EOF
  exit 2
fi

ABRATIO=$(cat $ABRATIO_FILE)
PERCTF=$(cat $TFPERC)
compseq --auto -stdout -word 1 $RAW_FASTA |awk '{if (NF == 5 && $0 ~ /^A|T|C|G/ && $0 !~ /[:alphanum:]/ ){print $1,$2,$3}}' > $NUC_FREQS
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'Compseq for nucleotide freqs failed. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$THIS_JOB_ID failed" "$tc_admin_mail" <<EOF
compseq --auto -stdout -word 1 $RAW_FASTA |awk '{if (NF == 5 && $0 ~ /^A|T|C|G/ && $0 !~ /[:alphanum:]/ ){print $1,$2,$3}}' > $NUC_FREQS
exited with RC $? in job $THIS_JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$THIS_JOB_ID
EOF
  exit 2
fi

compseq --auto -stdout -word 2 $RAW_FASTA |awk '{if (NF == 5 && $0 ~ /^A|T|C|G/ && $0 !~ /[:alphanum:]/ ){print $1,$2,$3}}' > $DINUC_FREQS
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'Compseq for dinucleotide freqs failed. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$THIS_JOB_ID failed" "$tc_admin_mail" <<EOF
compseq --auto -stdout -word 2 $RAW_FASTA |awk '{if (NF == 5 && $0 ~ /^A|T|C|G/ && $0 !~ /[:alphanum:]/ ){print $1,$2,$3}}' > $DINUC_FREQS
exited with RC $? in job $THIS_JOB_ID.
Files are at: $FAILED_JOBS_DIR/job-$THIS_JOB_ID
EOF
  exit 2
fi

$r_interpreter --vanilla --slave <<RSCRIPT
nuc<-read.table(file = "$NUC_FREQS", header = F, stringsAsFactors = F, sep = ' ')
rownames(nuc)<-nuc\$V1
nuc\$V1<-NULL
nuc<-as.data.frame(t(nuc))
dinuc<-read.table(file = "$DINUC_FREQS", header = F, stringsAsFactors = F, sep = ' ')
rownames(dinuc)<-dinuc\$V1
dinuc\$V1<-NULL
dinuc<-as.data.frame(t(dinuc))
#Forward strand f(X) when X={A,T,C,G} in S
fa<-nuc\$A[[2]]
ft<-nuc\$T[[2]]
fc<-nuc\$C[[2]]
fg<-nuc\$G[[2]]
#Frequencies when S + SI = S*; f*(X) when X= {A,T,C,G}
faR<-(fa+ft)/2
fcR<-(fc+fg)/2
fAA <- (dinuc\$AA[[2]] + dinuc\$TT[[2]])/2
fAC <- (dinuc\$AC[[2]] + dinuc\$GT[[2]])/2
fCC <- (dinuc\$CC[[2]] + dinuc\$GG[[2]])/2
fCA <- (dinuc\$CA[[2]] + dinuc\$TG[[2]])/2
fGA <- (dinuc\$GA[[2]] + dinuc\$TC[[2]])/2
fAG <- (dinuc\$AG[[2]] + dinuc\$CT[[2]])/2
pAA <- fAA/(faR * faR)
pAC <- fAC/(faR * fcR)
pCC <- fCC/(fcR * fcR)
pCA <- fCA/(faR * fcR)
pGA <- fGA/(faR * fcR)
pAG <- fAG/(faR * fcR)
pAT <- dinuc\$AT[[2]]/(faR * faR)
pCG <- dinuc\$CG[[2]]/(fcR * fcR)
pGC <- dinuc\$GC[[2]]/(fcR * fcR)
pTA <- dinuc\$TA[[2]]/(faR * faR)
odds<-cbind(pAA, pAC, pCC, pCA, pGA, pAG, pAT, pCG, pGC, pTA)
colnames(odds)<-c("pAA/pTT", "pAC/pGT", "pCC/pGG", "pCA/pTG", "pGA/pTC", "pAG/pCT", "pAT", "pCG", "pGC", "pTA")
write.table(odds, file = "$ODDS_TABLE", sep = "\t", row.names = F, quote = F, col.names  = F)
RSCRIPT

if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "UPDATE mg_traits.mg_traits_jobs SET return_code = 2, error_message = 'Odds table script failed. Please contact adminitrator.' WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name
  cd ..
  mv $THIS_JOB_TMP_DIR $FAILED_JOBS_DIR
  mail -s "traits_calc:$THIS_JOB_ID failed" "$tc_admin_mail" <<EOF
$r_interpreter --vanilla --slave
exited with RC $? in job $THIS_JOB_ID.
Odds table script!
Files are at: $FAILED_JOBS_DIR/job-$THIS_JOB_ID
EOF
  exit 2
fi

# load mg_traits_aa
printf "$SAMPLE_LABEL\t" | cat - $AA_TABLE | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name -c "\COPY mg_traits.mg_traits_aa FROM STDIN"

# load mg_traits_pfam
printf "$SAMPLE_LABEL\t" | cat - $PFAMDB | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name -c "\COPY mg_traits.mg_traits_pfam FROM STDIN"

# load mg_traits_dinuc
printf "$SAMPLE_LABEL\t" | cat - $ODDS_TABLE | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name -c "\COPY mg_traits.mg_traits_dinuc FROM STDIN"

# insert into mg_traits_results
echo "INSERT INTO mg_traits.mg_traits_results (sample_label, gc_content, gc_variance, num_genes, total_mb, num_reads, ab_ratio, perc_tf) VALUES ('$SAMPLE_LABEL',$GC,$VARGC, $NUM_GENES, $NUM_BASES, $NUM_READS, $ABRATIO, $PERCTF);" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name

END_TIME=`date +%s.%N`
RUN_TIME=`echo $END_TIME-$START_TIME | bc -l`

# update mg_traits_jobs
echo "UPDATE mg_traits.mg_traits_jobs SET time_finished = now(), return_code = 0, total_run_time = total_run_time + $RUN_TIME, time_protocol = time_protocol || ('$JOB_ID', 'traits_calc_finish', $RUN_TIME)::mg_traits.time_log_entry  WHERE sample_label = '$SAMPLE_LABEL';" | psql -U $target_db_user -h $target_db_host -p $target_db_port -d $target_db_name

cd ..
rm -rf "job-$THIS_JOB_ID"