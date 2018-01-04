#mutRate_CV_summary.R

#BF Voight
#last mod: 08.27.2014

#automated script to perform CV and generate relavent stats 
#v10: no predictors
#v11: all first order terms

#load libraries and packages
library(DAAG);
source("mutRate_intx.R");

print("usage: %> R --vanilla <mutRate_CV_summary.R --args datafile_train datafile_test outfile");

#load arguments

args <- commandArgs();

if(length(args) != 7) {
  print("improper number of arguments specified. exiting");
  print("usage: %> R --vanilla <mutRate_CV_summary.R --args paramfile datafile_train datafile_test outfile");
  quit(save="no");
}

#=0 means not CG. all p5 positions are added
#=1 means is CG, not using nCpG sequences. Meaning p5_t2 is excluded
#=2 means is a CG, and in a CpG. Meaning all p5 varibles are excluded. 
paramfile <- args[4];
datafile_train <- args[5];
datafile_test <- args[6];
outfile <- args[7];

#paramfile <- "CVsel_1wayCT";
#datafile_train <- "nonCpG_rates_C-T_train_cov_vf.txt"; 
#datafile_test  <- "nonCpG_rates_C-T_test_cov_vf.txt"; 
#outfile <- "CV_R_tester";

#########
#GET DATA
tr <- read.table(file=datafile_train,header=T)
ts <- read.table(file=datafile_test,header=T)

#ensure lists are all in the same order
x <- tr[order(tr[,2]),]
tr <- x
x <- ts[order(ts[,2]),]
ts <- x

#######
#GET FORMULAS
form <- intx_makeformula(paramfile,"",flag=0);

##########
#DO REGRESSION
reg <- lm(form, data=tr);

##########
#GET STATS

#MSE via CV
daag <- CVlm(df=tr,m=8,form.lm=reg)
MSE <- attr(daag,"ms")

#AIC
AIC <- AIC(reg);

#Rsq-adj
rsq <- summary(reg)$adj.r.squared;

#prediction to TEST data
pred_tr <- cbind(tr$SEQ_REF,predict(reg,interval=c("prediction")));
reg_to_test <- lm(RATE ~ as.numeric(pred_tr[,2]),data=ts);
AIC_to_test <- AIC(reg_to_test);
rsq_to_test <- summary(reg_to_test)$adj.r.squared

output <- cbind(AIC,MSE,rsq,AIC_to_test,rsq_to_test);

#output details of the best model
write.table(output,file=outfile,row.names=F,col.names=T,quote=F)
