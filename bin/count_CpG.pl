#!/usr/bin/perl -w

if (scalar(@ARGV) == 2) {
    $arg = shift(@ARGV); 
    if ($arg =~ m/-s/) {
	$lookup_seq = shift(@ARGV);
    } elsif ($arg =~ m/-b/) {
	$whichpos = shift(@ARGV);
	$whichpos -= 1; #index of base to extract
    } else {
	goto EXIT;
    }

} else {
    print "here\n";
  EXIT:
    print "usage: %> count_CpG.pl [-s <regex sequence> | -b[t] <1-7> ] <CpG_ratesfile >outfile_pasted\n";
    exit();
}

if ($arg =~ m/-s/) { #search and report count of sequences
    while ($rl = <STDIN>) {
	chomp($rl);
	@e = split '\s+', $rl;
	@res = $e[1] =~ m/$lookup_seq/g;
	$n = scalar(@res);
	print "$rl $n\n";
    }
} elsif ($arg =~ m/-b/) { #report the recoded value for the given requested base (ACGT -> 1234);
    while ($rl = <STDIN>) {
	chomp($rl);
	@e = split '\s+', $rl;
	@f = split '', $e[1];
	$val = $f[$whichpos];
	$val =~ tr/[ACGT]/[1234]/;	
	if ($arg =~ m/-bt/) { #report thermometer variable
	    if ($val == 1) { #set "A" to reference
		$val = "0 0 0";
	    } elsif ($val == 2) { # "C"
		$val = "0 0 1";
	    } elsif ($val == 3) { # "G"
		$val = "0 1 0";
	    } elsif ($val == 4) { # "T"
		$val = "1 0 0";
	    }
	} 
	print "$rl $val\n";
    }
}



