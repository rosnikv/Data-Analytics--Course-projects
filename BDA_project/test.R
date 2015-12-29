dataset <- read.csv("/home/freestyler/BDA_project/Data/german.csv")
library("MASS")
tb<-table(dataset$jobex,dataset$credibility)
chisq.test(tb)

t<-table(dataset$TIN_guarantor_A101,dataset$credibility)
t

tbl <- matrix(c(442,15,33,196,9,5), ncol=2)
colnames(trial) <- c('1', '2')
rownames(trial) <- c('TIN_guarantor_A101', 'TIN_guarantor_A102','TIN_guarantor_A103')
tbl.table <- as.table(tbl)
tbl.table
chisq.test(tbl.table)

dataset <- read.csv("/home/freestyler/BDA_project/Data/german_test.csv")
library(fBasics, quietly=TRUE)

# Perform the test.

locationTest(na.omit(dataset[dataset[["credibility"]] == "1", "duration"]), na.omit(dataset[dataset[["credibility"]] == "2", "duration"]))

################ SVM

dataset <- read.csv("/home/freestyler/BDA_project/Data/outfile.csv")
library("MASS")
tb<-table(dataset$TNM_guarantor,dataset$R01_credibility)
tb
chisq.test(tb)



dataset <- read.csv("/home/freestyler/BDA_project/Data/outfile.csv")
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
# Rattle timestamp: 2015-10-09 16:17:18 x86_64-pc-linux-gnu 

# Support vector machine. 

# The 'kernlab' package provides the 'ksvm' function.

library(kernlab, quietly=TRUE)

# Build a Support Vector Machine model.

set.seed(42)
ksvm <- ksvm(as.factor(R01_credibility) ~ .,
                 data=dataset[train,c(input, target)],
                 kernel="rbfdot",
                 prob.model=TRUE)

# Generate a textual view of the SVM model.

ksvm

# Time taken: 0.38 secs

#============================================================
# Rattle timestamp: 2015-10-09 16:17:21 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# ROC Curve: requires the ROCR package.

library(ROCR)

# ROC Curve: requires the ggplot2 package.

library(ggplot2, quietly=TRUE)

# Generate an ROC Curve for the ksvm model on outfile.csv [test].

pr <- predict(ksvm, newdata=na.omit(dataset[test, c(input, target)]), type="probabilities")[,2]

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
p <- p + ggtitle("ROC Curve SVM [test] R01_credibility")
p <- p + theme(plot.title=element_text(size=10))
p <- p + geom_line(data=data.frame(), aes(x=c(0,1), y=c(0,1)), colour="grey")
p <- p + annotate("text", x=0.50, y=0.00, hjust=0, vjust=0, size=5,
                  label=paste("AUC =", round(au, 2)))
print(p)


pr <- predict(ksvm, newdata=na.omit(dataset[test, c(input, target)]))

table(dataset[test, c(input, target)]$R01_credibility, pr,
      dnn=c("Actual", "Predicted"))

