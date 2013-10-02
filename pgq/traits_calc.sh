#!/usr/bin/bash
# variables $db_host, $db_port, $db_name are passed by qsub -v db_host=[host],db_port=[port],db_name=[name]
#example from blast consumer;
#echo $(psql -U sge -h $db_host -p $db_port -d $db_name -c "COPY(select seq from core.blast_run where sid='$sid' AND jid='$jid'::numeric) TO STDOUT") | eval blastall -p $prog -d /vol/biodb/megx/$db $evalue -m 7 > $outfile


# READ PROPERTIES FILE
FILE=$1

#source "./"$PROPS
#if [ "$?" -ne "0" ]; then
#  echo "Validation failed."
#  exit 1
#fi

#echo "Crunching metagenome "$NAME": "$DESCRIPTION

PREFIX=$(echo $FILE|cut -f1 -d '.' )

printf "Validating file..."
# FASTA VALIDATION
seqret $FILE -sformat fasta -stdout -auto > /dev/null
if [ "$?" -ne "0" ]; then
  echo "Wrong file format."
  exit 1
fi

printf " done\n"

# Checking for duplicates
printf "Removing duplicated sequences..."
UNIQUE=$PREFIX"_unique.fasta"
UNIQUELOG=$PREFIX"_unique.log"
./cd-hit-dup -i $FILE -o $UNIQUE > $UNIQUELOG

if [ "$?" -ne "0" ]; then
  echo "Wrong file format."
  exit 1
fi
printf " done\n"


NUMREADS=$(grep 'Total number of sequences:'  $UNIQUELOG|awk '{print $(NF)}')
NUMUNIQUE=$(grep 'Number of clusters found:'  $UNIQUELOG|awk '{print $(NF)}')

echo "Number of sequences: "$NUMREADS
echo "Number of unique sequences: "$NUMUNIQUE

if [ "$NUMREADS" -ne "$NUMUNIQUE" ]; then
  echo "We found duplicates. Please provide a pre-processed metagenome."
  exit 1
fi




# printf 'Clustering at 95%%...'
# CLUST95=$PREFIX"-95.fasta"
# CLUST95LOG=$PREFIX"-95.log"
# CLUST95CLSTR=$CLUST95".clstr"
# # Cluster at 95%
# /usr/local/software/cd-hit-4.6.1/cd-hit-est -i $UNIQUE -o $CLUST95 -c 0.95 -T 8 -M 50000 -d 0 > $CLUST95LOG

# if [ "$?" -ne "0" ]; then
#   echo "Wrong file format."
#   exit 1
# fi
# printf " done\n"


# NUMCLUST95=$(grep -c '^>' CLUST95CLSTR)

# printf "Removing singletons...\n"

# /usr/local/software/cd-hit-4.6.1/make_multi_seq.pl $UNIQUE $CLUST95CLSTR tmp_seqs 2

# if [ "$?" -ne "0" ]; then
#   echo "Wrong file format."
#   exit 1
# fi
# printf " done\n"
# exit 0


printf "Calculating sequence statistics..."

infoseq $FILE -only -pgc -length -noheading -auto > tmp_file

R --vanilla <<'RSCRIPT' > /dev/null
t<-read.table(file = 'tmp_file', header = F)
bp<-sum(t[,1])
meanGC<-mean(t[,2])
varGC<-var(t[,2])
res<-paste(bp, meanGC, varGC, sep = ' ')
write(res, file = 'mg_stats.txt')
RSCRIPT

if [ "$?" -ne "0" ]; then
  echo "Wrong file format."
  exit 1
fi
printf " done\n"


NUMBASES=$(cut -f1 mg_stats.txt -d ' ')
GC=$(cut -f2 mg_stats.txt -d ' ')
VARGC=$(cut -f3 mg_stats.txt -d ' ')
printf "Number of bases: %d\nGC content: %f\nGC variance: %f\n" $NUMBASES $GC $VARGC



# Get ORFS with getorf
printf "Getting ORFs..."
ORFAA=$PREFIX"_orf_aa.fasta"
ORFNT=$PREFIX"_orf_nt.fasta"
getorf -minsize 180 $FILE -auto -find 0 -outseq $ORFAA
getorf -minsize 180 $FILE -auto -find 2 -outseq $ORFNT

if [ "$?" -ne "0" ]; then
  echo "Something went wrong."
  exit 1
fi
printf " done\n"

NUMORFS=$(grep -c '>' $ORFAA)

printf "Number of ORFs: %d\n" $NUMORFS


# Functional annotation
printf "Getting functional profile..."
sh ~/upro/beta/upro.sh < $FILE | awk '{FS=",";printf("PF%05d\n", $4)}' > pfam.txt

if [ "$?" -ne "0" ]; then
  echo "Something went wrong."
  exit 1
fi
R --vanilla <<'RSCRIPT' > /dev/null
t<-read.table(file = 'pfam.txt', header = F, stringsAsFactors=F)
p<-read.table(file = 'pfam24_acc.txt', header = F, stringsAsFactors=F)
t.t<-as.data.frame(table(t))
colnames(p)<-'t'
t.m<-merge(t.t, p, all = T, by= "t")
t.m[is.na(t.m)]<-0
write.table(t.m, file = 'functional_table.txt', sep = "\t", row.names = F, quote = F, header = F)
RSCRIPT

if [ "$?" -ne "0" ]; then
  echo "Something went wrong."
  exit 1
fi
printf " done\n"
R --vanilla <<'RSCRIPT' > /dev/null
codon<-read.table(file = "GS002.cusp", header = F, stringsAsFactors = F, sep = ' ')
codon<-cbind(codon, codon$V3/sum(codon$V3))
colnames(codon)<-c("codon", "aa", "raw", "prop")
aa<-aggregate(raw ~ aa, data = codon, sum)
aa<-cbind(aa, (aa$raw/sum(aa$raw)*100))
colnames(aa)<-c("aa", "raw", "prop")
aa2<-as.data.frame(t(aa$prop))
colnames(aa2)<-aa$aa
ab<-(aa2$D + aa2$E)/(aa2$H + aa2$R + aa2$K)

write.table(t.m, file = 'functional_table.txt', sep = "\t", row.names = F, quote = F, header = T)
write.t
able(t.m, file = 'functional_table.txt', sep = "\t", row.names = F, quote = F, header = F)
RSCRIPT
