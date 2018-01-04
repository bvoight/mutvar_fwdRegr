## last modified: 09.20.2016
## - checks for features in reg and filters them out of list for selection

intx_getintxAIC <- function(reg,params) {
  AIClist <- numeric();
  for (i in 1:length(params)) {
    # check if this feature has already been selected
    feat <- rownames(summary(reg)$coefficients);
    #print(feat);
    find <- gsub("[*]",":",params[i]);
    foundit <- grep(pattern = find,x=feat);
    if (length(foundit) != 0) { 
       #already selected parameter, don't add
       print(paste("already selected: ",feat[foundit]));
    } else {
      # have not selected this parameter.
      form <- paste(". ~ . + ", params[i],sep="");
      q <- update(reg, form);

      if (length(AIClist) == 0) {
        AIClist <- c(params[i],AIC(q),q$df.residual);
      } else {
        AIClist <- rbind(AIClist, c(params[i],AIC(q),q$df.residual));
      }
    }
  }  
  
  #order the list
  AIClist <- AIClist[order(AIClist[,2],decreasing=T),]; 

  #get details of the current model and put at the top
  AIClist <- rbind(c("<none>",AIC(reg),reg$df.residual), AIClist);

  #ordering list would be cool
  return(AIClist);
}

intx_makeformula <- function(filename,lab,flag=1) {
  if (flag == 1) {
    thisform <- paste(lab,"$RATE",sep="");
  } else { 
    thisform <- paste(lab,"RATE",sep="");
  }
  z <- read.table(file=filename,header=F);
  for (i in 1:length(z[,1])) {
     if (i == 1) {
       thisform <- paste(thisform, " ~ ",sep="");
     } else {
       thisform <- paste(thisform, " + ",sep="");
     }
     thisform <- paste(thisform,z[i,],sep="");
  }
  return(thisform);
}

intx_scan_2way <- function(x,lab) {
  result <- NA;
    for (p in c(1,2,3,5,6,7)) {
      for (q in c(1,2,3,5,6,7)) {
        if (p < q) {
          for (i in 1:3) {
            for (j in 1:3) {
               var_todo <- paste(lab,"$p",p,"_t",i,":",lab,"$p",q,"_t",j,sep="");
               var_togrep <- paste(lab,"\\$p",p,"_t",i,":",lab,"\\$p",q,"_t",j,sep="");
               thisform <- as.formula(paste("x$RATE ~
               x$p1_t1 + x$p1_t2 + x$p1_t3 +
               x$p2_t1 + x$p2_t2 + x$p2_t3 +
               x$p3_t1 + x$p3_t2 + x$p3_t3 +
               x$p5_t1 + x$p5_t2 + x$p5_t3 +
               x$p6_t1 + x$p6_t2 + x$p6_t3 +
               x$p7_t1 + x$p7_t2 + x$p7_t3 + ",
               var_todo, sep=""))
               #print(thisform);
               reg_temp <- lm(thisform);
               #print(summary(reg_temp));
               idx <- grep(var_togrep,variable.names(reg_temp));
               #print(idx)
               if (length(idx) == 0) { #not found, set to NA.
                  idx <- grep(var_togrep,variable.names(reg_temp,full=TRUE));
                  temp <- as.matrix(t(c(NA,NA,NA,NA)));
               } else {
                  temp <- as.matrix(t(as.numeric(sprintf("%1.4g",summary(reg_temp)$coefficients[idx,1:4]))))
               }
               #print(temp)
               row.names(temp) <- variable.names(reg_temp,full=TRUE)[idx];
               if (is.na(result[1])) {
                 result <- temp;
               } else {
                 result <- rbind(result,temp);
               }
            }
          }
        }
      }
    }
    
  colnames(result) <- colnames(summary(reg_temp)$coefficients)
  return(result);
}

intx_scan_3way <- function(x,lab) {
  result <- NA;
   for (p in c(1,2,3,5,6,7)) {
    for (q in c(1,2,3,5,6,7)) {
      for (r in c(1,2,3,5,6,7)) {
        if (p < q && q < r) {
          for (i in 1:3) {
            for (j in 1:3) {
	      for (k in 1:3) {
                 var_todo <- paste(lab,"$p",p,"_t",i,":",lab,"$p",q,"_t",j,":",lab,"$p",r,"_t",k,sep="");
                 var_togrep <- paste(lab,"\\$p",p,"_t",i,":",lab,"\\$p",q,"_t",j,":",lab,"\\$p",r,"_t",k,sep="");
                 thisform <- as.formula(paste("x$RATE ~
                 x$p1_t1 + x$p1_t2 + x$p1_t3 +
                 x$p2_t1 + x$p2_t2 + x$p2_t3 +
                 x$p3_t1 + x$p3_t2 + x$p3_t3 +
                 x$p5_t1 + x$p5_t2 + x$p5_t3 +
                 x$p6_t1 + x$p6_t2 + x$p6_t3 +
                 x$p7_t1 + x$p7_t2 + x$p7_t3 + ",
                 var_todo, sep=""))
                 #print(thisform);
                 reg_temp <- lm(thisform);
                 #print(summary(reg_temp));
                 idx <- grep(var_togrep,variable.names(reg_temp));
                 #print(idx)
                 if (length(idx) == 0) { #not found, set to NA.
                   idx <- grep(var_togrep,variable.names(reg_temp,full=TRUE));
                   temp <- as.matrix(t(c(NA,NA,NA,NA)));
                 } else {
                   temp <- as.matrix(t(as.numeric(sprintf("%1.4g",summary(reg_temp)$coefficients[idx,1:4]))))
                 }
                 #print(temp)
                 row.names(temp) <- variable.names(reg_temp,full=TRUE)[idx];
                 if (is.na(result[1])) {
                   result <- temp;
                 } else {
                   result <- rbind(result,temp);
                 }
	      }
            }
          }
        }
      }
    }
  }
  
  colnames(result) <- colnames(summary(reg_temp)$coefficients)
  return(result);  
}

intx_scan_4way <- function(x,lab) {
  result <- NA;
    for (p in c(1,2,3,5,6,7)) {
     for (q in c(1,2,3,5,6,7)) {
      for (r in c(1,2,3,5,6,7)) {
        for (s in c(1,2,3,5,6,7)) {
          if (p < q && q < r && r < s) {
            for (i in 1:3) {
              for (j in 1:3) {
	        for (k in 1:3) {
		  for (l in 1:3) {
                    var_todo <- paste(lab,"$p",p,"_t",i,":",lab,"$p",q,"_t",j,":",lab,"$p",r,"_t",k,":",lab,"$p",s,"_t",l,sep="");
                     var_togrep <- paste(lab,"\\$p",p,"_t",i,":",lab,"\\$p",q,"_t",j,":",lab,"\\$p",r,"_t",k,":",lab,"\\$p",s,"_t",l,sep="");
                     thisform <- as.formula(paste("x$RATE ~
                     x$p1_t1 + x$p1_t2 + x$p1_t3 +
                     x$p2_t1 + x$p2_t2 + x$p2_t3 +
                     x$p3_t1 + x$p3_t2 + x$p3_t3 +
                     x$p5_t1 + x$p5_t2 + x$p5_t3 +
                     x$p6_t1 + x$p6_t2 + x$p6_t3 +
                     x$p7_t1 + x$p7_t2 + x$p7_t3 + ",
                     var_todo, sep=""))
                     #print(thisform);
                     reg_temp <- lm(thisform);
                     #print(summary(reg_temp));
                     idx <- grep(var_togrep,variable.names(reg_temp));
                     #print(idx)
                     if (length(idx) == 0) { #not found, set to NA.
                       idx <- grep(var_togrep,variable.names(reg_temp,full=TRUE));
                       temp <- as.matrix(t(c(NA,NA,NA,NA)));
                     } else {
                       temp <- as.matrix(t(as.numeric(sprintf("%1.4g",summary(reg_temp)$coefficients[idx,1:4]))))
                     }
                     #print(temp)
                     row.names(temp) <- variable.names(reg_temp,full=TRUE)[idx];
                     if (is.na(result[1])) {
                       result <- temp;
                     } else {
                       result <- rbind(result,temp);
                     }
     		  }
	        }
              }
            }
          }
        }
      }
    }
  }

  colnames(result) <- colnames(summary(reg_temp)$coefficients)
  return(result);  
}

intx_scan_5way <- function(x,lab) {
  result <- NA;
    for (p in c(1,2,3,5,6,7)) {
     for (q in c(1,2,3,5,6,7)) {
      for (r in c(1,2,3,5,6,7)) {
       for (s in c(1,2,3,5,6,7)) {
	for (t in c(1,2,3,5,6,7)) { 
          if (p < q && q < r && r < s && s < t) {
            for (i in 1:3) {
              for (j in 1:3) {
	        for (k in 1:3) {
		  for (l in 1:3) {
		    for (m in 1:3) {
                      var_todo <- paste(lab,"$p",p,"_t",i,":",lab,"$p",q,"_t",j,":",lab,"$p",r,"_t",k,":",lab,"$p",s,"_t",l,":",lab,"$p",t,"_t",m,sep="");
                      var_togrep <- paste(lab,"\\$p",p,"_t",i,":",lab,"\\$p",q,"_t",j,":",lab,"\\$p",r,"_t",k,":",lab,"\\$p",s,"_t",l,":",lab,"\\$p",t,"_t",m,sep="");
                      thisform <- as.formula(paste("x$RATE ~
                      x$p1_t1 + x$p1_t2 + x$p1_t3 +
                      x$p2_t1 + x$p2_t2 + x$p2_t3 +
                      x$p3_t1 + x$p3_t2 + x$p3_t3 +
                      x$p5_t1 + x$p5_t2 + x$p5_t3 +
                      x$p6_t1 + x$p6_t2 + x$p6_t3 +
                      x$p7_t1 + x$p7_t2 + x$p7_t3 + ",
                      var_todo, sep=""))
                      #print(thisform);
                      reg_temp <- lm(thisform);
                      #print(summary(reg_temp));
                      idx <- grep(var_togrep,variable.names(reg_temp));
                      #print(idx)
                      if (length(idx) == 0) { #not found, set to NA.
                        idx <- grep(var_togrep,variable.names(reg_temp,full=TRUE));
                        temp <- as.matrix(t(c(NA,NA,NA,NA)));
                      } else {
                        temp <- as.matrix(t(as.numeric(sprintf("%1.4g",summary(reg_temp)$coefficients[idx,1:4]))))
                      }
                      #print(temp)
                      row.names(temp) <- variable.names(reg_temp,full=TRUE)[idx];
                      if (is.na(result[1])) {
                        result <- temp;
                      } else {
                        result <- rbind(result,temp);
                      }
		    } #end m
     		  } #end l
	        } #end k
              } #end j
            } #end i
          } #end [iteration check]
        }	  
      }
     }
    }
  }

  colnames(result) <- colnames(summary(reg_temp)$coefficients)
  return(result);  
}

intx_scan_6way <- function(x,lab) {
  result <- NA;
    for (p in c(1,2,3,5,6,7)) {
     for (q in c(1,2,3,5,6,7)) {
      for (r in c(1,2,3,5,6,7)) {
       for (s in c(1,2,3,5,6,7)) {
	for (t in c(1,2,3,5,6,7)) {
	 for (u in c(1,2,3,5,6,7)) { 
          if (p < q && q < r && r < s && s < t && t < u) {
            for (i in 1:3) {
              for (j in 1:3) {
	        for (k in 1:3) {
		  for (l in 1:3) {
		    for (m in 1:3) {
		      for (n in 1:3) {
                        var_todo <- paste(lab,"$p",p,"_t",i,":",lab,"$p",q,"_t",j,":",lab,"$p",r,"_t",k,":",lab,"$p",s,"_t",l,":",lab,"$p",t,"_t",m,":",lab,"$p",u,"_t",n,sep="");
                        var_togrep <- paste(lab,"\\$p",p,"_t",i,":",lab,"\\$p",q,"_t",j,":",lab,"\\$p",r,"_t",k,":",lab,"\\$p",s,"_t",l,":",lab,"\\$p",t,"_t",m,":",lab,"\\$p",u,"_t",n,sep="");
                        thisform <- as.formula(paste("x$RATE ~
                        x$p1_t1 + x$p1_t2 + x$p1_t3 +
                        x$p2_t1 + x$p2_t2 + x$p2_t3 +
                        x$p3_t1 + x$p3_t2 + x$p3_t3 +
                        x$p5_t1 + x$p5_t2 + x$p5_t3 +
                        x$p6_t1 + x$p6_t2 + x$p6_t3 +
                        x$p7_t1 + x$p7_t2 + x$p7_t3 + ",
                        var_todo, sep=""))
                        #print(thisform);
                        reg_temp <- lm(thisform);
                        #print(summary(reg_temp));
                        idx <- grep(var_togrep,variable.names(reg_temp));
                        #print(idx)
                        if (length(idx) == 0) { #not found, set to NA.
                          idx <- grep(var_togrep,variable.names(reg_temp,full=TRUE));
                          temp <- as.matrix(t(c(NA,NA,NA,NA)));
                        } else {
                          temp <- as.matrix(t(as.numeric(sprintf("%1.4g",summary(reg_temp)$coefficients[idx,1:4]))))
                        }
                        #print(temp)
                        row.names(temp) <- variable.names(reg_temp,full=TRUE)[idx];
                        if (is.na(result[1])) {
                          result <- temp;
                        } else {
                          result <- rbind(result,temp);
                        }
		     } #end n
		    } #end m
     		  } #end l
	        } #end k
              } #end j
            } #end i
          } #end [iteration check]
        }
       }
      }
     }
   }
  }

  colnames(result) <- colnames(summary(reg_temp)$coefficients)
  return(result);  
}
