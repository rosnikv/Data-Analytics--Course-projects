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
table(ynew, nearest3)


#library(class)
#nearest1 <- knn(train=xtrain, test=xnew, cl=ytrain, k=1)
#nearest3 <- knn(train=xtrain, test=xnew, cl=ytrain, k=7)
#data<- data.frame(ynew,nearest1,nearest3)[1:10,]
#nearest3 <-as.vector(nearest3,mode="numeric")
#str(nearest3)
#ynew <- as.vector(ynew, mode = "numeric")
#table(dataset[test, c(input, target)]$R01_credibility, nearest1,
 #     dnn=c("Actual", "Predicted"))

table(dataset[test, c(input, target)]$R01_credibility, nearest3,
      dnn=c("Actual", "Predicted"))

pcme <- function(ynew, nearest3)
{
  x <- table(ynew, nearest3)
  tbl <- cbind(round(x/length(ynew), 2),
               Error=round(c(x[1,2]/sum(x[1,]),
                             x[2,1]/sum(x[2,])), 2))
  names(attr(tbl, "dimnames")) <- c("Actual", "Predicted")
  return(tbl)
};
pcme(na.omit(dataset[test, c(input, target)])$R01_credibility, nearest3)



library(ROCR)
library(ggplot2, quietly=TRUE)
nearest3 <-as.vector(nearest3,"numeric")
#nearest1 <-as.vector(nearest1,"numeric")
ynew <- as.vector(ynew, mode = "numeric")

pred_knn <- prediction(nearest3, ynew)

pe <- performance(pred_knn, "tpr", "fpr")
au <- performance(pred_knn, "auc")@y.values[[1]]
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




#pred_knn <- performance(pred_knn, "tpr", "fpr")
#plot(pred_knn, avg= "threshold", colorize=T, lwd=3, main="Voilà, a ROC curve!")

library(class)
nearest3 <- knn(train=xtrain, test=xnew, cl=ytrain, k=7)
table(ynew, nearest3)
#pcorrn1=100*sum(ynew==nearest1)/100
pcorrn3=100*sum(ynew==nearest3)/100
#pcorrn1
pcorrn3


#plot(xtrain[,c("duration","credit")],col=c(4,3,6,2)[dataset[train,"rate"]],pch=c(1,2)[as.numeric(ytrain)],main="Predicted default, by 3 nearest neighbors",cex.main=.95)
#points(xnew[,c("duration","credit")],bg=c(4,3,6,2)[dataset[train,"rate"]],pch=c(21,24)[as.numeric(nearest3)],cex=1.2,col=grey(.7))
#legend("bottomright",pch=c(1,16,2,17),bg=c(1,1,1,1),legend=c("data 0","pred 0","data 1","pred 1"),title="R01_credibility",bty="n",cex=.8)
#legend("topleft",fill=c(4,3,6,2),legend=c(1,2,3,4),title="RMA_rate %",horiz=TRUE,bty="n",col=grey(.7),cex=.8)


## above was for just one training set
## cross-validation (leave one out)
psum<- 0
pavg<- 0.0
pcorr=dim(15)
for (k in 1:15) {
  pred=knn.cv(dataset,cl=dataset$R01_credibility,k)
  pcorr[k]=100*sum(dataset$R01_credibility==pred)/1000
  psum<- psum+pcorr[k]
  }
pcorr
pavg<- psum/15


library(rpart)
dataset <- read.csv("/home/freestyler/outfile_saved.csv")
n<-nrow(dataset)
K<-10
divide<- n %/% K
set.seed(5)
#The runif() function can be used to simulate n independent uniform random variables.
unirand<-runif(n)
#rank returns the lowest order of position, returns the sample ranks of the values in a vector.
rang<-rank(unirand)
bloc<-(rang - 1)%/%divide +1
bloc<-as.factor(bloc)
print(summary(bloc))

all.err<- numeric(0)
all.sense<-numeric(0)
all.spese<-numeric(0)
all.acc1<-numeric(0)
for(k in 1:K){
  xtrain<-dataset[bloc!=k,]
  xnew<-dataset[bloc==k,]
  ytrain<-dataset$R01_credibility[bloc!=k]
  nearest <- knn(train=xtrain, test=xnew, cl=ytrain, k=7)
  #pred <- knn.predict(nearest,newdata = dataset[bloc==k,],type = "class")
  #confusion matrix for each partition
  mc<-table(dataset$R01_credibility[bloc==k],nearest)
  err<-1.0 - (mc[1,1]+mc[2,2])/sum(mc)
  acc1<-1-(err)
  a<-mc[1,1]
  b<-mc[1,1]+mc[1,2]
  sensitivity<-a/b
  c<-mc[2,2]
  d<-mc[2,2]+mc[2,1]
  specificity<-c/d
  #function combines vector, matrix or data frame by rows.
  all.sense<-rbind(all.sense,sensitivity)
  all.spese<-rbind(all.spese,specificity)
  #all.err <- rbind(all.err,err)
  all.acc1<-rbind(all.acc1,acc1)
}
print(all.sense)
print(all.spese)
#print(all.err)
print(all.acc1)

sens.cv<-mean(all.sense)
print(sens.cv)

spec.cv<-mean(all.spese)
print(spec.cv)

acc1.cv<-mean(all.acc1)
print(acc1.cv)
