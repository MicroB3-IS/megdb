#!/usr/bin/perl

my %conf;
my @schemas;
my $outputFile = "silva_extract.sql";
my $configFile = "silva_etl.conf";

#------------------------------------------------------------------------------------>
# parse parameters
#------------------------------------------------------------------------------------>
for (my $i = 0; $i <= $#ARGV; $i++) {
	if ($ARGV[$i] eq '-o') {
		$i++;
		if (defined $ARGV[$i]) {
			$outputFile = $ARGV[$i];
		} else {
			die "Syntax: build_extract_script.pl [-o output file] [-c config file] schemas\n";
		}
	} elsif ($ARGV[$i] eq '-c') {
		$i++;
		if (defined $ARGV[$i]) {
			$configFile = $ARGV[$i];
		} else {
			die "Syntax: build_extract_script.pl [-o output file] [-c config file] schemas\n";
		}
	} else {
		push @schemas, $ARGV[$i];
	}
}

if (@schemas == 0) {
	die "No schemas/databases specified!";
}

#------------------------------------------------------------------------------------>
# defaults and init
#------------------------------------------------------------------------------------>
$conf{'mysqluser'} = 'mschneid';
$conf{'mysqlpw'} = '';
$conf{'mysqlhost'} = 'silva-dev';
$conf{'mysqlport'} = 3306;
$conf{'fdwserver'} = 'silva_server';

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

#------------------------------------------------------------------------------------>
# ask for password
#------------------------------------------------------------------------------------>
if ($conf{'mysqlpw'} =~ /^$/) {
	print "User '$conf{'mysqluser'}' password for '$conf{'mysqlhost'}':";
	$conf{'mysqlpw'} = <STDIN>;
	$conf{'mysqlpw'} =~ s/\n//;
}


open(OUT,">$outputFile.tmp") or die "Cannot open output file!\n";
#------------------------------------------------------------------------------------>
# header
#------------------------------------------------------------------------------------>
my $head = "--This script was automatically created by build_extract_script.pl";
$head = "CREATE EXTENSION IF NOT EXISTS mysql_fdw;\n";
$head .= "BEGIN; CREATE SERVER silva_server FOREIGN DATA WRAPPER mysql_fdw OPTIONS (address '$conf{'mysqlhost'}', port '$conf{'mysqlport'}'); COMMIT;\n";
$head .= "BEGIN; CREATE USER MAPPING FOR PUBLIC SERVER $conf{'fdwserver'} OPTIONS (username '$conf{'mysqluser'}', password '$conf{'mysqlpw'}'); COMMIT;\n";
print OUT $head;
#------------------------------------------------------------------------------------>
# Convert ddl
#------------------------------------------------------------------------------------>
foreach my $schema (@schemas) {
	my $ddl;
	my $cmd = "mysqldump --user=$conf{'mysqluser'} --host=$conf{'mysqlhost'} --port=$conf{'mysqlport'} --password=$conf{'mysqlpw'} --skip-triggers --no-data --no-create-db --skip-opt $schema";

	print "$cmd\n";

	my $result = `$cmd`;
	if ($? >> 8 != 0) {
		print $result;
		exit $? >> 8;
	}

	print OUT "CREATE SCHEMA $schema;\n";
	$ddl .= $result;
	$ddl =~ s/TABLE\s+(\S+)/TABLE $schema\.$1/g;

	# make DDL PostgreSQL compatible
	# delete comments
	$ddl =~ s/--.*\n//g;
	$ddl =~ s/\/\*.*\n//g;
	$ddl =~ s/COMMENT\s*'.*?'//g;

	# remove MySQL quotes
	$ddl =~ s/`//g;

	#remove all keys
	$ddl =~ s/\s*PRIMARY.*\n//g;
	$ddl =~ s/\s*KEY.*\n//g;
	$ddl =~ s/UNIQUE//g;
	$ddl =~ s/,\s*CONSTRAINT.+?\)/\)/g;

	#remove not nulls
	$ddl =~ s/NOT\s+NULL//g;

	#remove defaults
	$ddl =~ s/DEFAULT\s*'.*?'//g;
	$ddl =~ s/DEFAULT\s*NULL//g;
	$ddl =~ s/DEFAULT\s*CURRENT\_TIMESTAMP//g;

	#remove enums and sets
	$ddl =~ s/enum\s*\(.+?\)/TEXT/g;
	$ddl =~ s/set\s*\(.+?\)/TEXT/g;

	#clean-up number type
	$ddl =~ s/tinyint/int/g;
	$ddl =~ s/int\(\d+\)/INT/g;
	$ddl =~ s/float\(.*?\)/FLOAT/g;
	$ddl =~ s/unsigned//g;

	#all to text
	$ddl =~ s/varchar\(\d+\)/TEXT/g;
	$ddl =~ s/char\(\d+\)/TEXT/g;
	$ddl =~ s/longtext/TEXT/g;
	$ddl =~ s/mediumtext/TEXT/g;

	#remove FULLTEXT
	$ddl =~ s/FULLTEXT//g;

	#remove char set
	$ddl =~ s/CHARACTER\s+SET\s+\w+//g;

	#remove remaining commas
	$ddl =~ s/,\s*\)/\)/g;

	print OUT $ddl;

	# create foreign tables

	$ddl =~ s/CREATE\s+TABLE/CREATE FOREIGN TABLE/g;
	$ddl =~ s/\)\s*;/\) SERVER $conf{'fdwserver'} OPTIONS INSERTQUERYHERE;/g;

	print OUT $ddl;
}
close(OUT);


#------------------------------------------------------------------------------------>
# post-processing - decompress longblobs
#------------------------------------------------------------------------------------>

open(PP,"<$outputFile.tmp") or die "Cannot open output file!\n";
open(OUT,">$outputFile") or die "Cannot open output file!\n";
my @columns;
my $tablename = '';
my $query = 0;
while (<PP>) {
	my $in = $_;
	if ($in =~ /CREATE\s+FOREIGN\s+TABLE\s+(\w+\.\w+)/) {
		$tablename = $1;
		@columns = ();
		$query = 0;
		$in =~ s/(TABLE\s+\w+\.\w+)/$1\_f/;
	} elsif ($in =~ /^\s*(\w+)\s+(\w+)/) {
		my $colname = $1;
		if ($2 =~ /longblob/i) {
			push @columns, "uncompress($colname)";
			$query = 1;
			$in =~ s/longblob/TEXT/;
		} else {
			push @columns, $colname;
		}
	}
	if ($in =~ /INSERTQUERYHERE/) {
		my $opts;
		if ($query == 1) {
			$opts = "(query 'SELECT ";
			$opts .= join(',',@columns);
			$opts .= " FROM $tablename')";
		} else {
			$opts = "(table '$tablename')";
		}
		$in =~ s/INSERTQUERYHERE/$opts/;
		$in .= "\nINSERT INTO $tablename SELECT * FROM $tablename".'_f;';
		$in .= "\nDROP FOREIGN TABLE $tablename".'_f;';
		@columns = ();
		$query = 0;
	}
	print OUT "$in";
}
close(OUT);
close(PP);

`rm $outputFile.tmp`;


