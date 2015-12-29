library(rattle)   # To access the weather dataset and utility commands.
library(magrittr) # For the %>% and %<>% operators.

building <- TRUE
scoring  <- ! building

crv$seed <- 42 

dataset <- read.csv("/home/freestyler/outfile_saved.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

set.seed(crv$seed) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.7*nobs) # 700 observations
validate <- sample(setdiff(seq_len(nrow(dataset)), train), 0.15*nobs) # 150 observations
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 150 observations


# The following variable selections have been noted.

input <- c("R01_credibility", "RRC_duration", "RRC_credit", "RRC_rate",
               "RRC_residence", "RRC_age", "RRC_nocredit", "RRC_liable",
               "RRC_TNM_check_status", "RRC_TNM_history", "RRC_TNM_purpose", "RRC_TNM_bonds",
               "RRC_TNM_jobex", "RRC_TNM_s_status", "RRC_TNM_guarantor", "RRC_TNM_property",
               "RRC_TNM_install", "RRC_TNM_house", "RRC_TNM_job", "RRC_TNM_ph")

numeric <- c("R01_credibility", "RRC_duration", "RRC_credit", "RRC_rate",
                 "RRC_residence", "RRC_age", "RRC_nocredit", "RRC_liable",
                 "RRC_TNM_check_status", "RRC_TNM_history", "RRC_TNM_purpose", "RRC_TNM_bonds",
                 "RRC_TNM_jobex", "RRC_TNM_s_status", "RRC_TNM_guarantor", "RRC_TNM_property",
                 "RRC_TNM_install", "RRC_TNM_house", "RRC_TNM_job", "RRC_TNM_ph")

categoric <- NULL

target  <- "RRC_TNM_nri"
risk    <- NULL
ident   <- NULL
ignore  <- NULL
weights <- NULL

#============================================================
# Rattle timestamp: 2015-10-17 02:42:10 x86_64-pc-linux-gnu 


set.seed(crv$seed) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.8*nobs) # 800 observations
validate <- NULL
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 200 observations

# The following variable selections have been noted.

input <- c("RRC_duration", "RRC_credit", "RRC_rate", "RRC_age",
               "RRC_nocredit", "RRC_TNM_check_status", "RRC_TNM_history", "RRC_TNM_purpose",
               "RRC_TNM_bonds", "RRC_TNM_jobex", "RRC_TNM_s_status", "RRC_TNM_guarantor",
               "RRC_TNM_property", "RRC_TNM_install", "RRC_TNM_house", "RRC_TNM_job",
               "RRC_TNM_ph", "RRC_TNM_nri")

numeric <- c("RRC_duration", "RRC_credit", "RRC_rate", "RRC_age",
                 "RRC_nocredit", "RRC_TNM_check_status", "RRC_TNM_history", "RRC_TNM_purpose",
                 "RRC_TNM_bonds", "RRC_TNM_jobex", "RRC_TNM_s_status", "RRC_TNM_guarantor",
                 "RRC_TNM_property", "RRC_TNM_install", "RRC_TNM_house", "RRC_TNM_job",
                 "RRC_TNM_ph", "RRC_TNM_nri")

categoric <- NULL

target  <- "R01_credibility"
risk    <- NULL
ident   <- NULL
ignore  <- c("RRC_residence", "RRC_liable")
weights <- NULL

#============================================================
# Rattle timestamp: 2015-10-17 02:42:18 x86_64-pc-linux-gnu 

# Neural Network 

# Build a neural network model using the nnet package.

library(nnet, quietly=TRUE)

# Build the NNet model.

set.seed(199)
nnet <- nnet(as.factor(R01_credibility) ~ .,
                 data=dataset[sample,c(input, target)],
                 size=7, skip=TRUE, MaxNWts=10000, trace=FALSE, maxit=100)


#library(devtools)
#source_url('https://gist.githubusercontent.com/fawda123/7471137/raw/466c1474d0a505ff044412703516c34f1a4684a5/nnet_plot_update.r')
#plot each model
#plot.nnet(nnet)

# Print the results of the modelling.

cat(sprintf("A %s network with %d weights.\n",
            paste(nnet$n, collapse="-"),
            length(nnet$wts)))
cat(sprintf("Inputs: %s.\n",
            paste(nnet$coefnames, collapse=", ")))
cat(sprintf("Output: %s.\n",
            names(attr(nnet$terms, "dataClasses"))[1]))
cat(sprintf("Sum of Squares Residuals: %.4f.\n",
            sum(residuals(nnet) ^ 2)))
cat("\n")
print(summary(nnet))
cat('\n')

# Time taken: 0.36 secs

#============================================================
# Rattle timestamp: 2015-10-17 02:42:23 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# Generate an Error Matrix for the Neural Net model.

# Obtain the response from the Neural Net model.

pr <- predict(nnet, newdata=dataset[test, c(input, target)], type="class")

# Generate the confusion matrix showing counts.

table(dataset[test, c(input, target)]$R01_credibility, pr,
      dnn=c("Actual", "Predicted"))

# Generate the confusion matrix showing proportions.

pcme <- function(actual, cl)
{
  x <- table(actual, cl)
  nc <- nrow(x)
  tbl <- cbind(x/length(actual),
               Error=sapply(1:nc,
                            function(r) round(sum(x[r,-r])/sum(x[r,]), 2)))
  names(attr(tbl, "dimnames")) <- c("Actual", "Predicted")
  return(tbl)
}
per <- pcme(dataset[test, c(input, target)]$R01_credibility, pr)
round(per, 2)

# Calculate the overall error percentage.

cat(round(sum(per[,"Error"], na.rm=TRUE), 2))

# Calculate the averaged class error percentage.

cat(round(mean(per[,"Error"], na.rm=TRUE), 2))

#============================================================
# Rattle timestamp: 2015-10-17 02:42:25 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# ROC Curve: requires the ROCR package.

library(ROCR)

# ROC Curve: requires the ggplot2 package.

library(ggplot2, quietly=TRUE)

# Generate an ROC Curve for the nnet model on outfile_saved.csv [test].

pr <- predict(nnet, newdata=dataset[test, c(input, target)])

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
p <- p + ggtitle("ROC Curve Neural Net outfile_saved.csv [test] R01_credibility")
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
# Rattle timestamp: 2015-10-11 17:01:09 x86_64-pc-linux-gnu 

# Load the data.

dataset <- read.csv("/home/freestyler/outfile_saved.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

#============================================================
# Rattle timestamp: 2015-10-11 17:01:10 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

set.seed(crv$seed) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.7*nobs) # 700 observations
validate <- sample(setdiff(seq_len(nrow(dataset)), train), 0.15*nobs) # 150 observations
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 150 observations

# The following variable selections have been noted.

set.seed(42)
nobs <- nrow(dataset) # 1000 observations
train <- sample(nrow(dataset), 0.8*nobs) # 800 observations
validate <- NULL
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 200 observations
# The following variable selections have been noted.

input <- c("RRC_duration", "RRC_credit", "RRC_rate", "RRC_residence",
           "RRC_age", "RRC_nocredit", "RRC_liable", "RRC_TNM_check_status",
           "RRC_TNM_history", "RRC_TNM_purpose", "RRC_TNM_bonds", "RRC_TNM_jobex",
           "RRC_TNM_s_status", "RRC_TNM_guarantor", "RRC_TNM_property", "RRC_TNM_install",
           "RRC_TNM_house", "RRC_TNM_job", "RRC_TNM_ph", "RRC_TNM_nri")

numeric <- c("RRC_duration", "RRC_credit", "RRC_rate", "RRC_residence",
             "RRC_age", "RRC_nocredit", "RRC_liable", "RRC_TNM_check_status",
             "RRC_TNM_history", "RRC_TNM_purpose", "RRC_TNM_bonds", "RRC_TNM_jobex",
             "RRC_TNM_s_status", "RRC_TNM_guarantor", "RRC_TNM_property", "RRC_TNM_install",
             "RRC_TNM_house", "RRC_TNM_job", "RRC_TNM_ph", "RRC_TNM_nri")

categoric <- NULL

target  <- "R01_credibility"
risk    <- NULL
ident   <- NULL
ignore  <- NULL
weights <- NULL


xtrain <- dataset[train,]
xnew <- dataset[-train,]
ytrain <- dataset$R01_credibility[train]
ynew <- dataset$R01_credibility[-train]
table(ytrain)
table(ynew)


modelFit <- pcaNNet(xtrain[, 2:21], ytrain, thresh=0.95,size = 6, linout = TRUE, trace = FALSE)
modelFit

pr<-predict(modelFit, xnew[, 2:21])
for(i in 1:length(pr)){
  if(pr[i]>0.49)
    pr[i]=1
  else
    pr[i]=0
#print(pr[i])
}
table(ynew, pr,dnn=c("Actual", "Predicted"))

