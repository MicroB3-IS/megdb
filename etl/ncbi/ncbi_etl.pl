#!/usr/bin/perl

use File::Basename;

my $scriptDir = dirname($0);
my %conf;
my $configFile = "ncbi_etl.conf";
my $result;
my $skip = 0;

#------------------------------------------------------------------------------------>
# parse parameters
#------------------------------------------------------------------------------------>
for (my $i = 0; $i <= $#ARGV; $i++) {
	if ($ARGV[$i] eq '-c') {
		$i++;
		if (defined $ARGV[$i]) {
			$configFile = $ARGV[$i];
		} else {
			die "Syntax: silva_etl.pl [-c config file] [-e | -t] \n";
		}
	} elsif ($ARGV[$i] eq '-e') {
		$skip = 1 unless $skipExtract > 1;
	} elsif ($ARGV[$i] eq '-t') {
		$skip = 2 unless $skipExtract > 2;
	}
}

#------------------------------------------------------------------------------------>
# defaults and init
#------------------------------------------------------------------------------------>
$conf{'pguser'} = 'mschneid';
$conf{'pgpw'} = '';
$conf{'pghost'} = 'antares';
$conf{'pgdb'} = 'megdb_r8';
$conf{'pgport'} = 5434;
$conf{'temp_dir'} = '/tmp/ncbi/';

#------------------------------------------------------------------------------------>
# load config from file
#------------------------------------------------------------------------------------>
open(CONF, "<$configFile") or die "File $configFile not found!";
while(<CONF>) {
	if (/^\s*([^\#]+?)\s*=\s*(.+?)\s*$/) {
		$conf{$1} = $2;
	}
}
close(CONF);
	
if ($conf{'pgpw'} !~ /^$/) {
	$ENV{PGPASSWORD} = $conf{'pgpw'};
}

if (defined $conf{ftp_proxy})
{
	$ENV{ftp_proxy} = $conf{ftp_proxy};
}
	

if ($skip < 1) {
#------------------------------------------------------------------------------------>
# extract
#------------------------------------------------------------------------------------>
	print "Checking temp directory...\n";
	print `mkdir $conf{temp_dir}` unless -e "$conf{temp_dir}";
	exit 1 unless ($? >> 8 == 0);
	print "Checking temp directory...OK\n";
	
	print "Downloading contextual info...\n";
	print `wget -P $conf{temp_dir} ftp://ftp.ncbi.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt` unless -e "$conf{temp_dir}/prokaryotes.txt";
	exit 1 unless ($? >> 8 == 0);
	print "Downloading contextual info...OK\n";

	print "Creating stage tables...\n";
	print `psql -h $conf{'pghost'} -p $conf{'pgport'} -U $conf{'pguser'} $conf{'pgdb'} 2>&1 < ncbi_extract.sql`;
	exit 1 unless ($? >> 8 == 0);
	print "Creating stage tables...OK\n";
	
	print "Loading contextual info...\n";
	print `psql -h $conf{'pghost'} -p $conf{'pgport'} -U $conf{'pguser'} $conf{'pgdb'} 2>&1 -c "\\copy ncbi.genome_info from '$conf{temp_dir}/prokaryotes.txt' with csv delimiter E'\\t' NULL '-' HEADER;"`;
	exit 1 unless ($? >> 8 == 0);
	print "Loading contextual info...OK\n";

	print "Downloading sequences...\n";
	print `wget -P $conf{temp_dir} ftp://ftp.ncbi.nih.gov/genomes/Bacteria/all.fna.tar.gz` unless -e "$conf{temp_dir}/all.fna.tar.gz";
	exit 1 unless ($? >> 8 == 0);
	print "Downloading sequences...OK\n";
	
	print "Decompressing sequences...\n";
	print `tar -C $conf{temp_dir} -xvzkf $conf{temp_dir}/all.fna.tar.gz` unless -e "$conf{temp_dir}/all.fna.tar.gz.is.unpacked";
	exit 1 unless ($? >> 8 == 0);
	print `touch $conf{temp_dir}/all.fna.tar.gz.is.unpacked`;
	print "Decompressing sequences...OK\n";
	
	print "Loading sequence data...\n";
	print `find $conf{temp_dir}/ -type f -name '*.fna' -print0 | xargs -0 cat | ./fasta_to_psql_stdin.pl | psql -h $conf{'pghost'} -p $conf{'pgport'} -U $conf{'pguser'} $conf{'pgdb'} -c "\\copy ncbi.genome_fasta from stdin"`;
	exit 1 unless ($? >> 8 == 0);
	print "Loading sequence data...OK\n";
}
if ($skip < 2) {
#------------------------------------------------------------------------------------>
# transform
#------------------------------------------------------------------------------------>
	print "Transforming data...\n";
	print `psql -h $conf{'pghost'} -p $conf{'pgport'} -U $conf{'pguser'} $conf{'pgdb'} 2>&1 < ncbi_transform.sql`;
	exit 1 unless ($? >> 8 == 0);
	print "Transforming data...\n";
}
#------------------------------------------------------------------------------------>
# load
#------------------------------------------------------------------------------------>
	print "Loading data...\n";
	print `psql -h $conf{'pghost'} -p $conf{'pgport'} -U $conf{'pguser'} $conf{'pgdb'} 2>&1 < ncbi_load.sql`;
	exit 1 unless ($? >> 8 == 0);
	print "Loading data...OK\n";


