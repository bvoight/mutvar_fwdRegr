#!/usr/bin/perl -w

if (scalar(@ARGV) == 5) {
    $mode = shift(@ARGV);
    $which_sub = shift(@ARGV);
    $runs = shift(@ARGV);
    $ratefiledir = shift(@ARGV);
    $path = shift(@ARGV);
} else {
    print "usage: %>auto_CVsummary.pl [0|1|2] [A-C|A-G|A-T|C-A|C-G|C-T] param_filelist ratefiledir path\n";
    exit();
}

open IN, "<$runs" or die;
while ($modelfile = <IN>) {
    chomp($modelfile);
    if ($mode == 0 || $mode == 1) {
	system "R --vanilla <mutRate_CV_summary.R --args @{[$path]}/$modelfile $ratefiledir/nonCpG_rates_@{[$which_sub]}_train_cov_vf.txt $ratefiledir/nonCpG_rates_@{[$which_sub]}_test_cov_vf.txt @{[$path]}/@{[$modelfile]}_@{[$which_sub]}.CVout";
    } elsif ($mode == 2) {
	system "R --vanilla <mutRate_CV_summary.R --args @{[$path]}/$modelfile $ratefiledir/CpG_rates_@{[$which_sub]}_train_cov_vf.txt $ratefiledir/CpG_rates_@{[$which_sub]}_test_cov_vf.txt @{[$path]}/@{[$modelfile]}_@{[$which_sub]}.CVout";
    }
}
close(IN);

