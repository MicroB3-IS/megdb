#!/usr/bin/perl

my $first_line = 0;
while (<STDIN>) {
	my $line = $_;
	$line =~ s/\n//;
	if (/^>/) {
		if ($first_line == 0) {
			print "$line\t";
			$first_line = 1;
		}
		else {
			print "\n$line\t";
		}
	}
	else {
		print $line;
	}
}
print "\n";