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

###########################################################################################################
# Set variables / parse parameters
###########################################################################################################

# Important Preset variables:
# $db_host: target database host
# $db_port: target database port
# $db_name: target database name
# $JOB_ID: sge job id

db_host="antares"
db_port="5491"
db_name="megdb_r8"
db_user="sge"

CD_HIT_DUP="/home/megxnet/opt/cd-hit/4.6/cd-hit-dup"
CD_HIT_EST="/home/megxnet/opt/cd-hit/4.6/cd-hit-est"
CD_HIT_MMS="/home/megxnet/opt/cd-hit/4.6/make_multi_seq.pl"
FRAG_GENE_SCAN="/home/megxnet/opt/FGS/run_FragGeneScan.pl"
UPRO="/home/megxnet/opt/upro/beta/upro.sh"
GNUPARALLEL="/home/megxnet/opt/parallel/bin/parallel"
R_INTERPRETER="/home/megxnet/opt/R/2.15.3/bin/R"

PFAM_ACCESSIONS="/home/megxnet/opt/pfam/pfam24_acc.txt"

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

# Create job directory
mkdir "job-$JOB_ID"
cd "job-$JOB_ID"
echo "Logs and temp files will be written to:$(pwd)"

###########################################################################################################
# Download file
###########################################################################################################

# download file
RAW_FASTA="01-raw-download"
printf "Downloading $MG_URL to $RAW_FASTA..."
wget -q -O $RAW_FASTA $MG_URL
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'Could not retrieve $MG_URL');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi
echo "OK"

# validate file
printf "Validating file..."
seqret $RAW_FASTA -sformat fasta -stdout -auto > /dev/null
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'$MG_URL is not a valid FASTA file');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi
echo "OK"

###########################################################################################################
# Check for duplicates
###########################################################################################################
printf "Removing duplicated sequences..."
UNIQUE="02-unique-sequences"
UNIQUE_LOG="02-unique-sequences.log"
$CD_HIT_DUP -i $RAW_FASTA -o $UNIQUE > $UNIQUE_LOG
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'$MG_URL cannot be processed by cd-hit-dup');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi
echo "OK"

NUM_READS=$(grep 'Total number of sequences:'  $UNIQUE_LOG|awk '{print $(NF)}')
NUM_UNIQUE=$(grep 'Number of clusters found:'  $UNIQUE_LOG|awk '{print $(NF)}')

echo "Number of sequences: "$NUM_READS
echo "Number of unique sequences: "$NUM_UNIQUE
if [ "$NUM_READS" -ne "$NUM_UNIQUE" ]; then
  echo "We found duplicates. Please provide a pre-processed metagenome."
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'$MG_URL contains duplicates. Please provide a pre-processed metagenome.');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi

###########################################################################################################
# Cluster
###########################################################################################################
printf 'Clustering at 95%%...'
CLUST95="03-clustered-sequences"
CLUST95_LOG=$CLUST95".log"
CLUST95_CLSTR=$CLUST95".clstr"

$CD_HIT_EST -i $UNIQUE -o $CLUST95 -c 0.95 -T 8 -M 50000 -d 0 > $CLUST95_LOG
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'$MG_URL cannot be processed by cd-hit-est');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi
echo "OK"

NUM_CLUST95=$(grep -c '^>' $CLUST95_CLSTR)

###########################################################################################################
# Remove singletons
###########################################################################################################
printf "Removing singletons..."

$CD_HIT_MMS $CLUST95 $CLUST95_CLSTR tmp_seqs 2
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'$MG_URL cannot be processed by cd-hit');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi
echo "OK"

###########################################################################################################
# Calculate sequence statistics
###########################################################################################################
printf "Calculating sequence statistics..."
INFOSEQ_TMPFILE="04-stats-tempfile"
INFOSEQ_MGSTATS="04-mg_stats"

infoseq $CLUST95 -only -pgc -length -noheading -auto > $INFOSEQ_TMPFILE
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'Cannot calculate sequence statistics. Please contact adminitrator.');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi

$R_INTERPRETER --vanilla --slave <<RSCRIPT
t<-read.table(file = "$INFOSEQ_TMPFILE", header = F)
bp<-sum(t[,1])
meanGC<-mean(t[,2])
varGC<-var(t[,2])
res<-paste(bp, meanGC, varGC, sep = ' ')
write(res, file = "$INFOSEQ_MGSTATS")
RSCRIPT

if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'Cannot process sequence statistics. Please contact adminitrator.');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi
echo "OK"

NUM_BASES=$(cut -f1 $INFOSEQ_MGSTATS -d ' ')
GC=$(cut -f2 $INFOSEQ_MGSTATS -d ' ')
VARGC=$(cut -f3 $INFOSEQ_MGSTATS -d ' ')
printf "Number of bases: %d\nGC content: %f\nGC variance: %f\n" $NUM_BASES $GC $VARGC

###########################################################################################################
# Get ORFS
###########################################################################################################

GENEAA="05-gene-aa-seqs"
GENENT="05-gene-nt-seqs"
NSEQ=$[($NUM_READS/8)+1]

#Split original in as many files as cores
printf "Splitting file ($NSEQ seqs file)..."
awk -vO=$NSEQ 'BEGIN {n_seq=0;} /^>/ {if(n_seq%O==0){file=sprintf("05-part-%d.fa",n_seq);} print >> file; n_seq++; next;} { print >> file; }' < $CLUST95
echo "OK"

printf "Gene calling..."
$GNUPARALLEL -j 8 "$FRAG_GENE_SCAN -genome={} -out={.}.genes10 -complete=0 -train=sanger_10" ::: *.fa
if [ "$?" -ne "0" ]; then
  echo "Something went wrong"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'FragGeneScan failed. Please contact adminitrator.');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi
echo "OK"

cat 05-part*.faa > $GENEAA
cat 05-part*.ffn > $GENENT

NUM_GENES=$(grep -c '>' $GENENT)
printf "Number of genes: %d\n" $NUM_GENES

###########################################################################################################
# Functional annotation
###########################################################################################################

printf "Getting functional profile..."
PFAMFILE="06-pfam"
PFAMDB="06-pfamdb"
FUNCTIONALTABLE="06-pfam-functional-table"
CODONCUSP="06-codon.cusp"
$UPRO < $GENENT | awk '{FS=",";printf("PF%05d\n", $4)}' > $PFAMFILE
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'UPro failed. Please contact adminitrator.');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi

$R_INTERPRETER --vanilla --slave <<RSCRIPT
t<-read.table(file = '$PFAMFILE', header = F, stringsAsFactors=F)
p<-read.table(file = '$PFAM_ACCESSIONS', header = F, stringsAsFactors=F)
t.t<-as.data.frame(table(t))
colnames(p)<-'t'
t.m<-merge(t.t, p, all = T, by= "t")
t.m[is.na(t.m)]<-0
write.table(t.m, file = '$FUNCTIONALTABLE', sep = "\t", row.names = F, quote = F, col.names = F)
RSCRIPT
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'Could not process UPro output. Please contact adminitrator.');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi

awk -v f=$SAMPLE_LABEL 'BEGIN{ORS="";print "f\t{"}{ if (NR == 1) {print "{"$1","$2"}"}else{print ",{"$1","$2"}"}}END{print "}"}' $FUNCTIONALTABLE > $PFAMDB

cusp --auto -stdout $GENENT |awk '{if ($0 !~ "*" && $0 !~ /[:alphanum:]/ && $0 !~ /^$/){ print $1,$2,$5}}' > $CODONCUSP
if [ "$?" -ne "0" ]; then
  echo "failed"
  echo "INSERT INTO mg_traits.mg_traits_results (sample_label, return_code, error_message) VALUES ('$SAMPLE_LABEL',1,'Could not process UPro output. Please contact adminitrator.');" | psql -U $db_user -h $db_host -p $db_port -d $db_name
  exit 1
fi

echo "OK"

AA_TABLE="07-aa-table"
ABRATIO_FILE="07-ab-ratio"
NUC_FREQS="07-nuc-freqs"
DINUC_FREQS="07-dinuc-freqs"
ODDS_TABLE="07-odds-table"

$R_INTERPRETER --vanilla --slave <<RSCRIPT
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

ABRATIO=$(cat $ABRATIO_FILE)
compseq --auto -stdout -word 1 $CLUST95 |awk '{if (NF == 5 && $0 ~ /^A|T|C|G/ && $0 !~ /[:alphanum:]/ ){print $1,$2,$3}}' > $NUC_FREQS
compseq --auto -stdout -word 2 $CLUST95 |awk '{if (NF == 5 && $0 ~ /^A|T|C|G/ && $0 !~ /[:alphanum:]/ ){print $1,$2,$3}}' > $DINUC_FREQS

$R_INTERPRETER --vanilla --slave <<RSCRIPT
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

printf "$SAMPLE_LABEL\t" | cat - $AA_TABLE | psql -U $db_user -h $db_host -p $db_port -d $db_name -c "\COPY mg_traits.mg_traits_aa FROM STDIN"

cat $PFAMFILE | tr '\n' ',' | sed -e "s/^/$SAMPLE_LABEL\t\\{/" -e "s/,$/\\}/" | psql -U $db_user -h $db_host -p $db_port -d $db_name -c "\COPY mg_traits.mg_traits_pfam FROM STDIN"

printf "$SAMPLE_LABEL\t" | cat - $ODDS_TABLE | psql -U $db_user -h $db_host -p $db_port -d $db_name -c "\COPY mg_traits.mg_traits_dinuc FROM STDIN"

echo "INSERT INTO mg_traits.mg_traits_results (sample_label, gc_content, gc_variance, num_genes, total_mb, num_reads, ab_ratio) VALUES ('$SAMPLE_LABEL',$GC,$VARGC, $NUM_GENES, $NUM_BASES, $NUM_READS, $ABRATIO);" | psql -U $db_user -h $db_host -p $db_port -d $db_name

cd ..
rm -rf "job-$JOB_ID"




