#!/usr/bin/perl

use File::Basename;

my $scriptDir = dirname($0);
my %conf;
my $configFile = "silva_etl.conf";
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
$conf{'mysqluser'} = 'mschneid';
$conf{'mysqlpw'} = '';
$conf{'mysqlhost'} = 'silva-dev';
$conf{'mysqlport'} = 3306;
$conf{'fdwserver'} = 'silva_server';
$conf{'pguser'} = 'mschneid';
$conf{'pgpw'} = '';
$conf{'pghost'} = 'antares';
$conf{'pgdb'} = 'megdb_r8';
$conf{'pgport'} = 5434;
$conf{'ssuschema'} = '';
$conf{'lsuschema'} = '';

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


if ($skip < 1) {
#------------------------------------------------------------------------------------>
# create stage script
#------------------------------------------------------------------------------------>
	print "Create silva_extract.sql script...\n";
	$result = system("$scriptDir/build_extract_script.pl -c $configFile -o silva_extract.sql $conf{'ssuschema'} $conf{'lsuschema'} 2>&1");
	if ($result != 0) {
		print "failed with rc $result\n";
		exit $result;
	}
#------------------------------------------------------------------------------------>
# Extract
#------------------------------------------------------------------------------------>
	print "Extract data from $conf{'mysqlhost'} to $conf{'pghost'}...\n";
	$result = system("psql -h $conf{'pghost'} -p $conf{'pgport'} -U $conf{'pguser'} $conf{'pgdb'} 2>&1 < silva_extract.sql");
	if ($result != 0) {
		print "failed with rc $result\n";
		exit $result;
	}
}
if ($skip < 2) {
#------------------------------------------------------------------------------------>
# transform
#------------------------------------------------------------------------------------>
	open(IN, "<silva_transform.sql") or die "Cannot open silva_transoform.sql";
	open(PSQL, "|psql -h $conf{'pghost'} -p $conf{'pgport'} -U $conf{'pguser'} $conf{'pgdb'} 2>&1");
	while (<IN>) {
		s/\%SSUSCHEMA\%/$conf{'ssuschema'}/g;
		s/\%LSUSCHEMA\%/$conf{'lsuschema'}/g;
		print PSQL;		
	}
	close(IN);
	close(PSQL);
	$result = $? >> 8;
	if ($result != 0) {
		print "failed with rc $result\n";
		exit $result;
	}
}
#------------------------------------------------------------------------------------>
# load
#------------------------------------------------------------------------------------>
print "Load data...\n";
$result = system("psql -h $conf{'pghost'} -p $conf{'pgport'} -U $conf{'pguser'} $conf{'pgdb'} 2>&1 < silva_load.sql");
if ($result != 0) {
	print "failed with rc $result\n";
	exit $result;
}
