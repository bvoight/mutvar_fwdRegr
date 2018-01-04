#!/usr/bin/perl -w

#count number of C or G bases
#report thermometer variables for position 1, 2, 3, 5, 6, and 7
#report the position-specific CG counts
# @ p1
# @ p2
# @ p5
# @ p6
# @ p2 non-ACG CG
# @ p6 non-ACG CG

#report the position-specific ACG
# @ p1
# @ p5

if (scalar(@ARGV) == 2) {
    $seq = shift(@ARGV);
    $ratefiledir = shift(@ARGV);
} else {
    print "usage: %>mk_nonCpG_covfile [A-G|C-T] ratefilesdir\n";
    exit();
}

#make the header
open OUT, ">header" or die;
print OUT "TYPE SEQ_REF SEQ_ALT RATE n_C.G p1_t1 p1_t2 p1_t3 p2_t1 p2_t2 p2_t3 p3_t1 p3_t2 p3_t3 p5_t1 p5_t2 p5_t3 p6_t1 p6_t2 p6_t3 p7_t1 p7_t2 p7_t3 p1_CG p2_CG p5_CG p6_CG p2_CG_woACG p6_CG_woACG p1_ACG p5_ACG\n";
close(OUT);

#all
system "./count_CpG.pl -s [CG] <$ratefiledir/nonCpG_rates_@{[$seq]}_all.txt >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.1";

system "./count_CpG.pl -bt 1 <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.1 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.2";
system "./count_CpG.pl -bt 2 <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.2 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.3";
system "./count_CpG.pl -bt 3 <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.3 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.4";
system "./count_CpG.pl -bt 5 <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.4 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.5";
system "./count_CpG.pl -bt 6 <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.5 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.6";
system "./count_CpG.pl -bt 7 <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.6 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.7";

system "./count_CpG.pl -s CG[ACGT]{5} <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.7 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.8";
system "./count_CpG.pl -s [ACGT]{1}CG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.8 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.9";
system "./count_CpG.pl -s [ACGT]{4}CG[ACGT]{1} <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.9 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.10";
system "./count_CpG.pl -s [ACGT]{5}CG <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.10 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.11";
system "./count_CpG.pl -s [CGT]{1}CG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.11 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.12";
system "./count_CpG.pl -s [ACGT]{4}[CGT]{1}CG <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.12 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.13";

system "./count_CpG.pl -s ACG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.13 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.14";
system "./count_CpG.pl -s [ACGT]{4}ACG <$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.14 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.15";

system "cat header $ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.15 >$ratefiledir/nonCpG_rates_@{[$seq]}_all_cov_vf.txt";
system "rm $ratefiledir/nonCpG_rates_@{[$seq]}_all_cov.txt.*";

#train
system "./count_CpG.pl -s [CG] <$ratefiledir/nonCpG_rates_@{[$seq]}_train.txt >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.1";

system "./count_CpG.pl -bt 1 <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.1 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.2";
system "./count_CpG.pl -bt 2 <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.2 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.3";
system "./count_CpG.pl -bt 3 <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.3 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.4";
system "./count_CpG.pl -bt 5 <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.4 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.5";
system "./count_CpG.pl -bt 6 <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.5 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.6";
system "./count_CpG.pl -bt 7 <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.6 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.7";

system "./count_CpG.pl -s CG[ACGT]{5} <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.7 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.8";
system "./count_CpG.pl -s [ACGT]{1}CG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.8 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.9";
system "./count_CpG.pl -s [ACGT]{4}CG[ACGT]{1} <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.9 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.10";
system "./count_CpG.pl -s [ACGT]{5}CG <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.10 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.11";
system "./count_CpG.pl -s [CGT]{1}CG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.11 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.12";
system "./count_CpG.pl -s [ACGT]{4}[CGT]{1}CG <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.12 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.13";

system "./count_CpG.pl -s ACG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.13 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.14";
system "./count_CpG.pl -s [ACGT]{4}ACG <$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.14 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.15";

system "cat header $ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.15 >$ratefiledir/nonCpG_rates_@{[$seq]}_train_cov_vf.txt";
system "rm $ratefiledir/nonCpG_rates_@{[$seq]}_train_cov.txt.*";

#test
system "./count_CpG.pl -s [CG] <$ratefiledir/nonCpG_rates_@{[$seq]}_test.txt >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.1";

system "./count_CpG.pl -bt 1 <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.1 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.2";
system "./count_CpG.pl -bt 2 <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.2 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.3";
system "./count_CpG.pl -bt 3 <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.3 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.4";
system "./count_CpG.pl -bt 5 <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.4 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.5";
system "./count_CpG.pl -bt 6 <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.5 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.6";
system "./count_CpG.pl -bt 7 <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.6 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.7";

system "./count_CpG.pl -s CG[ACGT]{5} <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.7 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.8";
system "./count_CpG.pl -s [ACGT]{1}CG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.8 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.9";
system "./count_CpG.pl -s [ACGT]{4}CG[ACGT]{1} <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.9 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.10";
system "./count_CpG.pl -s [ACGT]{5}CG <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.10 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.11";
system "./count_CpG.pl -s [CGT]{1}CG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.11 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.12";
system "./count_CpG.pl -s [ACGT]{4}[CGT]{1}CG <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.12 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.13";

system "./count_CpG.pl -s ACG[ACGT]{4} <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.13 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.14";
system "./count_CpG.pl -s [ACGT]{4}ACG <$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.14 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.15";

system "cat header $ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.15 >$ratefiledir/nonCpG_rates_@{[$seq]}_test_cov_vf.txt";
system "rm $ratefiledir/nonCpG_rates_@{[$seq]}_test_cov.txt.*";
