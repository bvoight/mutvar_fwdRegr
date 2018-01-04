## last modified: 09.20.2016
# - outputs summary countdown of left to select as forward steps proceed

library(leaps);
source("mutRate_intx.R");

print("usage: %> R --vanilla <CV_picker.R --args datafile_train bestmodelfile intxparamfile outfile");

#load arguments

args <- commandArgs();

if(length(args) != 8) {
  print("improper number of arguments specified. exiting");
  print("usage: %> R --vanilla <CV_picker.R --args stoprule-pval datafile_train bestmodelfile intxparamfile outfile");
  quit(save="no");
}

stop_th <- as.numeric(args[4]);
datafile <- args[5];
bestmodel <- args[6];
paramsfile <- args[7];
outfile <- args[8];

#datafile <- "nonCpG_rates_A-C_train_cov_vf.txt";
#bestmodel <- "tryit_2way";
#paramsfile <- "CVsel_3wayALL";
#outfile <- "tryit_3way";
#stop_th <- 0.001;

#obtain files
form <- intx_makeformula(bestmodel,"",0)
a <- read.table(file=datafile, header=T)
reg <- lm(form,data=a)
params <- read.table(file=paramsfile,header=F)

print(summary(reg));

continue <- 1;
reg_prev <- reg;
while (continue == 1) {
  list <- intx_getintxAIC(reg_prev,t(params))
  #print(list);
  print(paste("parameters left to select from (+1 for intercept): ",length(list[,1]))); #it's minus 1 for the intercept
  if (length(list[,1]) == 1) { # only intercept remains in list
    continue = 0;
  } else {

    this_form <- paste(". ~ . + ", list[2,1],sep="");
    reg_next <- update(reg_prev, this_form);
    print(anova(reg_prev, reg_next));
    p <- unlist(anova(reg_prev,reg_next)$Pr)[2];
    print(p);

    if (p > stop_th) {
      #best model stops at reg_prev
      continue = 0;
    } else {
      reg_prev <- reg_next;
    }
  }
  print(continue);
}

#output reg_prev params
write.table(labels(reg_prev),file=outfile,row.names=F,col.names=F,quote=F)










