#!/usr/bin/perl

system("cd ncbi;./ncbi_etl.pl -c ../etl.conf") == 0 or die "NCBI ETL failed";
system("cd silva;./silva_etl.pl -c ../etl.conf") == 0 or die "SILVA ETL failed";