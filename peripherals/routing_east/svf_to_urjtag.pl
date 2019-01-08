#!/usr/bin/perl

my $inloop=0;
my $cnt=0;
my $rep;

while(<>) {
	if ( /^LOOP/) {
		$inloop = 1;
		/(\d+) /;
		$cnt = $1;
		$rep = "";
		next;
	}
	if ($inloop == 0) {
		print $_;
		next;
	}
	if ( /^ENDLOOP/) {
		$inloop = 0;
		while ($cnt > 0) {
			print $rep;
			$cnt--;
		}
		$rep = "";
		next;
	}
	$rep = $rep . $_;
}



