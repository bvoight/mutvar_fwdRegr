#!/usr/bin/perl -w

$header = <STDIN>;
chomp($header);
print "$header BPSEQ\n";

while ($rl = <STDIN>) {
    chomp($rl);

    if ($rl =~ m/Intercept/) {
	print "$rl NA\n";
    } else {
	#initialize this seq
	$myseq{'1'} = "_";
	$myseq{'2'} = "_";
	$myseq{'3'} = "_";
	$myseq{'4'} = "-";
	$myseq{'5'} = "_";
	$myseq{'6'} = "_";
	$myseq{'7'} = "_";
	
	
	@e = split '\s+', $rl;
	@seq = split ':', $e[0];
	
	foreach $i (@seq) {
	    $i =~ m/p(\d+)_(t\d+)/;
	    $pos = $1;
	    $basecode = $2;
	    if ($basecode =~ m/t1/) {
		$base = "T";
	    } elsif ($basecode =~ m/t2/) {
		$base = "G";
	    } elsif ($basecode =~ m/t3/) {
		$base = "C";
	    }
	    $myseq{$pos} = $base;
	}
	
	$this_seq = "";
	foreach $pos (sort {$a <=> $b} keys %myseq) {
	    $this_seq .= $myseq{$pos};
	}
	
	print "$rl $this_seq\n";
    }
}
