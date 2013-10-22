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

# Important Preset variables:
# $db_host: target database host
# $db_port: target database port
# $db_name: target database name
# $JOB_ID: sge job id

#example from blast consumer;
#echo $(psql -U sge -h $db_host -p $db_port -d $db_name -c "COPY(select seq from core.blast_run where sid='$sid' AND jid='$jid'::numeric) TO STDOUT") | eval blastall -p $prog -d /vol/biodb/megx/$db $evalue -m 7 > $outfile

mkdir "job-$JOB_ID"
cd "job-$JOB_ID"

# urldecode input
string=$(echo $1 | sed -e 's/&/|/g' -e 's/%2b/\+/g' -e 's/%2d/-/g' -e 's/%2f/\//g' -e 's/%2e/\./g' -e 's/%5f/_/g' -e 's/%3a/:/g' -e 's/\+/ /g')

# set delimiter
IFS="|"

# parse input
for pair in $string; do
key=${pair%=*}
value=${pair#*=}

echo $key -- $value;

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

done

# READ PROPERTIES FILE
#source "./"$PROPS
#if [ "$?" -ne "0" ]; then
#  echo "Validation failed."
#  exit 1
#fi

#echo "Crunching metagenome "$NAME": "$DESCRIPTION

PREFIX=$JOB_ID

# download file
RAW_FASTA=$PREFIX"_raw.fasta"
echo "Downloading from $MG_URL to $RAW_FASTA"
wget -q -O $RAW_FASTA $MG_URL
if [ "$?" -ne "0" ]; then
  echo "Cannot download file from:"$MG_URL
  exit 1
fi

# validate file
printf "Validating file..."
seqret $RAW_FASTA -sformat fasta -stdout -auto > /dev/null
if [ "$?" -ne "0" ]; then
  echo "Wrong file format.\n"
  exit 1
fi
printf "OK\n"

# Checking for duplicates
printf "Removing duplicated sequences..."
UNIQUE=$PREFIX"_unique.fasta"
UNIQUELOG=$PREFIX"_unique.log"
~/opt/cd-hit/4.6/cd-hit-dup -i $RAW_FASTA -o $UNIQUE > $UNIQUELOG
if [ "$?" -ne "0" ]; then
  echo "Wrong file format.\n"
  exit 1
fi
printf "OK\n"

NUMREADS=$(grep 'Total number of sequences:'  $UNIQUELOG|awk '{print $(NF)}')
NUMUNIQUE=$(grep 'Number of clusters found:'  $UNIQUELOG|awk '{print $(NF)}')

echo "Number of sequences: "$NUMREADS
echo "Number of unique sequences: "$NUMUNIQUE
if [ "$NUMREADS" -ne "$NUMUNIQUE" ]; then
  echo "We found duplicates. Please provide a pre-processed metagenome."
  exit 1
fi

printf 'Clustering at 95%%...'
CLUST95=$PREFIX"-95.fasta"
CLUST95LOG=$PREFIX"-95.log"
CLUST95CLSTR=$CLUST95".clstr"
# Cluster at 95%
~/opt/cd-hit/4.6/cd-hit-est -i $UNIQUE -o $CLUST95 -c 0.95 -T 8 -M 50000 -d 0 > $CLUST95LOG

if [ "$?" -ne "0" ]; then
  echo "Wrong file format."
  exit 1
fi
printf " done\n"

NUMCLUST95=$(grep -c '^>' CLUST95CLSTR)

printf "Removing singletons...\n"

~/opt/cd-hit/4.6/make_multi_seq.pl $UNIQUE $CLUST95CLSTR tmp_seqs 2

if [ "$?" -ne "0" ]; then
  echo "Wrong file format."
  exit 1
fi
printf " done\n"

printf "Calculating sequence statistics..."

INFOSEQ_TMPFILE=$PREFIX"_stats"
INFOSEQ_MGSTATS=$PREFIX"_mg_stats"
echo Tempfile: $INFOSEQ_TMPFILE
echo statfile: $INFOSEQ_MGSTATS
infoseq $UNIQUE -only -pgc -length -noheading -auto > $INFOSEQ_TMPFILE

R --vanilla --slave <<RSCRIPT
t<-read.table(file = "$INFOSEQ_TMPFILE", header = F)
bp<-sum(t[,1])
meanGC<-mean(t[,2])
varGC<-var(t[,2])
res<-paste(bp, meanGC, varGC, sep = ' ')
write(res, file = "$INFOSEQ_MGSTATS")
RSCRIPT

if [ "$?" -ne "0" ]; then
  echo "Wrong file format."
  exit 1
fi
printf " done\n"


NUMBASES=$(cut -f1 $INFOSEQ_MGSTATS -d ' ')
GC=$(cut -f2 $INFOSEQ_MGSTATS -d ' ')
VARGC=$(cut -f3 $INFOSEQ_MGSTATS -d ' ')
printf "Number of bases: %d\nGC content: %f\nGC variance: %f\n" $NUMBASES $GC $VARGC

# Get ORFS with getorf
#GENEAA=$PREFIX"_gene_aa.fasta"
#GENENT=$PREFIX"_gene_nt.fasta"
#NSEQ=$[($NUMREADS/8)+1]
#
#Split original in as many files as cores
#printf "Splitting file ($NSEQ seqs file)..."
#awk -vO=$NSEQ 'BEGIN {n_seq=0;} /^>/ {if(n_seq%O==0){file=sprintf("myseq%d.fa",n_seq);} print >> file; n_seq++; next;} { print >> file; }' < $FILE
#printf " done\n"
#
#printf "Gene calling..."
#~/opt/parallel/bin/parallel -j 8 'FGS/run_FragGeneScan.pl -genome={} -out={.}.genes10 -complete=0 -train=sanger_10' ::: *.fa
#
#cat myseq*.faa > $GENEAA
#cat myseq*.ffn > $GENENT
#
#if [ "$?" -ne "0" ]; then
#  echo "Something went wrong."
#  exit 1
#fi
#printf " done\n"
#
#NUMGENES=$(grep -c '>' $GENENT)
#
#printf "Number of geness: %d\n" $NUMGENES
#
#
# Functional annotation
#printf "Getting functional profile..."
#sh ~/upro/beta/upro.sh < $GENENT | awk '{FS=",";printf("PF%05d\n", $4)}' > pfam.txt
#
#if [ "$?" -ne "0" ]; then
#  echo "Something went wrong."
#  exit 1
#fi
#R --vanilla <<'RSCRIPT' > /dev/null
#t<-read.table(file = 'pfam.txt', header = F, stringsAsFactors=F)
#p<-read.table(file = 'pfam24_acc.txt', header = F, stringsAsFactors=F)
#t.t<-as.data.frame(table(t))
#colnames(p)<-'t'
#t.m<-merge(t.t, p, all = T, by= "t")
#t.m[is.na(t.m)]<-0
#write.table(t.m, file = 'functional_table.txt', sep = "\t", row.names = F, quote = F, col.names = F)
#RSCRIPT
#awk -v f=$SAMPLE_LABEL 'BEGIN{ORS="";print "f\t{"}{ if (NR == 1) {print "{"$1","$2"}"}else{print ",{"$1","$2"}"}}END{print "}"}' functional_table.txt > pfam_db.txt
#
#cusp --auto -stdout $GENENT |awk '{if ($0 !~ "*" && $0 !~ /[:alphanum:]/ && $0 !~ /^$/){ print $1,$2,$5}}' > codon.cusp
#
#
#if [ "$?" -ne "0" ]; then
#  echo "Something went wrong."
#  exit 1
#fi
#printf " done\n"
#R --vanilla <<'RSCRIPT' > /dev/null
#codon<-read.table(file = "codon.cusp", header = F, stringsAsFactors = F, sep = ' ')
#codon<-cbind(codon, codon$V3/sum(codon$V3))
#colnames(codon)<-c("codon", "aa", "raw", "prop")
#aa<-aggregate(raw ~ aa, data = codon, sum)
#aa<-cbind(aa, (aa$raw/sum(aa$raw)*100))
#colnames(aa)<-c("aa", "raw", "prop")
#aa2<-as.data.frame(t(aa$prop))
#colnames(aa2)<-aa$aa
#ab<-(aa2$D + aa2$E)/(aa2$H + aa2$R + aa2$K)
#write.table(aa2, file = 'aa_table.txt', sep = "\t", row.names = F, quote = F, col.names  = T)
#write(ab, file = 'ab_ratio.txt')
#RSCRIPT
#ABRATIO=$(cat ab_ratio.txt)
#
#compseq --auto -stdout -word 1 GS002.fna |awk '{if (NF == 5 && $0 ~ /^A|T|C|G/ && $0 !~ /[:alphanum:]/ ){print $1,$2,$3}}' > nuc_freqs.txt
#
#compseq --auto -stdout -word 2 GS002.fna |awk '{if (NF == 5 && $0 ~ /^A|T|C|G/ && $0 !~ /[:alphanum:]/ ){print $1,$2,$3}}' > dinuc_freqs.txt
#
#R --vanilla <<'RSCRIPT' > /dev/null
#nuc<-read.table(file = "nuc_freqs.txt", header = F, stringsAsFactors = F, sep = ' ')
#rownames(nuc)<-nuc$V1
#nuc$V1<-NULL
#nuc<-as.data.frame(t(nuc))
#dinuc<-read.table(file = "dinuc_freqs.txt", header = F, stringsAsFactors = F, sep = ' ')
#rownames(dinuc)<-dinuc$V1
#dinuc$V1<-NULL
#dinuc<-as.data.frame(t(dinuc))
#Forward strand f(X) when X={A,T,C,G} in S
#fa<-nuc$A[[2]]
#ft<-nuc$T[[2]]
#fc<-nuc$C[[2]]
#fg<-nuc$G[[2]]
#Frequencies when S + SI = S*; f*(X) when X= {A,T,C,G}
#faR<-(fa+ft)/2
#fcR<-(fc+fg)/2
#fAA <- (dinuc$AA[[2]] + dinuc$TT[[2]])/2
#fAC <- (dinuc$AC[[2]] + dinuc$GT[[2]])/2
#fCC <- (dinuc$CC[[2]] + dinuc$GG[[2]])/2
#fCA <- (dinuc$CA[[2]] + dinuc$TG[[2]])/2
#fGA <- (dinuc$GA[[2]] + dinuc$TC[[2]])/2
#fAG <- (dinuc$AG[[2]] + dinuc$CT[[2]])/2
#pAA <- fAA/(faR * faR)
#pAC <- fAC/(faR * fcR)
#pCC <- fCC/(fcR * fcR)
#pCA <- fCA/(faR * fcR)
#pGA <- fGA/(faR * fcR)
#pAG <- fAG/(faR * fcR)
#pAT <- dinuc$AT[[2]]/(faR * faR)
#pCG <- dinuc$CG[[2]]/(fcR * fcR)
#pGC <- dinuc$GC[[2]]/(fcR * fcR)
#pTA <- dinuc$TA[[2]]/(faR * faR)
#odds<-cbind(pAA, pAC, pCC, pCA, pGA, pAG, pAT, pCG, pGC, pTA)
#colnames(odds)<-c("pAA/pTT", "pAC/pGT", "pCC/pGG", "pCA/pTG", "pGA/pTC", "pAG/pCT", "pAT", "pCG", "pGC", "pTA")
#RSCRIPT

echo "INSERT INTO mg_traits.mg_traits_results VALUES ('$SAMPLE_LABEL',$GC,$VARGC);" | psql -U sge -h antares -p 5491 -d megdb_r8