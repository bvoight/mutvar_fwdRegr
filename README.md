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

#this matches (expected # of contexts is (4^7 * 3)/2 = 24576
#      (+1 header line: the header)
#      (+2 header line: which chromosomes selected for training/testing)

####
#First, run script to process all substitution classes

usage: %> rate_processor.pl [AC|AG|AT|CA|CG|CT] [CpGflag: 0|1|2] ben_data_7mer_bayesian_test_training_AFR_10 ratefiles

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

