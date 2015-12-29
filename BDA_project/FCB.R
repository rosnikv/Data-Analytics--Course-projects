library(car)
library(stats)
library(graphics)
library(fBasics, quietly=TRUE)
library(reshape, quietly=TRUE)
data<-read.csv("/root/BDA_project/german.csv")

#data$age <- rescale.by.group(data$age, type="irank", itop=4) #work in progress
#data$credit <- rescale.by.group(data$credit, type="irank", itop=4)

set.seed(42)
nobs <- nrow(data) # 1000 observation
sample <- train <- sample(nrow(data), 0.7*nobs) # 700 observations
validate <- sample(setdiff(seq_len(nrow(data)), train), 0.15*nobs) # 150 observations
test <- setdiff(setdiff(seq_len(nrow(data)), train), validate) # 150 observations

target  <- "credibility"
risk    <- NULL
ident   <- NULL
ignore  <- NULL
weights <- NULL
input <- c("status", "duration", "history", "purpose",
     "credit", "bonds", "jobex", "rate",
     "sex", "guarantor", "residence", "property",
     "age", "install", "house", "nocredit",
     "job", "no", "ph", "nri")

numeric <- c("duration", "credit", "rate", "residence",
     "age", "nocredit", "no")

categoric <- c("status", "history", "purpose", "bonds",
     "jobex", "sex", "guarantor", "property",
     "install", "house", "job", "ph",	
     "nri")
lapply(data[sample, c(input, risk, target)][,c(2, 5, 8, 11, 13, 16, 18, 21)], basicStats)

showData(data, placement='-20+200', font=getRcmdr('logFont'), maxwidth=80, maxheight=30, suppress.X11.warnings=FALSE)

