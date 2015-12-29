library(lattice)
library(C50)
library(gmodels)
library(caret)

library(rattle)
dataset<-read.csv("/home/freestyler/BDA_project/Data/outfile.csv")
set.seed(42) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.8*nobs) # 800 observations
validate <- NULL
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 200 observations

# The following variable selections have been noted.

input <- c("duration", "credit", "rate", "age",
           "nocredit", "TNM_check_status", "TNM_history", "TNM_purpose",
           "TNM_bonds", "TNM_jobex", "TNM_s_status", "TNM_guarantor",
           "TNM_property", "TNM_install", "TNM_house", "TNM_job",
           "TNM_ph", "TNM_nri")

numeric <- c("duration", "credit", "rate", "age",
             "nocredit", "TNM_check_status", "TNM_history", "TNM_purpose",
             "TNM_bonds", "TNM_jobex", "TNM_s_status", "TNM_guarantor",
             "TNM_property", "TNM_install", "TNM_house", "TNM_job",
             "TNM_ph", "TNM_nri")

categoric <- NULL

target  <- "R01_credibility"
risk    <- NULL
ident   <- NULL
ignore  <- c("residence", "liable")
weights <- NULL



#============================================================
# Rattle timestamp: 2015-10-11 00:31:44 x86_64-pc-linux-gnu 

# Decision Tree 

# The 'rpart' package provides the 'rpart' function.

library(rpart, quietly=TRUE)

# Reset the random number seed to obtain the same results each time.

set.seed(crv$seed)

# Build the Decision Tree model.

rpart <- rpart(R01_credibility ~ .,
                   data=dataset[train, c(input, target)],
                   method="class",
                   parms=list(split="information"),
                   control=rpart.control(usesurrogate=0, 
                                         maxsurrogate=0))

# Generate a textual view of the Decision Tree model.

print(rpart)
printcp(rpart)
cat("\n")

# Time taken: 0.09 secs

# List the rules from the tree using a Rattle support function.

asRules(rpart)

#============================================================
# Rattle timestamp: 2015-10-11 00:31:55 x86_64-pc-linux-gnu 

# Plot the resulting Decision Tree. 

# We use the rpart.plot package.
library(rpart.plot)	
prp(rpart)
text(rpart)
fancyRpartPlot(rpart, main="Decision Tree  $ R01_credibility")

#============================================================
# Rattle timestamp: 2015-10-11 00:31:59 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# Generate an Error Matrix for the Decision Tree model.

# Obtain the response from the Decision Tree model.

pr <- predict(rpart, newdata=dataset[test, c(input, target)], type="class")

# Generate the confusion matrix showing counts.

table(dataset[test, c(input, target)]$R01_credibility, pr,
      dnn=c("Actual", "Predicted"))

# Generate the confusion matrix showing proportions.

pcme <- function(actual, cl)
{
  x <- table(actual, cl)
  tbl <- cbind(round(x/length(actual), 2),
               Error=round(c(x[1,2]/sum(x[1,]),
                             x[2,1]/sum(x[2,])), 2))
  names(attr(tbl, "dimnames")) <- c("Actual", "Predicted")
  return(tbl)
};
pcme(dataset[test, c(input, target)]$R01_credibility, pr)

# Calculate the overall error percentage.

overall <- function(x)
{
  if (nrow(x) == 2) 
    cat((x[1,2] + x[2,1]) / sum(x)) 
  else
    cat(1 - (x[1,rownames(x)]) / sum(x))
} 
overall(table(pr, dataset[test, c(input, target)]$R01_credibility,  
              dnn=c("Predicted", "Actual")))

# Calculate the averaged class error percentage.

avgerr <- function(x) 
  cat(mean(c(x[1,2], x[2,1]) / apply(x, 1, sum))) 
avgerr(table(pr, dataset[test, c(input, target)]$R01_credibility,  
             dnn=c("Predicted", "Actual")))

#============================================================
# Rattle timestamp: 2015-10-11 00:32:05 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# ROC Curve: requires the ROCR package.

library(ROCR)

# ROC Curve: requires the ggplot2 package.

library(ggplot2, quietly=TRUE)

# Generate an ROC Curve for the rpart model on outfile.csv [test].

pr <- predict(rpart, newdata=dataset[test, c(input, target)])[,2]

# Remove observations with missing target.

no.miss   <- na.omit(dataset[test, c(input, target)]$R01_credibility)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(pr[-miss.list], no.miss)
} else
{
  pred <- prediction(pr, no.miss)
}

pe <- performance(pred, "tpr", "fpr")
au <- performance(pred, "auc")@y.values[[1]]
pd <- data.frame(fpr=unlist(pe@x.values), tpr=unlist(pe@y.values))
p <- ggplot(pd, aes(x=fpr, y=tpr))
p <- p + geom_line(colour="red")
p <- p + xlab("False Positive Rate") + ylab("True Positive Rate")
p <- p + ggtitle("ROC Curve Decision Tree outfile.csv [test] R01_credibility")
p <- p + theme(plot.title=element_text(size=10))
p <- p + geom_line(data=data.frame(), aes(x=c(0,1), y=c(0,1)), colour="grey")
p <- p + annotate("text", x=0.50, y=0.00, hjust=0, vjust=0, size=5,
                  label=paste("AUC =", round(au, 2)))
print(p)

# Calculate the area under the curve for the plot.

# Remove observations with missing target.

no.miss   <- na.omit(dataset[test, c(input, target)]$R01_credibility)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(pr[-miss.list], no.miss)
} else
{
  pred <- prediction(pr, no.miss)
}
performance(pred, "auc")

#============================================================
# Rattle timestamp: 2015-10-11 00:32:24 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# Sensitivity/Specificity Plot: requires the ROCR package

library(ROCR)

# Generate Sensitivity/Specificity Plot for rpart model on outfile.csv [test].

pr <- predict(rpart, newdata=dataset[test, c(input, target)])[,2]

# Remove observations with missing target.

no.miss   <- na.omit(dataset[test, c(input, target)]$R01_credibility)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(pr[-miss.list], no.miss)
} else
{
  pred <- prediction(pr, no.miss)
}
plot(performance(pred, "sens", "spec"), col="#CC0000FF", lty=1, add=FALSE)


