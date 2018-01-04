#!/usr/bin/perl -w

if (scalar(@ARGV) == 4) {
    $whichsub = shift(@ARGV);
    $CpGflag = shift(@ARGV);
    $infile = shift(@ARGV);
    $outputdir = shift(@ARGV);
} else {
    print "usage: %> rate_processor.pl [AC|AG|AT|CA|CG|CT] [CpGflag: 0|1|2] ben_data_7mer_bayesian_test_training_AFR_10 ratefiles\n" or die;
    exit();
}

#grab CpG only if specified
if ($CpGflag == 0) {
    $CpGgrep = "'.......,'";
    $CpGname = "nonCpG";
} elsif ($CpGflag == 1) {
    $CpGgrep = "'...[C][^G]..,'";
    $CpGname = "nonCpG";
} elsif ($CpGflag == 2) {
    $CpGgrep = "'...[C][G]..,'";
    $CpGname = "CpG";
} else {
    exit();
}

#grep the substitution you asked for
@e = split '', $whichsub;
$subst_grep = "'^" . $e[0] . "," . "$e[1]'";

$cmd = "tail -n +4 " . $infile . " | ";
$cmd .= "grep " . $CpGgrep . " | ";
$cmd .= "grep " . $subst_grep . " | ";

$cmd_all = $cmd . "awk -F ' ' ' {print(\$2,\$3,\$1)} ' | ";
$cmd_train = $cmd . "awk -F ' ' ' {print(\$2,\$4,\$1)} ' | ";
$cmd_test = $cmd . "awk -F ' ' ' {print(\$2,\$5,\$1)} ' | ";

$next = "sed ' s/,/ /g' | awk -F ' ' ' {print(\$4\"->\"\$5,\$1,\$2,\$3)} ' | sort -k4 -r ";

$cmd_all .= $next;
$cmd_train .= $next;
$cmd_test .= $next;

$cmd_all .= ">" . $outputdir . "/" . $CpGname . "_rates_" . $e[0] . "-" . $e[1] . "_all.txt";
$cmd_train .= ">" . $outputdir . "/" . $CpGname . "_rates_" . $e[0] . "-" . $e[1] . "_train.txt";
$cmd_test .= ">" . $outputdir . "/" . $CpGname . "_rates_" . $e[0] . "-" . $e[1] . "_test.txt";

print "$cmd_all\n";
print "$cmd_train\n";
print "$cmd_test\n";

system "$cmd_all";
system "$cmd_train";
system "$cmd_test";
