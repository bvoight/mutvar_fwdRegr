source("mutRate_intx.R");

args <- commandArgs();
if(length(args) != 6) {
  print("improper number of arguments specified. exiting");
  print("usage: %> R --vanilla <output_allmodels.R --args paramfile datafile outfile");
  quit(save="no");
}

paramfile <- args[4];
datafile <- args[5];
outfile <- args[6];

#paramfile <- "00_CT/tryit_4way";
#datafile <- "nonCpG_rates_C-T_train_cov_vf.txt";
#outfile <- "00_CT/nCpG_C-T_modelsummary.txt";

########
#GET DATA
tr <- read.table(file=datafile,header=T)

#######
#GET FORMULA
form <- intx_makeformula(paramfile,"",flag=0);

##########
#DO REGRESSION
reg <- lm(form, data=tr);

##########
#OUTPUT MODEL
head <- cbind("PARAM","BETA","SE","TVAL","PVAL")
write.table(file=outfile,head,row.names=F,col.names=F,quote=F)
write.table(file=outfile,summary(reg)$coefficients,row.names=T,col.names=F,quote=F,append=T)