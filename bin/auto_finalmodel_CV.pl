#!/usr/bin/perl -w
 
$sig_th = 0.001;

if (scalar(@ARGV) == 5) {
    $CTmode = shift(@ARGV);
    $sub = shift(@ARGV);
    $path = shift(@ARGV);
    $ratefiledir = shift(@ARGV);
    $modelpath = shift(@ARGV);
} else {
    print "usage: %> auto_finalmodel_CV.pl [0|1|2] [A-C|A-G|A-T|C-A|C-G|C-T] path ratefiledir modelpath\n";
    exit();
}

#prep the model file list to generate CV stats for
open OUT, ">@{[$path]}/modellist_@{[$sub]}" or die;

#run the following models in sequence
if ($CTmode == 0) { #nCpG: AC, AG, AT
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/nonCpG_rates_@{[$sub]}_train_cov_vf.txt $modelpath/CVsel_1wayALL $modelpath/CVsel_2wayALL @{[$path]}/tryit_2way >@{[$path]}/2way_nCpG_@{[$sub]}.Rout";
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/nonCpG_rates_@{[$sub]}_train_cov_vf.txt @{[$path]}/tryit_2way $modelpath/CVsel_3wayALL @{[$path]}/tryit_3way >@{[$path]}/3way_nCpG_@{[$sub]}.Rout";
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/nonCpG_rates_@{[$sub]}_train_cov_vf.txt @{[$path]}/tryit_3way $modelpath/CVsel_4wayALL @{[$path]}/tryit_4way >@{[$path]}/4way_nCpG_@{[$sub]}.Rout";

    # generate the generic model file
    print OUT "CVsel_0way\n";
    print OUT "CVsel_1wayALL\n";
    print OUT "CVsel_1_2wayALL\n";
    print OUT "CVsel_1_2_3wayALL\n";
    print OUT "CVsel_1_2_3_4wayALL\n";
   
} elsif ($CTmode == 1) { #nCpG: CA, CG, CT
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/nonCpG_rates_@{[$sub]}_train_cov_vf.txt $modelpath/CVsel_1wayCT $modelpath/CVsel_2wayCT @{[$path]}/tryit_2way >@{[$path]}/2way_nCpG_@{[$sub]}.Rout";
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/nonCpG_rates_@{[$sub]}_train_cov_vf.txt @{[$path]}/tryit_2way $modelpath/CVsel_3wayCT @{[$path]}/tryit_3way >@{[$path]}/3way_nCpG_@{[$sub]}.Rout";
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/nonCpG_rates_@{[$sub]}_train_cov_vf.txt @{[$path]}/tryit_3way $modelpath/CVsel_4wayCT @{[$path]}/tryit_4way >@{[$path]}/4way_nCpG_@{[$sub]}.Rout";

    # generate the generic model file
    print OUT "CVsel_0way\n";
    print OUT "CVsel_1wayCT\n";
    print OUT "CVsel_1_2wayCT\n";
    print OUT "CVsel_1_2_3wayCT\n";
    print OUT "CVsel_1_2_3_4wayCT\n";

} elsif ($CTmode == 2) { #CpG: CA, CG, CT
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/CpG_rates_@{[$sub]}_train_cov_vf.txt $modelpath/CVsel_1wayCpG $modelpath/CVsel_2wayCpG @{[$path]}/tryit_2way >@{[$path]}/2way_CpG_@{[$sub]}.Rout";
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/CpG_rates_@{[$sub]}_train_cov_vf.txt @{[$path]}/tryit_2way $modelpath/CVsel_3wayCpG @{[$path]}/tryit_3way >@{[$path]}/3way_CpG_@{[$sub]}.Rout";
    system "R --vanilla <model_picker.R --args $sig_th $ratefiledir/CpG_rates_@{[$sub]}_train_cov_vf.txt @{[$path]}/tryit_3way $modelpath/CVsel_4wayCpG @{[$path]}/tryit_4way >@{[$path]}/4way_CpG_@{[$sub]}.Rout";

    # generate the generic model file
    print OUT "CVsel_0way\n";
    print OUT "CVsel_1wayCpG\n";
    print OUT "CVsel_1_2wayCpG\n";
    print OUT "CVsel_1_2_3wayCpG\n";
    print OUT "CVsel_1_2_3_4wayCpG\n";

}

#add final models to run CV stats on
print OUT "tryit_2way\n";
print OUT "tryit_3way\n";
print OUT "tryit_4way\n";
close(OUT);

#run CV stats
system "./auto_CVsummary.pl $CTmode $sub @{[$path]}/modellist_@{[$sub]} $ratefiledir $path";

