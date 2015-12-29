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
# Rattle timestamp: 2015-10-09 17:33:20 x86_64-pc-linux-gnu 

# Load the data.

dataset <- read.csv("/home/freestyler/BDA_project/Data/outfile.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

#============================================================
# Rattle timestamp: 2015-10-09 17:33:21 x86_64-pc-linux-gnu 

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
# Rattle timestamp: 2015-10-09 17:33:28 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

set.seed(crv$seed) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.8*nobs) # 800 observations
validate <- NULL
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 200 observations

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
# Rattle timestamp: 2015-10-09 17:33:37 x86_64-pc-linux-gnu 

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
# Rattle timestamp: 2015-10-09 17:33:47 x86_64-pc-linux-gnu 

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

# Time taken: 0.24 secs

# Plot the model evaluation.

ttl <- genPlotTitleCmd("Linear Model",dataname,vector=TRUE)
plot(glm, main=ttl[1])

#============================================================
# Rattle timestamp: 2015-10-09 17:34:02 x86_64-pc-linux-gnu 

# Evaluate model performance. 

# ROC Curve: requires the ROCR package.

library(ROCR)

# ROC Curve: requires the ggplot2 package.

library(ggplot2, quietly=TRUE)

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

pe <- performance(pred, "tpr", "fpr")
au <- performance(pred, "auc")@y.values[[1]]
pd <- data.frame(fpr=unlist(pe@x.values), tpr=unlist(pe@y.values))
p <- ggplot(pd, aes(x=fpr, y=tpr))
p <- p + geom_line(colour="red")
p <- p + xlab("False Positive Rate") + ylab("True Positive Rate")
p <- p + ggtitle("ROC Curve Linear [test] R01_credibility")
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


# Evaluate model performance. 

# Sensitivity/Specificity Plot: requires the ROCR package

library(ROCR)

# Generate Sensitivity/Specificity Plot for glm model on outfile.csv [test].

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
plot(performance(pred, "sens", "spec"), col="#CC0000FF", lty=1, add=FALSE)



dataset <- read.csv("/home/freestyler/BDA_project/Data/outfile.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

set.seed(42) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.8*nobs) # 800 observations
validate <- NULL
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 200 observations

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
# Rattle timestamp: 2015-10-10 03:11:08 x86_64-pc-linux-gnu 

# Principal Components Analysis (on numerics only).

pc <- princomp(na.omit(dataset[sample, numeric]), scale=TRUE, center=TRUE, tol=0)

# Show the output of the analysis.

pc

# Summarise the importance of the components found.

summary(pc)

# Display a plot showing the relative importance of the components.




# Display a plot showing the two most principal components.

#biplot(pc, main="")
#title(main="Principal Components outfile.csv",
#      sub=paste("Rattle", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))


l#ibrary("FactoMineR")
#res.pca = PCA(dataset[,1:19], scale.unit=TRUE, ncp=5, graph=T) 
#res.pca = PCA(dataset[,1:12], scale.unit=TRUE, ncp=5, quanti.sup=c(11: 12), graph=T) 


#library(devtools)
#install_github("ggbiplot", "vqv")

#install.packages("http://cran.r-project.org/src/contrib/Archive/arules/arules_1.1-0.tar.gz", repo=NULL, type="source")



#library(ggbiplot)
#g <- ggbiplot(res.pca, obs.scale = 1, var.scale = 1, 
#               ellipse = TRUE, 
#              circle = TRUE)
#g <- g + scale_color_discrete(name = '')
#g <- g + theme(legend.direction = 'horizontal', 
#               legend.position = 'top')
#print(g)
