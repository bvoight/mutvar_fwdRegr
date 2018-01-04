#!/usr/bin/perl -w

#first, count CG dimers.
#second, count ACG occurences
#third, count TACG occurences
#fourth, count number of C or G bases
#next, count number of A or T bases
#report thermometer variables for position 1, 2, 3, 6, and 7
#report the position-specific CG counts
# @ p1
# @ p2
# @ p6
# @ p2 non-ACG CG
#report the position-specific ACG
# @ p1
# @ p3

if (scalar(@ARGV) == 2) {
    $seq = shift(@ARGV);
    $ratefiledir = shift(@ARGV);
} else {
    print "usage: %>mk_$ratefiledir/CpG_covfile [C-T|C-A|C-G]\n";
    exit();
}

#make the header
open OUT, ">header" or die;
print OUT "TYPE SEQ_REF SEQ_ALT RATE n_CG n_ACG n_TACG n_C.G n_A.T p1_t1 p1_t2 p1_t3 p2_t1 p2_t2 p2_t3 p3_t1 p3_t2 p3_t3 p6_t1 p6_t2 p6_t3 p7_t1 p7_t2 p7_t3 p1_CG p2_CG p6_CG p2_CG_woACG p1_ACG p3_ACG\n";
close(OUT);

#all
system "./count_CpG.pl -s CG <$ratefiledir/CpG_rates_@{[$seq]}_all.txt >$ratefiledir/CpG_rates_@{[$seq]}_CGcnt.txt";
system "./count_CpG.pl -s ACG <$ratefiledir/CpG_rates_@{[$seq]}_CGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt.txt";
system "./count_CpG.pl -s TACG <$ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt_TACGcnt.txt";
system "./count_CpG.pl -s [CG] <$ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt_TACGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt_TACGcnt_pcCG.txt";
system "./count_CpG.pl -s [AT] <$ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt_TACGcnt_pcCG.txt >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.1";
system "./count_CpG.pl -bt 1 <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.1 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.2";
system "./count_CpG.pl -bt 2 <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.2 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.3";
system "./count_CpG.pl -bt 3 <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.3 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.4";
system "./count_CpG.pl -bt 6 <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.4 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.5";
system "./count_CpG.pl -bt 7 <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.5 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.6";
system "./count_CpG.pl -s CG[ACGT]{5} <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.6 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.7";
system "./count_CpG.pl -s [ACGT]{1}CG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.7 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.8";
system "./count_CpG.pl -s [ACGT]{5}CG <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.8 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.9";
system "./count_CpG.pl -s [CGT]{1}CG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.9 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.10";
system "./count_CpG.pl -s ACG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.10 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.11";
system "./count_CpG.pl -s [ACGT]{2}ACG[ACGT]{2} <$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.11 >$ratefiledir/CpG_rates_@{[$seq]}_cov.txt.12";
system "cat header $ratefiledir/CpG_rates_@{[$seq]}_cov.txt.12 >$ratefiledir/CpG_rates_@{[$seq]}_all_cov_vf.txt";

system "rm $ratefiledir/CpG_rates_@{[$seq]}_CGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt_TACGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_CGcnt_ACGcnt_TACGcnt_pcCG.txt $ratefiledir/CpG_rates_@{[$seq]}_cov.txt.*";

#train
system "./count_CpG.pl -s CG <$ratefiledir/CpG_rates_@{[$seq]}_train.txt >$ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt.txt";
system "./count_CpG.pl -s ACG <$ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt.txt";
system "./count_CpG.pl -s TACG <$ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt_TACGcnt.txt";
system "./count_CpG.pl -s [CG] <$ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt_TACGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt_TACGcnt_pcCG.txt";
system "./count_CpG.pl -s [AT] <$ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt_TACGcnt_pcCG.txt >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.1";
system "./count_CpG.pl -bt 1 <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.1 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.2";
system "./count_CpG.pl -bt 2 <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.2 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.3";
system "./count_CpG.pl -bt 3 <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.3 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.4";
system "./count_CpG.pl -bt 6 <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.4 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.5";
system "./count_CpG.pl -bt 7 <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.5 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.6";
system "./count_CpG.pl -s CG[ACGT]{5} <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.6 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.7";
system "./count_CpG.pl -s [ACGT]{1}CG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.7 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.8";
system "./count_CpG.pl -s [ACGT]{5}CG <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.8 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.9";
system "./count_CpG.pl -s [CGT]{1}CG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.9 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.10";
system "./count_CpG.pl -s ACG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.10 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.11";
system "./count_CpG.pl -s [ACGT]{2}ACG[ACGT]{2} <$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.11 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.12";
system "cat header $ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.12 >$ratefiledir/CpG_rates_@{[$seq]}_train_cov_vf.txt";

system "rm $ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt_TACGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_train_CGcnt_ACGcnt_TACGcnt_pcCG.txt $ratefiledir/CpG_rates_@{[$seq]}_train_cov.txt.*";

#test
system "./count_CpG.pl -s CG <$ratefiledir/CpG_rates_@{[$seq]}_test.txt >$ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt.txt";
system "./count_CpG.pl -s ACG <$ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt.txt";
system "./count_CpG.pl -s TACG <$ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt_TACGcnt.txt";
system "./count_CpG.pl -s [CG] <$ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt_TACGcnt.txt >$ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt_TACGcnt_pcCG.txt";
system "./count_CpG.pl -s [AT] <$ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt_TACGcnt_pcCG.txt >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.1";
system "./count_CpG.pl -bt 1 <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.1 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.2";
system "./count_CpG.pl -bt 2 <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.2 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.3";
system "./count_CpG.pl -bt 3 <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.3 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.4";
system "./count_CpG.pl -bt 6 <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.4 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.5";
system "./count_CpG.pl -bt 7 <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.5 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.6";
system "./count_CpG.pl -s CG[ACGT]{5} <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.6 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.7";
system "./count_CpG.pl -s [ACGT]{1}CG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.7 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.8";
system "./count_CpG.pl -s [ACGT]{5}CG <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.8 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.9";
system "./count_CpG.pl -s [CGT]{1}CG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.9 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.10";
system "./count_CpG.pl -s ACG[ACGT]{4} <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.10 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.11";
system "./count_CpG.pl -s [ACGT]{2}ACG[ACGT]{2} <$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.11 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.12";
system "cat header $ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.12 >$ratefiledir/CpG_rates_@{[$seq]}_test_cov_vf.txt";

system "rm $ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt_TACGcnt.txt $ratefiledir/CpG_rates_@{[$seq]}_test_CGcnt_ACGcnt_TACGcnt_pcCG.txt $ratefiledir/CpG_rates_@{[$seq]}_test_cov.txt.*";
