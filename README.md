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
arg 2: the CpG Flag (set 0 if desire AC|AG|AT; set =1 if desire CA|CG|CT -ve CpG context, set =2 if desire CA|CG|CT +ve CpG context)
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
### CONFIRMED! reproduces to this point.


### 2. Model / Feature Selection

I've provide a listing of models given in the `modelfiles` directory

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
The nomenclature I'm using here is
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

Finally, for specific models that fix CpG context, this means that p4 is always set to "G". in that case, you don't need to include this as a variable, and there will be no interaction terms possible with that position, i.e., the model space is 'reduced'. I have provided those listings for you.

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

