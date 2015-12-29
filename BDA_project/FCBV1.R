library(car)
library(stats)
library(graphics)
library(fBasics, quietly=TRUE)
library(reshape, quietly=TRUE)
library(randomForest, quietly=TRUE)
data<-read.csv("/home/freestyler/BDA_project/Data/german.csv")

#data$age <- rescale.by.group(data$age, type="irank", itop=4) #work in progress
#data$credit <- rescale.by.group(data$credit, type="irank", itop=4)

set.seed(42)
nobs <- nrow(data) # 1000 observation
sample <- train <- sample(nrow(data), 0.7*nobs) # 700 observations
validate <- sample(setdiff(seq_len(nrow(data)), train), 0.15*nobs) # 150 observations
test <- setdiff(setdiff(seq_len(nrow(data)), train), validate) # 150 observations

ytrain <- data$credibility[train]
ynew <- data$credibility[-train]
df<- data.frame(ytrain)
str(df)
table(df)
df1<- data.frame(ynew)
str(df1)
table(df1)

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
lp <- lapply(data[sample, c(input, risk, target)][,c(2, 5, 8, 11, 13, 16, 18, 21)], basicStats)
lp


df<- data.frame(sample)
table(df$credibility)

rf <- randomForest::randomForest(as.factor(credibility) ~ .,
      data=data[sample,c(input, target)], 
      ntree=400,
      mtry=4,
      importance=TRUE,
      na.action=randomForest::na.roughfix,
      replace=FALSE)
rf
randomForest::varImpPlot(rf, main="variable importance curve")


library(verification)
aucc <- verification::roc.area(as.integer(as.factor(data[sample, target]))-1,
                 rf$votes[,2])$A
verification::roc.plot(as.integer(as.factor(data[sample, target]))-1,
         rf$votes[,2], main="ROC Curve Random forest")

library(rpart)
rpart <- rpart(credibility ~ .,
                   data=data[train, c(input, target)],
                   method="class",
                   parms=list(split="information"),
                   control=rpart.control(usesurrogate=0, 
                                         maxsurrogate=0))
print(rpart)

printcp(rpart)
				   
library(rattle)					
library(rpart.plot)			
library(RColorBrewer)
library(party)
library(partykit)				
library(caret)					
						
plot(rpart)			
text(rpart)

prp(rpart) # Will plot the tree
prp(rpart,varlen=3) # Shorten variable names

fancyRpartPlot(rpart)

prp(rxAddInheritance(rpart))
fancyRpartPlot(rxAddInheritance(rpart))
library(relimp, pos=45)
showData(data, placement='-20+200', font=getRcmdr('logFont'), maxwidth=80, 
  maxheight=30, suppress.X11.warnings=FALSE)

