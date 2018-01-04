#!/usr/bin/perl -w

@subst_list = ();

foreach $file (@ARGV) {    
    #save which substitution you are merging; full list
    $file =~ m/CpG_([ACGTX]-[ACGTX]+)/;
    $seq = $1; 
    push @subst_list, $seq;

    open IN, "<$file" or die;
    $rl = <IN>; #header;

    while ($rl = <IN>) {
	chomp($rl);
	@e = split '\s+', $rl;
	if ($e[5] =~ /NA/) {
	    $order = 0; #intercept
	} else {
	    $order = () = $e[5] =~ m/[ACGT]/g;
	}
	@{$data{$order}{$e[5]}{$seq}} = ($e[1], $e[4]);
	$termlist{$order}{$e[5]} = 1;
    }
    close(IN);
}

#print header
print "BPSEQ ORDER";
foreach $seq (sort {$a cmp $b} @subst_list) {
    @bp = split '-', $seq;
    print " BETA_@{[$bp[0]]}to@{[$bp[1]]} PVAL_@{[$bp[0]]}to@{[$bp[1]]}";
}
print "\n";

foreach $order (sort {$a <=> $b} keys %data) {
    foreach $term (sort {$a cmp $b} keys %{$termlist{$order}}) {
	if ($term =~ m/NA/) {
	    $count = 0;
	} else {
	    $count = () = $term =~ m/[ACGT]/g;
	}
	print "$term $count";
	foreach $seq (sort {$a cmp $b} @subst_list) {
	    if (!defined($data{$order}{$term}{$seq}[0])) {
		print " NA NA";
	    } else {
		printf " %1.3g %1.3g", $data{$order}{$term}{$seq}[0],$data{$order}{$term}{$seq}[1];
	    }
	}
	print "\n";
    }
}
