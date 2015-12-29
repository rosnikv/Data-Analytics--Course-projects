
library(rattle)   # To access the weather dataset and utility commands.
library(magrittr) # For the %>% and %<>% operators.

building <- TRUE
scoring  <- ! building


# A pre-defined value is used to reset the random seed so that results are repeatable.

crv$seed <- 42 

#============================================================
# Rattle timestamp: 2015-10-17 19:56:16 x86_64-pc-linux-gnu 

# Load the data.

dataset <- read.csv("/home/freestyler/BDA_project/Data/outfile.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

#============================================================
# Rattle timestamp: 2015-10-17 19:56:17 x86_64-pc-linux-gnu 

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
# Rattle timestamp: 2015-10-17 19:56:33 x86_64-pc-linux-gnu 

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

#============================================================
# Rattle timestamp: 2015-10-17 19:59:01 x86_64-pc-linux-gnu 

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

# Time taken: 0.11 secs

#============================================================
# Rattle timestamp: 2015-10-17 19:59:05 x86_64-pc-linux-gnu 

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

# The `pROC' package implements various AUC functions.

# Calculate the Area Under the Curve (AUC).

pROC::roc(rf$y, as.numeric(rf$predicted))

# Calculate the AUC Confidence Interval.

pROC::ci.auc(rf$y, as.numeric(rf$predicted))

# List the importance of the variables.

rn <- round(randomForest::importance(rf), 2)
rn[order(rn[,3], decreasing=TRUE),]

# Time taken: 2.24 secs

#============================================================
# Rattle timestamp: 2015-10-17 19:59:27 x86_64-pc-linux-gnu 

# Regression model 

# Build a Regression model.

glm <- glm(R01_credibility ~ .,
               data=dataset[train, c(input, target)],
               family=binomial(link="logit"))

# Generate a textual view of the Linear model.

print(summary(glm))
cat(sprintf("Log likelihood: %.3f (%d df)\n",
            logLik(glm)[1],
            attr(logLik(glm), "df")))
cat(sprintf("Null/Residual deviance difference: %.3f (%d df)\n",
            glm$null.deviance-glm$deviance,
            glm$df.null-glm$df.residual))
cat(sprintf("Chi-square p-value: %.8f\n",
            dchisq(glm$null.deviance-glm$deviance,
                   glm$df.null-glm$df.residual)))
cat(sprintf("Pseudo R-Square (optimistic): %.8f\n",
            cor(glm$y, glm$fitted.values)))
cat('\n==== ANOVA ====\n\n')
print(anova(glm, test="Chisq"))
cat("\n")

# Time taken: 0.31 secs

#============================================================
# Rattle timestamp: 2015-10-17 19:59:54 x86_64-pc-linux-gnu 

# Support vector machine. 

# The 'kernlab' package provides the 'ksvm' function.

library(kernlab, quietly=TRUE)

# Build a Support Vector Machine model.

set.seed(crv$seed)
ksvm <- ksvm(as.factor(R01_credibility) ~ .,
                 data=dataset[train,c(input, target)],
                 kernel="rbfdot",
                 prob.model=TRUE)

# Generate a textual view of the SVM model.

ksvm

# Time taken: 0.39 secs



#============================================================
# Rattle timestamp: 2015-10-17 20:00:10 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# ROC Curve: requires the ROCR package.

library(ROCR)

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
ROCR::plot(performance(pred, "tpr", "fpr"), col="#CC0000FF", lty=1, add=FALSE)

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

# ROC Curve: requires the ROCR package.

library(ROCR)

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
ROCR::plot(performance(pred, "tpr", "fpr"), col="#FFFF00", lty=2, add=TRUE)

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

# ROC Curve: requires the ROCR package.

library(ROCR)

# Generate an ROC Curve for the ksvm model on outfile.csv [test].

pr <- kernlab::predict(ksvm, newdata=na.omit(dataset[test, c(input, target)]), type="probabilities")[,2]

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
ROCR::plot(performance(pred, "tpr", "fpr"), col="#00FF00", lty=3, add=TRUE)

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

# ROC Curve: requires the ROCR package.

library(ROCR)

# Generate an ROC Curve for the glm model on outfile.csv [test].

pr <- predict(glm, type="response", newdata=dataset[test, c(input, target)])

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
ROCR::plot(performance(pred, "tpr", "fpr"), col="#00EEEE", lty=4, add=TRUE)

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
ROCR::plot(performance(pred, "tpr", "fpr"), col="#8A2BE2", lty=5, add=TRUE)

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



#============================================================
# Rattle timestamp: 2015-10-11 17:01:21 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

# The following variable selections have been noted.

set.seed(42)
nobs <- nrow(dataset) # 1000 observations
train <- sample(nrow(dataset), 0.8*nobs) # 800 observations
validate <- NULL
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 200 observations
# The following variable selections have been noted.

input <- c("RRC_duration", "RRC_credit", "RRC_rate", 
           "RRC_age", "RRC_nocredit", "RRC_TNM_check_status",
           "RRC_TNM_history", "RRC_TNM_purpose", "RRC_TNM_bonds", "RRC_TNM_jobex",
           "RRC_TNM_s_status", "RRC_TNM_guarantor", "RRC_TNM_property", "RRC_TNM_install",
           "RRC_TNM_house", "RRC_TNM_job", "RRC_TNM_ph", "RRC_TNM_nri")

numeric <- c("RRC_duration", "RRC_credit", "RRC_rate",
             "RRC_age", "RRC_nocredit", "RRC_TNM_check_status",
             "RRC_TNM_history", "RRC_TNM_purpose", "RRC_TNM_bonds", "RRC_TNM_jobex",
             "RRC_TNM_s_status", "RRC_TNM_guarantor", "RRC_TNM_property", "RRC_TNM_install",
             "RRC_TNM_house", "RRC_TNM_job", "RRC_TNM_ph", "RRC_TNM_nri")

categoric <- NULL

target  <- "R01_credibility"
risk    <- NULL
ident   <- NULL
ignore  <- c("RRC_residence","RRC_liable")
weights <- NULL

xtrain <- dataset[train,]
xnew <- dataset[-train,]
ytrain <- dataset$R01_credibility[train]
ynew <- dataset$R01_credibility[-train]
table(ytrain)
table(ynew)

train_dataset<-read.csv("/home/freestyler/new_sample.csv")

input <- c("RRC_duration", "RRC_credit", "RRC_rate", 
           "RRC_age", "RRC_nocredit", "RRC_TNM_check_status",
           "RRC_TNM_history", "RRC_TNM_purpose", "RRC_TNM_bonds", "RRC_TNM_jobex",
           "RRC_TNM_s_status", "RRC_TNM_guarantor", "RRC_TNM_property", "RRC_TNM_install",
           "RRC_TNM_house", "RRC_TNM_job", "RRC_TNM_ph", "RRC_TNM_nri")

numeric <- c("RRC_duration", "RRC_credit", "RRC_rate",
             "RRC_age", "RRC_nocredit", "RRC_TNM_check_status",
             "RRC_TNM_history", "RRC_TNM_purpose", "RRC_TNM_bonds", "RRC_TNM_jobex",
             "RRC_TNM_s_status", "RRC_TNM_guarantor", "RRC_TNM_property", "RRC_TNM_install",
             "RRC_TNM_house", "RRC_TNM_job", "RRC_TNM_ph", "RRC_TNM_nri")

categoric <- NULL

target  <- "R01_credibility"
risk    <- NULL
ident   <- NULL
ignore  <- c("RRC_residence","RRC_liable")
weights <- NULL

xtrain <- train_dataset
ytrain <- train_dataset$R01_credibility
table(ytrain)
table(ynew)

library(class)
nearest3 <- knn(train=xtrain, test=xnew, cl=ytrain, k=7)


library(ROCR)
library(ggplot2, quietly=TRUE)
nearest3 <-as.vector(nearest3,"numeric")
#nearest1 <-as.vector(nearest1,"numeric")
ynew <- as.vector(ynew, mode = "numeric")

pred_knn <- prediction(nearest3, ynew)

no.miss   <- na.omit(dataset[test, c(input, target)]$R01_credibility)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(pred_knn[-miss.list], no.miss)
} else
{
  pred <- prediction(pred_knn, no.miss)
}

ROCR::plot(performance(pred_knn, "tpr", "fpr"), col="#FF00FF", lty=6, add=TRUE)

no.miss   <- na.omit(dataset[test, c(input, target)]$R01_credibility)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(pred_knn[-miss.list], no.miss)
} else
{
  pred <- prediction(pred_knn, no.miss)
}
performance(pred, "auc")



# Add a legend to the plot.

legend("bottomright", c("rpart","rf","ksvm","glm","nnet","knn"), col=rainbow(6, 1, .8), lty=1:6, title="Models", inset=c(0.05, 0.05))

# Add decorations to the plot.

title(main="ROC Curve  [test]",
      sub=paste("", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"])
      )
grid()
