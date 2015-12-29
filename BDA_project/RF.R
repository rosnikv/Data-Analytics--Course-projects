library(rattle)

# This log generally records the process of building a model. However, with very 
# little effort the log can be used to score a new dataset. The logical variable 
# 'building' is used to toggle between generating transformations, as when building 
# a model, and simply using the transformations, as when scoring a dataset.

building <- TRUE
scoring  <- ! building


# A pre-defined value is used to reset the random seed so that results are repeatable.

crv$seed <- 42 

#============================================================
# Rattle timestamp: 2015-10-11 17:30:28 x86_64-pc-linux-gnu 

# Load the data.

dataset <- read.csv("/home/freestyler/BDA_project/Data/outfile.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

#============================================================
# Rattle timestamp: 2015-10-11 17:30:29 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

set.seed(crv$seed) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.7*nobs) # 700 observations
validate <- sample(setdiff(seq_len(nrow(dataset)), train), 0.15*nobs) # 150 observations
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 150 observations

# The following variable selections have been noted.

input <- c("duration", "credit", "rate", "residence",
               "age", "nocredit", "liable", "TNM_check_status",
               "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
               "TNM_s_status", "TNM_guarantor", "TNM_property", "TNM_install",
               "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

numeric <- c("duration", "credit", "rate", "residence",
                 "age", "nocredit", "liable", "TNM_check_status",
                 "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
                 "TNM_s_status", "TNM_guarantor", "TNM_property", "TNM_install",
                 "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

categoric <- NULL

target  <- "R01_credibility"
risk    <- NULL
ident   <- NULL
ignore  <- NULL
weights <- NULL

#============================================================
# Rattle timestamp: 2015-10-11 17:30:42 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

set.seed(crv$seed) 
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

xtrain <- dataset[train,]
xnew <- dataset[-train,]
ytrain <- dataset$R01_credibility[train]
ynew <- dataset$R01_credibility[-train]


#============================================================
# Rattle timestamp: 2015-10-11 17:30:51 x86_64-pc-linux-gnu 

# Random Forest 

# The 'randomForest' package provides the 'randomForest' function.

library(randomForest, quietly=TRUE)

# Build the Random Forest model.

set.seed(crv$seed)
rf <- randomForest::randomForest(as.factor(R01_credibility) ~ .,
                                 data=dataset[sample,c(input, target)],
                                 ntree=500,
                                 mtry=4,
                                 importance=TRUE,
                                 na.action=randomForest::na.roughfix,
                                 replace=FALSE)

# Generate textual output of 'Random Forest' model.

rf
asRules(rf)

# The `pROC' package implements various AUC functions.

# Calculate the Area Under the Curve (AUC).

pROC::roc(rf$y, as.numeric(rf$predicted))

# Calculate the AUC Confidence Interval.

pROC::ci.auc(rf$y, as.numeric(rf$predicted))

# List the importance of the variables.

rn <- round(randomForest::importance(rf), 2)
rn[order(rn[,3], decreasing=TRUE),]

# Time taken: 2.26 secs

#============================================================
# Rattle timestamp: 2015-10-11 17:30:56 x86_64-pc-linux-gnu 

# Plot the relative importance of the variables.

randomForest::varImpPlot(rf, main="")
title(main="Variable Importance Random Forest outfile.csv",
      sub=paste("Rattle", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))

# Display tree number 1.

printRandomForests(rf, 1)

# Plot the OOB ROC curve.

library(verification)
aucc <- verification::roc.area(as.integer(as.factor(dataset[sample, target]))-1,
                               rf$votes[,2])$A
verification::roc.plot(as.integer(as.factor(dataset[sample, target]))-1,
                       rf$votes[,2], main="")
legend("bottomright", bty="n",
       sprintf("Area Under the Curve (AUC) = %1.3f", aucc))
title(main="OOB ROC Curve Random Forest outfile.csv",
      sub=paste("Rattle", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))

# Plot the error rate against the number of trees.

plot(rf, main="")
legend("topright", c("OOB", "0", "1"), text.col=1:6, lty=1:3, col=1:3)
title(main="Error Rates Random Forest outfile.csv",
      sub=paste("Rattle", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))

#============================================================
# Rattle timestamp: 2015-10-11 17:31:20 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# ROC Curve: requires the ROCR package.

library(ROCR)

# ROC Curve: requires the ggplot2 package.

library(ggplot2, quietly=TRUE)

# Generate an ROC Curve for the rf model on outfile.csv [test].

pr <- predict(rf, newdata=na.omit(dataset[test, c(input, target)]), type="prob")[,2]

# Remove observations with missing target.

no.miss   <- na.omit(na.omit(dataset[test, c(input, target)])$R01_credibility)
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
p <- p + ggtitle("ROC Curve Random Forest outfile.csv [test] R01_credibility")
p <- p + theme(plot.title=element_text(size=10))
p <- p + geom_line(data=data.frame(), aes(x=c(0,1), y=c(0,1)), colour="grey")
p <- p + annotate("text", x=0.50, y=0.00, hjust=0, vjust=0, size=5,
                  label=paste("AUC =", round(au, 2)))
print(p)

# Calculate the area under the curve for the plot.


# Remove observations with missing target.

no.miss   <- na.omit(na.omit(dataset[test, c(input, target)])$R01_credibility)
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
# Rattle timestamp: 2015-10-11 17:31:24 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# Generate an Error Matrix for the Random Forest model.

# Obtain the response from the Random Forest model.

pr <- predict(rf, newdata=na.omit(dataset[test, c(input, target)]))

# Generate the confusion matrix showing counts.

table(na.omit(dataset[test, c(input, target)])$R01_credibility, pr,
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
pcme(na.omit(dataset[test, c(input, target)])$R01_credibility, pr)

# Calculate the overall error percentage.

overall <- function(x)
{
  if (nrow(x) == 2) 
    cat((x[1,2] + x[2,1]) / sum(x)) 
  else
    cat(1 - (x[1,rownames(x)]) / sum(x))
} 
overall(table(pr, na.omit(dataset[test, c(input, target)])$R01_credibility,  
              dnn=c("Predicted", "Actual")))

# Calculate the averaged class error percentage.

avgerr <- function(x) 
  cat(mean(c(x[1,2], x[2,1]) / apply(x, 1, sum))) 
avgerr(table(pr, na.omit(dataset[test, c(input, target)])$R01_credibility,  
             dnn=c("Predicted", "Actual")))

#============================================================
# Rattle timestamp: 2015-10-11 17:31:29 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# Sensitivity/Specificity Plot: requires the ROCR package

library(ROCR)

# Generate Sensitivity/Specificity Plot for rf model on outfile.csv [test].

pr <- predict(rf, newdata=na.omit(dataset[test, c(input, target)]), type="prob")[,2]

# Remove observations with missing target.

no.miss   <- na.omit(na.omit(dataset[test, c(input, target)])$R01_credibility)
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
