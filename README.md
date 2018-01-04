#################
# mutvar_fwdRegr
This repo contains the forward Regression framework used to model substitution probabilities for 7-mer sequence context model, as described in Aggarwala and Voight (2015). 

############
#Objectives 

Explaining variability in substitution model (CpG/nonCpG) contexts via forward regression analysis

Round 2, update to capture removal of refseq and 1000G masked regions

By: BF Voight
Initially Created: 12.15.2014

Aim here is to take sequence context rates inferred from Varun's 7mer model
specifically looking at frequent substitutions in non-CpG contexts -- specifically C-T and A-G)
-- and develop a set of features which explain low/high variability

ideally, the broad hypothesis is that variability in rates of polymorphism
within these contexts depend on some unknown biological mechanism(s), but that
these are determined in part by the sequence context

# This README (pipeline) is broken down into several parts

1. Data Processing, creation of input files based on raw substitution probability tables
2. Model and Feature Selection
3. Making summary tables for features selected (e.g. Suppl. Table 7a, 7b)
4. "Decoding" the sequence annotation (binary 0/1 encoding to A/C/G/T nucleotides)
5. outputting "directional consistency" across different substitution classes
6. output predicted values for models (example being C-T in CpG context)
