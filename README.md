# mutvar_fwdRegr
This repo contains the forward Regression framework used to model substitution probabilities for 7-mer sequence context model,
 as described in Aggarwala and Voight (2015). 

### Objectives 

Explaining variability in substitution model (CpG/nonCpG) contexts via forward regression analysis

Round 2, update to capture removal of refseq and 1000G masked regions

By: BF Voight

Initially Created: 12.15.2014

Aim here is to take sequence context rates inferred from Varun's 7mer model specifically looking at frequent substitutions in non-CpG contexts -- specifically C-T and A-G) -- and develop a set of features which explain low/high variability

ideally, the broad hypothesis is that variability in rates of polymorphism within these contexts depend on some unknown biological mechanism(s), but that these are determined in part by the sequence context

### This README (pipeline) is broken down into several parts

1. Data Processing, creation of input files based on raw substitution probability tables
2. Model and Feature Selection
3. Making summary tables for features selected (e.g. Suppl. Table 7a, 7b)
4. "Decoding" the sequence annotation (binary 0/1 encoding to A/C/G/T nucleotides)
5. outputting "directional consistency" across different substitution classes
6. output predicted values for models (example being C-T in CpG context)

### 1. Data Processing

On the RAW data file:

```` 
raw_data/ben_data_7mer_bayesian_test_training_AFR_10
````

This file contains a set of substitution probabilities:
- for each type of substitution class
- for each 7-mer sequence context
- either for all chromosomes (autosome_rate), even chromosomes (training) and odd chromosomes (testing).
- estimated using the AFR continental group, excluding admixed samples, described in Aggarwala and Voight (2015). 

````
wc raw_data/ben_data_7mer_bayesian_test_training_AFR_10
  24579  147462 1879666 ben_data_7mer_bayesian_test_training_AFR_10
````

This matches (expected # of contexts is (4^7 * 3)/2 = 24576
- (+1 header line: the header)
- (+2 header line: which chromosomes selected for training/testing)

### Now, run script to process all substitution classes

````
usage: %> rate_processor.pl [AC|AG|AT|CA|CG|CT] 
       	  		    [0|1|2]       
       			    raw_data/ben_data_7mer_bayesian_test_training_AFR_10 
			    ratefiles

arg 1: The substitution class of interest
arg 2: the CpG Flag (set 0 if desire AC|AG|AT; set =1 if desire CA|CG|CT -ve CpG context, 
       set =2 if desire CA|CG|CT +ve CpG context)
arg 3: the substitution probability table
arg 4: the directory to output the summary results files
````

````
### A to C/G/T substitutions [CpG = FALSE]
./rate_processor.pl AC 0 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles
./rate_processor.pl AG 0 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles
./rate_processor.pl AT 0 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles

### C to A/G/T substitutions [CpG = FALSE]
./rate_processor.pl CA 1 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles
./rate_processor.pl CG 1 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles
./rate_processor.pl CT 1 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles

### C to A/G/T substitutions [CpG = TRUE]
./rate_processor.pl CA 2 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles
./rate_processor.pl CG 2 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles
./rate_processor.pl CT 2 raw_data/ben_data_7mer_bayesian_test_training_AFR_10 ratefiles
````

### Next, make the input files for R  
````
usage: %>mk_nonCpG_covfile [A-G|C-T] ratefilesdir
usage: %>mk_CpG_covfile.pl [C-T|C-A|C-G] ratefilesdir

arg 1: The substitution class of interest: A-C, A-G, A-T, C-A, C-T, C-G
arg 2: the directory to output the summary results files.
````

````
./mk_nonCpG_covfile.pl A-C ratefiles
./mk_nonCpG_covfile.pl A-G ratefiles
./mk_nonCpG_covfile.pl A-T ratefiles
./mk_nonCpG_covfile.pl C-A ratefiles
./mk_nonCpG_covfile.pl C-T ratefiles
./mk_nonCpG_covfile.pl C-G ratefiles

./mk_CpG_covfile.pl C-A ratefiles
./mk_CpG_covfile.pl C-G ratefiles
./mk_CpG_covfile.pl C-T ratefiles
````

### 2. Model / Feature Selection

I've provide a listing of models given in the `modelfiles` directory.

If you looked at one of those files, e.g. 

````
head -n 20 modelfiles/CVsel_1_2wayALL

p1_t1
p1_t2
p1_t3
p2_t1
p2_t2
p2_t3
p3_t1
p3_t2
p3_t3
p5_t1
p5_t2
p5_t3
p6_t1
p6_t2
p6_t3
p7_t1
p7_t2
p7_t3
p2_t1*p3_t1
p6_t3*p7_t3
...
````
To remind you of how the model is encoded: Each position (pX) is defined by three variables (tY), which then defined the nucleotide state for each position of the sequence context. You might ask "couldn't you code this with two variables?" Write it out - you'll see that the T state is "1 1" which is not quite what you want.

The nomenclature I'm using here is:
- pX - where X is 1,2,3 or 5,6,7 - this is the position of the nucletoide sequence context
- tY - where Y is 1,2 or 3 - this denotes the "label" for the nucleotide at the position
- pX_tY*pX_tY - this denotes an 'interaction' term of the given position/nucleotide. 

I've encoded this as (arbitarily) as:
````
0 0 0 = A
0 0 1 = C
0 1 0 = G
1 0 0 = T
````
which means the "reference" nucleotide is "A", i.e., the change in probability of substitution which is estimated is change (C, G, or T) relative To A. 

Note that you can have multiple interactions (here, 2way, but 3 or 4 way, for example). The modelfiles will give the list all of these possible interactions

Finally, for specific models that fix CpG context, this means that p5 is always set to "G". in that case, you don't need to include this as a variable, and there will be no interaction terms possible with that position, i.e., the model space is 'reduced'. I have provided those listings for you.

And obviously, p4 is excluded since that is the position of the polymorphic site, and in our case, we're stratifying each substitution classes of which there are 9: A-C, A-G, A-T, C-A, C-G, C-T (non-CpG), and C-A, C-G, C-T (CpG).

### Note: 

By default, the P-value threshold for the F-test significance test to add terms is set at P = 0.001. 

If you want to change this to something more strict (more significant P-value leading to fewer features selected) or less strict (leading to more features selected), you would need to edit the script `auto_finalmodel_CV.pl` script and change `$sig_th = 0.01;` to any p-value you desire.

Yes, I realize the how ugly this is. Bad Coder, no Doughnut!! I apologize -- it's what happens when the PI has to code with limited time. :/ 

For what it's worth, I've set this to something less strict (P=0.01) and qualitatively find similar results for 7-mer modelling purposes.

````
usage: %> auto_finalmodel_CV.pl [0|1|2] [A-C|A-G|A-T|C-A|C-G|C-T] path ratefiledir modelpath

arg 1: CpG Flag: =2 if CA,CG,CT in CpG is desired, =1 if CA,CG,CT if non-CpG is desired, =0 if AC,AG,AT is desired
arg 2: the directory in which to store the results [e.g., 00_AC for AC; 01_CT for CT in CpG, etc.]
arg 3: path where ratefiles are stored
arg 4: path where modelfiles are stored 
````

This is a master script which:

1. calls `model_picker.R` in R, which is the unit that performs the actual feature selection steps.

This script performs the series of feature selection steps in turn, e.g. 0 interactions, 2-way, 3-way, then 4-way interactions.

This uses the *training* rate files to build the model out. 

This script also maintains the "hierarchy of constraint": when adding increasingly complex interactions (i.e., 3-way), if the lower order terms are not present (2-way, 1-way), it will add those, increase the degree of freedom, and performs the F-test in the context with those additional parameters.

2. calls `auto_CVsummary.pl`, which performs the cross validation and summary analysis automatically for all models developed.

this script calls `mutRate_CV_summary.R` in R, which is the unit that perform the actual cross validation experiments.

Here, 8-fold CV is performed. 

````
# Run model and feature building.
./auto_finalmodel_CV.pl 2 C-A 01_CA ratefiles modelfiles
./auto_finalmodel_CV.pl 2 C-G 01_CG ratefiles modelfiles
./auto_finalmodel_CV.pl 2 C-T 01_CT ratefiles modelfiles

./auto_finalmodel_CV.pl 1 C-A 00_CA ratefiles modelfiles
./auto_finalmodel_CV.pl 1 C-G 00_CG ratefiles modelfiles
./auto_finalmodel_CV.pl 1 C-T 00_CT ratefiles modelfiles

./auto_finalmodel_CV.pl 0 A-C 00_AC ratefiles modelfiles
./auto_finalmodel_CV.pl 0 A-G 00_AG ratefiles modelfiles
./auto_finalmodel_CV.pl 0 A-T 00_AT ratefiles modelfiles
````

File output produced: (X and Y are placeholders for nucleotides, e.g. C-A or C-T or A-C, etc.)

*.Rout: raw output from the given model_picker.R run
CVsel_*way_X-Y.CVout: Text file for the summary output results for cross validation (training phase) and results for holdout (testing phase) including ALL features

tryit_*way: the list of selected feature for the given interaction model (1way, 2way, 3way, or 4way). Format similar to files found in `modelfile` directory
tryit_*way_X-Y.CVout: Text file for the summary output results for cross validation (training phase) and results for holdout (testing phase) including the subset of *selected* features

modellist_X-Y: the list of all models that will be tested in cross validation

### CONFIRMED! reproduces to this point at least for: C-T CpGs, A-T, and C-T non-CpG

### 3. Making summary tables for features selected (e.g. Suppl. Table 7a, 7b)

Make summary tables for features selected (Table 7a, 7b)

````
## nonCpG
R --vanilla <output_allmodels.R --args 00_AC/tryit_4way ratefiles/nonCpG_rates_A-C_all_cov_vf.txt 00_AC/nCpG_A-C_modelsum_all.txt
R --vanilla <output_allmodels.R --args 00_AC/tryit_4way ratefiles/nonCpG_rates_A-C_train_cov_vf.txt 00_AC/nCpG_A-C_modelsum_train.txt
R --vanilla <output_allmodels.R --args 00_AC/tryit_4way ratefiles/nonCpG_rates_A-C_test_cov_vf.txt 00_AC/nCpG_A-C_modelsum_test.txt

R --vanilla <output_allmodels.R --args 00_AG/tryit_4way ratefiles/nonCpG_rates_A-G_all_cov_vf.txt 00_AG/nCpG_A-G_modelsum_all.txt
R --vanilla <output_allmodels.R --args 00_AG/tryit_4way ratefiles/nonCpG_rates_A-G_train_cov_vf.txt 00_AG/nCpG_A-G_modelsum_train.txt
R --vanilla <output_allmodels.R --args 00_AG/tryit_4way ratefiles/nonCpG_rates_A-G_test_cov_vf.txt 00_AG/nCpG_A-G_modelsum_test.txt

R --vanilla <output_allmodels.R --args 00_AT/tryit_4way ratefiles/nonCpG_rates_A-T_all_cov_vf.txt 00_AT/nCpG_A-T_modelsum_all.txt
R --vanilla <output_allmodels.R --args 00_AT/tryit_4way ratefiles/nonCpG_rates_A-T_train_cov_vf.txt 00_AT/nCpG_A-T_modelsum_train.txt
R --vanilla <output_allmodels.R --args 00_AT/tryit_4way ratefiles/nonCpG_rates_A-T_test_cov_vf.txt 00_AT/nCpG_A-T_modelsum_test.txt

R --vanilla <output_allmodels.R --args 00_CA/tryit_4way ratefiles/nonCpG_rates_C-A_all_cov_vf.txt 00_CA/nCpG_C-A_modelsum_all.txt
R --vanilla <output_allmodels.R --args 00_CA/tryit_4way ratefiles/nonCpG_rates_C-A_train_cov_vf.txt 00_CA/nCpG_C-A_modelsum_train.txt
R --vanilla <output_allmodels.R --args 00_CA/tryit_4way ratefiles/nonCpG_rates_C-A_test_cov_vf.txt 00_CA/nCpG_C-A_modelsum_test.txt

R --vanilla <output_allmodels.R --args 00_CG/tryit_4way ratefiles/nonCpG_rates_C-G_all_cov_vf.txt 00_CG/nCpG_C-G_modelsum_all.txt
R --vanilla <output_allmodels.R --args 00_CG/tryit_4way ratefiles/nonCpG_rates_C-G_train_cov_vf.txt 00_CG/nCpG_C-G_modelsum_train.txt
R --vanilla <output_allmodels.R --args 00_CG/tryit_4way ratefiles/nonCpG_rates_C-G_test_cov_vf.txt 00_CG/nCpG_C-G_modelsum_test.txt

R --vanilla <output_allmodels.R --args 00_CT/tryit_4way ratefiles/nonCpG_rates_C-T_all_cov_vf.txt 00_CT/nCpG_C-T_modelsum_all.txt
R --vanilla <output_allmodels.R --args 00_CT/tryit_4way ratefiles/nonCpG_rates_C-T_train_cov_vf.txt 00_CT/nCpG_C-T_modelsum_train.txt
R --vanilla <output_allmodels.R --args 00_CT/tryit_4way ratefiles/nonCpG_rates_C-T_test_cov_vf.txt 00_CT/nCpG_C-T_modelsum_test.txt

## CpG
######NOTE: for this substitution class (C-A), the best model was "all first + 2 way via feature selection" (tryit_2way)
R --vanilla <output_allmodels.R --args 01_CA/tryit_2way ratefiles/CpG_rates_C-A_all_cov_vf.txt 01_CA/CpG_C-A_modelsum_all.txt
R --vanilla <output_allmodels.R --args 01_CA/tryit_2way ratefiles/CpG_rates_C-A_train_cov_vf.txt 01_CA/CpG_C-A_modelsum_train.txt
R --vanilla <output_allmodels.R --args 01_CA/tryit_2way ratefiles/CpG_rates_C-A_test_cov_vf.txt 01_CA/CpG_C-A_modelsum_test.txt

R --vanilla <output_allmodels.R --args 01_CG/tryit_4way ratefiles/CpG_rates_C-G_all_cov_vf.txt 01_CG/CpG_C-G_modelsum_all.txt
R --vanilla <output_allmodels.R --args 01_CG/tryit_4way ratefiles/CpG_rates_C-G_train_cov_vf.txt 01_CG/CpG_C-G_modelsum_train.txt
R --vanilla <output_allmodels.R --args 01_CG/tryit_4way ratefiles/CpG_rates_C-G_test_cov_vf.txt 01_CG/CpG_C-G_modelsum_test.txt

R --vanilla <output_allmodels.R --args 01_CT/tryit_4way ratefiles/CpG_rates_C-T_all_cov_vf.txt 01_CT/CpG_C-T_modelsum_all.txt
R --vanilla <output_allmodels.R --args 01_CT/tryit_4way ratefiles/CpG_rates_C-T_train_cov_vf.txt 01_CT/CpG_C-T_modelsum_train.txt
R --vanilla <output_allmodels.R --args 01_CT/tryit_4way ratefiles/CpG_rates_C-T_test_cov_vf.txt 01_CT/CpG_C-T_modelsum_test.txt

````

### 4. "Decoding" the sequence annotation (binary 0/1 encoding to A/C/G/T nucleotides)

````
./R_param_decoder.pl <00_AC/nCpG_A-C_modelsum_all.txt >00_AC/nCpG_A-C_modelsum_all_bpseq.txt
./R_param_decoder.pl <00_AG/nCpG_A-G_modelsum_all.txt >00_AG/nCpG_A-G_modelsum_all_bpseq.txt
./R_param_decoder.pl <00_AT/nCpG_A-T_modelsum_all.txt >00_AT/nCpG_A-T_modelsum_all_bpseq.txt
./R_param_decoder.pl <00_CA/nCpG_C-A_modelsum_all.txt >00_CA/nCpG_C-A_modelsum_all_bpseq.txt
./R_param_decoder.pl <00_CG/nCpG_C-G_modelsum_all.txt >00_CG/nCpG_C-G_modelsum_all_bpseq.txt
./R_param_decoder.pl <00_CT/nCpG_C-T_modelsum_all.txt >00_CT/nCpG_C-T_modelsum_all_bpseq.txt
./R_param_decoder.pl <01_CA/CpG_C-A_modelsum_all.txt >01_CA/CpG_C-A_modelsum_all_bpseq.txt
./R_param_decoder.pl <01_CG/CpG_C-G_modelsum_all.txt >01_CG/CpG_C-G_modelsum_all_bpseq.txt
./R_param_decoder.pl <01_CT/CpG_C-T_modelsum_all.txt >01_CT/CpG_C-T_modelsum_all_bpseq.txt

./R_param_decoder.pl <00_AC/nCpG_A-C_modelsum_train.txt >00_AC/nCpG_A-C_modelsum_train_bpseq.txt
./R_param_decoder.pl <00_AG/nCpG_A-G_modelsum_train.txt >00_AG/nCpG_A-G_modelsum_train_bpseq.txt
./R_param_decoder.pl <00_AT/nCpG_A-T_modelsum_train.txt >00_AT/nCpG_A-T_modelsum_train_bpseq.txt
./R_param_decoder.pl <00_CA/nCpG_C-A_modelsum_train.txt >00_CA/nCpG_C-A_modelsum_train_bpseq.txt
./R_param_decoder.pl <00_CG/nCpG_C-G_modelsum_train.txt >00_CG/nCpG_C-G_modelsum_train_bpseq.txt
./R_param_decoder.pl <00_CT/nCpG_C-T_modelsum_train.txt >00_CT/nCpG_C-T_modelsum_train_bpseq.txt
./R_param_decoder.pl <01_CA/CpG_C-A_modelsum_train.txt >01_CA/CpG_C-A_modelsum_train_bpseq.txt
./R_param_decoder.pl <01_CG/CpG_C-G_modelsum_train.txt >01_CG/CpG_C-G_modelsum_train_bpseq.txt
./R_param_decoder.pl <01_CT/CpG_C-T_modelsum_train.txt >01_CT/CpG_C-T_modelsum_train_bpseq.txt

./R_param_decoder.pl <00_AC/nCpG_A-C_modelsum_train.txt >00_AC/nCpG_A-C_modelsum_test_bpseq.txt
./R_param_decoder.pl <00_AG/nCpG_A-G_modelsum_test.txt >00_AG/nCpG_A-G_modelsum_test_bpseq.txt
./R_param_decoder.pl <00_AT/nCpG_A-T_modelsum_test.txt >00_AT/nCpG_A-T_modelsum_test_bpseq.txt
./R_param_decoder.pl <00_CA/nCpG_C-A_modelsum_test.txt >00_CA/nCpG_C-A_modelsum_test_bpseq.txt
./R_param_decoder.pl <00_CG/nCpG_C-G_modelsum_test.txt >00_CG/nCpG_C-G_modelsum_test_bpseq.txt
./R_param_decoder.pl <00_CT/nCpG_C-T_modelsum_test.txt >00_CT/nCpG_C-T_modelsum_test_bpseq.txt
./R_param_decoder.pl <01_CA/CpG_C-A_modelsum_test.txt >01_CA/CpG_C-A_modelsum_test_bpseq.txt
./R_param_decoder.pl <01_CG/CpG_C-G_modelsum_test.txt >01_CG/CpG_C-G_modelsum_test_bpseq.txt
./R_param_decoder.pl <01_CT/CpG_C-T_modelsum_test.txt >01_CT/CpG_C-T_modelsum_test_bpseq.txt
````

# Merge files into master

````
#nCpG
./mutsum_mergeem.pl 00_AC/nCpG_A-C_modelsum_all_bpseq.txt \
                    00_AG/nCpG_A-G_modelsum_all_bpseq.txt \
                    00_AT/nCpG_A-T_modelsum_all_bpseq.txt \
                    00_CA/nCpG_C-A_modelsum_all_bpseq.txt \
                    00_CG/nCpG_C-G_modelsum_all_bpseq.txt \
                    00_CT/nCpG_C-T_modelsum_all_bpseq.txt \
                    >finaltables/nCpG_sorted_featuretable_all.txt

./mutsum_mergeem.pl 00_AC/nCpG_A-C_modelsum_train_bpseq.txt \
                    00_AG/nCpG_A-G_modelsum_train_bpseq.txt \
                    00_AT/nCpG_A-T_modelsum_train_bpseq.txt \
                    00_CA/nCpG_C-A_modelsum_train_bpseq.txt \
                    00_CG/nCpG_C-G_modelsum_train_bpseq.txt \
                    00_CT/nCpG_C-T_modelsum_train_bpseq.txt \
                    >finaltables/nCpG_sorted_featuretable_train.txt

./mutsum_mergeem.pl 00_AC/nCpG_A-C_modelsum_test_bpseq.txt \
                    00_AG/nCpG_A-G_modelsum_test_bpseq.txt \
                    00_AT/nCpG_A-T_modelsum_test_bpseq.txt \
                    00_CA/nCpG_C-A_modelsum_test_bpseq.txt \
                    00_CG/nCpG_C-G_modelsum_test_bpseq.txt \
                    00_CT/nCpG_C-T_modelsum_test_bpseq.txt \
                    >finaltables/nCpG_sorted_featuretable_test.txt

## CpG
./mutsum_mergeem.pl 01_CA/CpG_C-A_modelsum_all_bpseq.txt \
                    01_CG/CpG_C-G_modelsum_all_bpseq.txt \
                    01_CT/CpG_C-T_modelsum_all_bpseq.txt \
                    >finaltables/CpG_sorted_featuretable_all.txt

./mutsum_mergeem.pl 01_CA/CpG_C-A_modelsum_train_bpseq.txt \
                    01_CG/CpG_C-G_modelsum_train_bpseq.txt \
                    01_CT/CpG_C-T_modelsum_train_bpseq.txt \
                    >finaltables/CpG_sorted_featuretable_train.txt

/mutsum_mergeem.pl 01_CA/CpG_C-A_modelsum_test_bpseq.txt \
                    01_CG/CpG_C-G_modelsum_test_bpseq.txt \
                    01_CT/CpG_C-T_modelsum_test_bpseq.txt \
                    >finaltables/CpG_sorted_featuretable_test.txt
````

### 5. outputting "directional consistency" across different substitution classes

````
#append directional consistency
./mutsum_dirconst.pl <finaltables/nCpG_sorted_featuretable_all.txt >finaltables/nCpG_sorted_featuretable_all_wdir.txt
./mutsum_dirconst.pl <finaltables/nCpG_sorted_featuretable_train.txt >finaltables/nCpG_sorted_featuretable_train_wdir.txt
./mutsum_dirconst.pl <finaltables/nCpG_sorted_featuretable_test.txt >finaltables/nCpG_sorted_featuretable_test_wdir.txt

./mutsum_dirconst.pl <finaltables/CpG_sorted_featuretable_all.txt >finaltables/CpG_sorted_featuretable_all_wdir.txt
./mutsum_dirconst.pl <finaltables/CpG_sorted_featuretable_train.txt >finaltables/CpG_sorted_featuretable_train_wdir.txt
./mutsum_dirconst.pl <finaltables/CpG_sorted_featuretable_test.txt >finaltables/CpG_sorted_featuretable_test_wdir.txt
````

````
#extract final columns and report tables
awk -F ' ' ' {print($1,$2,$3,$5,$7,$9,$11,$13,$15)} ' <finaltables/nCpG_sorted_featuretable_all_wdir.txt >finaltables/nCpG_featuretable_all_vf.txt
awk -F ' ' ' {print($1,$2,$3,$5,$7,$9,$11,$13,$15)} ' <finaltables/nCpG_sorted_featuretable_all_wdir.txt >finaltables/nCpG_featuretable_train_vf.txt
awk -F ' ' ' {print($1,$2,$3,$5,$7,$9,$11,$13,$15)} ' <finaltables/nCpG_sorted_featuretable_all_wdir.txt >finaltables/nCpG_featuretable_test_vf.txt

awk -F ' ' ' {print($1,$2,$3,$5,$7,$9)} ' <finaltables/CpG_sorted_featuretable_all_wdir.txt >finaltables/CpG_featuretable_all_vf.txt
awk -F ' ' ' {print($1,$2,$3,$5,$7,$9)} ' <finaltables/CpG_sorted_featuretable_all_wdir.txt >finaltables/CpG_featuretable_train_vf.txt
awk -F ' ' ' {print($1,$2,$3,$5,$7,$9)} ' <finaltables/CpG_sorted_featuretable_all_wdir.txt >finaltables/CpG_featuretable_test_vf.txt
````

### 6. output predicted values for models (example being C-T in CpG context)

#Note that the way this is done, is really for the "_10" set of data (train = even chromosomes, test = odd chromosomes)

#command line called:
````
R --vanilla --args 01_CT/tryit_4way ratefiles/CpG_rates_C-T_train_cov_vf.txt ratefiles/CpG_rates_C-T_test_cov_vf.txt CpG_C-T_train_predictRates.txt
````

````
#R code here for above command: 
library(DAAG);
source("mutRate_intx.R");
args <- commandArgs();

paramfile <- args[4];
datafile_train <- args[5];
datafile_test <- args[6];
outfile <- args[7];

tr <- read.table(file=datafile_train,header=T)
ts <- read.table(file=datafile_test,header=T)
x <- tr[order(tr[,2]),]
tr <- x
x <- ts[order(ts[,2]),]
ts <- x
form <- intx_makeformula(paramfile,"",flag=0);
reg <- lm(form, data=tr);

pred_tr <- cbind(as.character(tr$SEQ_REF), predict(reg,interval=c("prediction")));
write.table(pred_tr[,1:2],file=outfile,quote=F,row.names=F, col.names=F)
````
 
