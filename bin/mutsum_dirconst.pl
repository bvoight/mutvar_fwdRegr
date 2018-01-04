#!/usr/bin/perl -w

$rl = <STDIN>;
chomp($rl);
print "$rl DIR DIR_SIG\n";

while ($rl = <STDIN>) {
    chomp($rl);
    @e = split '\s+', $rl;

    $dir = "";
    $dir_sig = "";

    shift(@e); #shift off the term
    shift(@e); #shift off the order

    while (scalar(@e) > 0) {
	$this_beta = shift(@e);
	$this_pval = shift(@e);
	if ($this_beta =~ m/NA/) { #this feature not in this sequence model
	    $dir .= "x";
	    $dir_sig .= "x";
	} else { #feature is in this sequence model
	    if ($this_beta > 0) {
		$dir .= "+";
		if ($this_pval < 0.05) {
		    $dir_sig .= "+";
		} else {
		    $dir_sig .= "0";
		}
	    } elsif ($this_beta < 0) {
		$dir .= "-";
		if ($this_pval < 0.05) {
		    $dir_sig .= "-";
		} else {
		    $dir_sig .= "0";
		}
	    }
	}      
    }

    print "$rl \'$dir \'$dir_sig\n";
}
