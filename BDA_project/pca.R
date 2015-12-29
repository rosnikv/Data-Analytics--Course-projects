# Rattle is Copyright (c) 2006-2015 Togaware Pty Ltd.

#============================================================
# Rattle timestamp: 2015-11-01 17:35:54 x86_64-pc-linux-gnu 

# Rattle version 4.0.0 user 'freestyler'

# This log file captures all Rattle interactions as R commands. 

Export this log to a file using the Export button or the Tools 
# menu to save a log of all your activity. This facilitates repeatability. For example, exporting 
# to a file called 'myrf01.R' will allow you to type in the R Console 
# the command source('myrf01.R') and so repeat all actions automatically. 
# Generally, you will want to edit the file to suit your needs. You can also directly 
# edit this current log in place to record additional information before exporting. 

# Saving and loading projects also retains this log.

# We begin by loading the required libraries.

library(rattle)   # To access the weather dataset and utility commands.
library(magrittr) # For the %>% and %<>% operators.

# This log generally records the process of building a model. However, with very 
# little effort the log can be used to score a new dataset. The logical variable 
# 'building' is used to toggle between generating transformations, as when building 
# a model, and simply using the transformations, as when scoring a dataset.

building <- TRUE
scoring  <- ! building


# A pre-defined value is used to reset the random seed so that results are repeatable.

crv$seed <- 42 

#============================================================
# Rattle timestamp: 2015-11-01 17:36:27 x86_64-pc-linux-gnu 

# Load the data.

dataset <- read.csv("file:///home/freestyler/outfile.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

#============================================================
# Rattle timestamp: 2015-11-01 17:36:28 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

set.seed(crv$seed) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.7*nobs) # 700 observations
validate <- sample(setdiff(seq_len(nrow(dataset)), train), 0.15*nobs) # 150 observations
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 150 observations

# The following variable selections have been noted.

input <- c("duration", "credit", "rate", "residence",
               "age", "nocredit", "no", "TNM_status",
               "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
               "TNM_sex", "TNM_guarantor", "TNM_property", "TNM_install",
               "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

numeric <- c("duration", "credit", "rate", "residence",
                 "age", "nocredit", "no", "TNM_status",
                 "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
                 "TNM_sex", "TNM_guarantor", "TNM_property", "TNM_install",
                 "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

categoric <- NULL

target  <- "R01_credibility"
risk    <- NULL
ident   <- NULL
ignore  <- NULL
weights <- NULL

#============================================================
# Rattle timestamp: 2015-11-01 17:36:37 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

set.seed(crv$seed) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.8*nobs) # 800 observations
validate <- NULL
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 200 observations

# The following variable selections have been noted.

input <- c("duration", "credit", "rate", "residence",
               "age", "nocredit", "no", "TNM_status",
               "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
               "TNM_sex", "TNM_guarantor", "TNM_property", "TNM_install",
               "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

numeric <- c("duration", "credit", "rate", "residence",
                 "age", "nocredit", "no", "TNM_status",
                 "TNM_history", "TNM_purpose", "TNM_bonds", "TNM_jobex",
                 "TNM_sex", "TNM_guarantor", "TNM_property", "TNM_install",
                 "TNM_house", "TNM_job", "TNM_ph", "TNM_nri")

categoric <- NULL

target  <- "R01_credibility"
risk    <- NULL
ident   <- NULL
ignore  <- NULL
weights <- NULL

#============================================================
# Rattle timestamp: 2015-11-01 17:36:51 x86_64-pc-linux-gnu 

# Load the data.

dataset <- read.csv("/home/freestyler/outfile_saved.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

#============================================================
# Rattle timestamp: 2015-11-01 17:36:51 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

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
# Rattle timestamp: 2015-11-01 17:37:01 x86_64-pc-linux-gnu 

# Note the user selections. 

# Build the training/validate/test datasets.

set.seed(crv$seed) 
nobs <- nrow(dataset) # 1000 observations 
sample <- train <- sample(nrow(dataset), 0.7*nobs) # 700 observations
validate <- sample(setdiff(seq_len(nrow(dataset)), train), 0.15*nobs) # 150 observations
test <- setdiff(setdiff(seq_len(nrow(dataset)), train), validate) # 150 observations

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
# Rattle timestamp: 2015-11-01 17:37:07 x86_64-pc-linux-gnu 

# Principal Components Analysis (on numerics only).

pc <- princomp(na.omit(dataset[sample, numeric]), scale=TRUE, center=TRUE, tol=0)

# Show the output of the analysis.

pc

# Summarise the importance of the components found.

summary(pc)

# Display a plot showing the relative importance of the components.

plot(pc, main="")
title(main="Principal Components Importance outfile_saved.csv",
      sub=paste("Rattle", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))


# Display a plot showing the two most principal components.

biplot(pc, main="")
title(main="Principal Components outfile_saved.csv",
      sub=paste("Rattle", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))



