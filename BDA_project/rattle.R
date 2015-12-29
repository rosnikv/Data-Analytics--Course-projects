library(rattle)

# This log generally records the process of building a model. However, with very 
# little effort the log can be used to score a new dataset. The logical variable 
# 'building' is used to toggle between generating transformations, as when building 
# a model, and simply using the transformations, as when scoring a dataset.

building <- TRUE
scoring  <- ! building

# The colorspace package is used to generate the colours used in plots, if available.

library(colorspace)

# A pre-defined value is used to reset the random seed so that results are repeatable.

crv$seed <- 42 

#============================================================
# Rattle timestamp: 2015-09-27 21:47:10 x86_64-unknown-linux-gnu 

# Load the data.

crs$dataset <- read.csv("file:///root/BDA_project/Data/german_test.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

#============================================================
# Rattle timestamp: 2015-09-27 21:47:10 x86_64-unknown-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

set.seed(crv$seed) 
crs$nobs <- nrow(crs$dataset) # 1000 observations 
crs$sample <- crs$train <- sample(nrow(crs$dataset), 0.7*crs$nobs) # 700 observations
crs$validate <- sample(setdiff(seq_len(nrow(crs$dataset)), crs$train), 0.15*crs$nobs) # 150 observations
crs$test <- setdiff(setdiff(seq_len(nrow(crs$dataset)), crs$train), crs$validate) # 150 observations

# The following variable selections have been noted.

crs$input <- c("status", "duration", "history", "purpose",
     "credit", "bonds", "jobex", "rate",
     "sex", "guarantor", "residence", "property",
     "age", "install", "house", "nocredit",
     "job", "no", "ph", "nri")

crs$numeric <- c("duration", "credit", "rate", "residence",
     "age", "nocredit", "no")

crs$categoric <- c("status", "history", "purpose", "bonds",
     "jobex", "sex", "guarantor", "property",
     "install", "house", "job", "ph",
     "nri")

crs$target  <- "credibility"
crs$risk    <- NULL
crs$ident   <- NULL
crs$ignore  <- NULL
crs$weights <- NULL

#============================================================
# Rattle timestamp: 2015-09-27 21:47:30 x86_64-unknown-linux-gnu 

# Remap variables. 

# Bin the variable(s) into 4 bins using quantiles.

if (building)
{
   crs$dataset[["BQ4_history"]] <- binning(crs$dataset[["history"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_purpose"]] <- binning(crs$dataset[["purpose"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_bonds"]] <- binning(crs$dataset[["bonds"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_jobex"]] <- binning(crs$dataset[["jobex"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_sex"]] <- binning(crs$dataset[["sex"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_guarantor"]] <- binning(crs$dataset[["guarantor"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_property"]] <- binning(crs$dataset[["property"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_install"]] <- binning(crs$dataset[["install"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_house"]] <- binning(crs$dataset[["house"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_job"]] <- binning(crs$dataset[["job"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_ph"]] <- binning(crs$dataset[["ph"]], 4, method="quantile", ordered=FALSE)
  crs$dataset[["BQ4_nri"]] <- binning(crs$dataset[["nri"]], 4, method="quantile", ordered=FALSE)
}


#============================================================
# Rattle timestamp: 2015-09-27 21:47:36 x86_64-unknown-linux-gnu 

# Remap variables. 

# Transform into a numeric.

  crs$dataset[["TNM_status"]] <- as.numeric(crs$dataset[["status"]])
  crs$dataset[["TNM_history"]] <- as.numeric(crs$dataset[["history"]])
  crs$dataset[["TNM_purpose"]] <- as.numeric(crs$dataset[["purpose"]])
  crs$dataset[["TNM_bonds"]] <- as.numeric(crs$dataset[["bonds"]])
  crs$dataset[["TNM_jobex"]] <- as.numeric(crs$dataset[["jobex"]])
  crs$dataset[["TNM_sex"]] <- as.numeric(crs$dataset[["sex"]])
  crs$dataset[["TNM_guarantor"]] <- as.numeric(crs$dataset[["guarantor"]])
  crs$dataset[["TNM_property"]] <- as.numeric(crs$dataset[["property"]])
  crs$dataset[["TNM_install"]] <- as.numeric(crs$dataset[["install"]])
  crs$dataset[["TNM_house"]] <- as.numeric(crs$dataset[["house"]])
  crs$dataset[["TNM_job"]] <- as.numeric(crs$dataset[["job"]])
  crs$dataset[["TNM_ph"]] <- as.numeric(crs$dataset[["ph"]])
  crs$dataset[["TNM_nri"]] <- as.numeric(crs$dataset[["nri"]])

#============================================================
# Rattle timestamp: 2015-09-27 21:47:36 x86_64-unknown-linux-gnu 

# Note the user selections. 

# The following variable selections have been noted.

crs$input <- c("duration", "credit", "rate", "residence",
     "age", "nocredit", "no", "TNM_status",
     "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
     "TNM_sex", "TNM_guarantor", "TNM_property", "TNM_install",
     "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

crs$numeric <- c("duration", "credit", "rate", "residence",
     "age", "nocredit", "no", "TNM_status",
     "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
     "TNM_sex", "TNM_guarantor", "TNM_property", "TNM_install",
     "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

crs$categoric <- NULL

crs$target  <- "credibility"
crs$risk    <- NULL
crs$ident   <- NULL
crs$ignore  <- c("status", "history", "purpose", "bonds", "jobex", "sex", "guarantor", "property", "install", "house", "job", "ph", "nri")
crs$weights <- NULL

#============================================================
# Rattle timestamp: 2015-09-27 21:48:43 x86_64-unknown-linux-gnu 

# Regression model 

# Build a Regression model.

crs$glm <- glm(credibility ~ .,
    data=crs$dataset[crs$train, c(crs$input, crs$target)],
    family=binomial(link="logit"))

#============================================================
# Rattle timestamp: 2015-09-27 21:48:55 x86_64-unknown-linux-gnu 

# Transform variables by rescaling. 

# The 'reshape' package provides the 'rescaler' function.

require(reshape, quietly=TRUE)

# Rescale credibility.

crs$dataset[["R01_credibility"]] <- crs$dataset[["credibility"]]

# Rescale to [0,1].

if (building)
{
  crs$dataset[["R01_credibility"]] <-  rescaler(crs$dataset[["credibility"]], "range")
}

# When scoring transform using the training data parameters.

if (scoring)
{
  crs$dataset[["R01_credibility"]] <- (crs$dataset[["credibility"]] - 1.000000)/abs(2.000000 - 1.000000)
}

#============================================================
# Rattle timestamp: 2015-09-27 21:48:56 x86_64-unknown-linux-gnu 

# Note the user selections. 

# The following variable selections have been noted.

crs$input <- c("duration", "credit", "rate", "residence",
     "age", "nocredit", "no", "TNM_status",
     "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
     "TNM_sex", "TNM_guarantor", "TNM_property", "TNM_install",
     "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

crs$numeric <- c("duration", "credit", "rate", "residence",
     "age", "nocredit", "no", "TNM_status",
     "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
     "TNM_sex", "TNM_guarantor", "TNM_property", "TNM_install",
     "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

crs$categoric <- NULL

crs$target  <- "R01_credibility"
crs$risk    <- NULL
crs$ident   <- NULL
crs$ignore  <- c("status", "history", "purpose", "bonds", "jobex", "sex", "guarantor", "property", "install", "house", "job", "ph", "nri", "credibility")
crs$weights <- NULL



Summary of the Logistic Regression model (built using glm):

Call:
glm(formula = R01_credibility ~ ., family = binomial(link = "logit"), 
    data = crs$dataset[crs$train, c(crs$input, crs$target)])

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-1.9054  -0.7653  -0.4391   0.8174   2.3948  

Coefficients:
                 Estimate  Std. Error z value Pr(>|z|)    
(Intercept)    5.12089691  1.27096472   4.029 5.60e-05 ***
duration       0.02138851  0.01043556   2.050  0.04041 *  
credit         0.00007327  0.00004733   1.548  0.12166    
rate           0.24838337  0.09958129   2.494  0.01262 *  
residence     -0.05956715  0.09158736  -0.650  0.51544    
age           -0.00573418  0.00969502  -0.591  0.55422    
nocredit       0.20071386  0.18871689   1.064  0.28752    
no             0.20072847  0.27602529   0.727  0.46710    
TNM_status    -0.61100362  0.08452928  -7.228 4.89e-13 ***
TNM_history   -0.37544571  0.10096965  -3.718  0.00020 ***
TNM_purpose   -0.02814228  0.03661132  -0.769  0.44208    
TNM_bonds     -0.19433242  0.07158370  -2.715  0.00663 ** 
TNM_jobex     -0.15871424  0.08352389  -1.900  0.05740 .  
TNM_sex       -0.20180465  0.13206672  -1.528  0.12650    
TNM_guarantor -0.67388050  0.23024726  -2.927  0.00343 ** 
TNM_property   0.17600443  0.10684239   1.647  0.09949 .  
TNM_install   -0.37733424  0.13503682  -2.794  0.00520 ** 
TNM_house     -0.25312885  0.19616789  -1.290  0.19692    
TNM_job        0.00833029  0.16018789   0.052  0.95853    
TNM_ph        -0.15887636  0.22140547  -0.718  0.47302    
TNM_nri       -1.22904042  0.71720860  -1.714  0.08659 .  
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 855.21  on 699  degrees of freedom
Residual deviance: 673.24  on 679  degrees of freedom
AIC: 715.24

Number of Fisher Scoring iterations: 5

Log likelihood: -336.620 (21 df)
Null/Residual deviance difference: 181.969 (20 df)
Chi-square p-value: 0.00000000
Pseudo R-Square (optimistic): 0.49620900

==== ANOVA ====

Analysis of Deviance Table

Model: binomial, link: logit

Response: R01_credibility

Terms added sequentially (first to last)


              Df Deviance Resid. Df Resid. Dev    Pr(>Chi)    
NULL                            699     855.21                
duration       1   22.506       698     832.70 0.000002095 ***
credit         1    0.507       697     832.20   0.4766566    
rate           1    2.286       696     829.91   0.1305540    
residence      1    0.673       695     829.24   0.4121300    
age            1    3.231       694     826.01   0.0722366 .  
nocredit       1    1.847       693     824.16   0.1741845    
no             1    0.178       692     823.98   0.6730650    
TNM_status     1   88.312       691     735.67   < 2.2e-16 ***
TNM_history    1   19.516       690     716.15 0.000009974 ***
TNM_purpose    1    0.168       689     715.99   0.6821524    
TNM_bonds      1    7.448       688     708.54   0.0063519 ** 
TNM_jobex      1    4.201       687     704.34   0.0404011 *  
TNM_sex        1    2.686       686     701.65   0.1012245    
TNM_guarantor  1   12.290       685     689.36   0.0004555 ***
TNM_property   1    2.996       684     686.37   0.0834886 .  
TNM_install    1    7.468       683     678.90   0.0062802 ** 
TNM_house      1    1.599       682     677.30   0.2060977    
TNM_job        1    0.020       681     677.28   0.8880395    
TNM_ph         1    0.426       680     676.85   0.5138923    
TNM_nri        1    3.613       679     673.24   0.0573178 .  
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Time taken: 0.44 secs

Rattle timestamp: 2015-09-27 21:50:07 root
======================================================================

#============================================================
# Rattle timestamp: 2015-09-27 21:50:07 x86_64-unknown-linux-gnu 

# Regression model 

# Build a Regression model.

crs$glm <- glm(R01_credibility ~ .,
    data=crs$dataset[crs$train, c(crs$input, crs$target)],
    family=binomial(link="logit"))

# Generate a textual view of the Linear model.

print(summary(crs$glm))
cat(sprintf("Log likelihood: %.3f (%d df)\n",
            logLik(crs$glm)[1],
            attr(logLik(crs$glm), "df")))
cat(sprintf("Null/Residual deviance difference: %.3f (%d df)\n",
            crs$glm$null.deviance-crs$glm$deviance,
            crs$glm$df.null-crs$glm$df.residual))
cat(sprintf("Chi-square p-value: %.8f\n",
            dchisq(crs$glm$null.deviance-crs$glm$deviance,
                   crs$glm$df.null-crs$glm$df.residual)))
cat(sprintf("Pseudo R-Square (optimistic): %.8f\n",
             cor(crs$glm$y, crs$glm$fitted.values)))
cat('\n==== ANOVA ====\n\n')
print(anova(crs$glm, test="Chisq"))
cat("\n")

# Time taken: 0.44 secs


#============================================================
# Rattle timestamp: 2015-09-27 21:50:59 x86_64-unknown-linux-gnu 

# Evaluate model performance. 

# ROC Curve: requires the ROCR package.

library(ROCR)

# ROC Curve: requires the ggplot2 package.

require(ggplot2, quietly=TRUE)

# Generate an ROC Curve for the glm model on german_test.csv [validate].

crs$pr <- predict(crs$glm, type="response", newdata=crs$dataset[crs$validate, c(crs$input, crs$target)])

# Remove observations with missing target.

no.miss   <- na.omit(crs$dataset[crs$validate, c(crs$input, crs$target)]$R01_credibility)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(crs$pr[-miss.list], no.miss)
} else
{
  pred <- prediction(crs$pr, no.miss)
}

pe <- performance(pred, "tpr", "fpr")
au <- performance(pred, "auc")@y.values[[1]]
pd <- data.frame(fpr=unlist(pe@x.values), tpr=unlist(pe@y.values))
p <- ggplot(pd, aes(x=fpr, y=tpr))
p <- p + geom_line(colour="red")
p <- p + xlab("False Positive Rate") + ylab("True Positive Rate")
p <- p + ggtitle("ROC Curve Linear german_test.csv [validate] R01_credibility")
p <- p + theme(plot.title=element_text(size=10))
p <- p + geom_line(data=data.frame(), aes(x=c(0,1), y=c(0,1)), colour="grey")
p <- p + annotate("text", x=0.50, y=0.00, hjust=0, vjust=0, size=5,
                   label=paste("AUC =", round(au, 2)))
print(p)

# Calculate the area under the curve for the plot.


# Remove observations with missing target.

no.miss   <- na.omit(crs$dataset[crs$validate, c(crs$input, crs$target)]$R01_credibility)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(crs$pr[-miss.list], no.miss)
} else
{
  pred <- prediction(crs$pr, no.miss)
}
performance(pred, "auc")


