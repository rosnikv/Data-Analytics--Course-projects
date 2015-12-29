setwd("/root/BDA_project/")

g.data <- read.delim("/root/BDA_project/Data/german.data",header=F,sep=" ")
#g.data <- read.csv("/root/BDA_project/german_test.csv", header = F)

head(g.data)# "head" displays the first six observations
dim(g.data)

#is.numeric(g.data$age)

names(g.data) <- c("chk_acct", "duration", "history", "purpose", "amount", "sav_acct", "employment", "install_rate", "pstatus", "other_debtor", "time_resid", "property", "age", "other_install", "housing", "other_credits", "job", "num_depend", "telephone", "foreign", "response")
head(g.data)

#Suppose we want to check the distribution of amount in the given data. We can use a simple plot command.

#plot(g.data$amount, type = "l", col = "royalblue")
#plot(g.data$age, type = "l", col = "brown")

# histograms to check the frequency distribution of these variables.
#hist(g.data$amount)
#hist(g.data$age)

g.data$amt.fac <- as.factor(ifelse(g.data$amount <= 2500, "0-2500", 
                                  ifelse(g.data$amount <= 5000, "2600-5000", "5000+")))
head(g.data$amt.fac)

g.data$age.fac <- as.factor(ifelse(g.data$age<=30, '0-30', ifelse(g.data$age <= 40, '30-40', '40+')))
head(g.data$age.fac)

g.data$default <- as.factor(ifelse(g.data$response == 1, "0", "1"))
is.factor(g.data$default)
contrasts(g.data$default)
head(g.data$default)

attach(g.data)

#R provides many functions to plot categorical data.
mosaicplot(default ~ age.fac, col = T)
mosaicplot(default ~ job, col = T)
mosaicplot(default ~ chk_acct, col = T)


# a spine plot.
spineplot(default ~ age.fac)

library(lattice)
xyplot(amount ~ age)

#condition on a variable and see the interaction
xyplot(amount ~ age | default)


d <- sort(sample(nrow(g.data), nrow(g.data)*0.7))

dev<-g.data[d,]
val<-g.data[-d,]

dim(g.data)
dim(dev)
dim(val)




##########-------------2.1: Logistic regression------------###############

m1.logit <- glm(default ~ 
                          amt.fac + 
                          age.fac + 
                          duration +
                          chk_acct +
                          history +
                          purpose +
                          sav_acct +
                          employment +
                          install_rate + 
                          pstatus +
                          other_debtor +
                          time_resid +
                          property +
                          other_install + 
                          housing +
                          other_credits +
                          job +
                          num_depend + 
                          telephone + 
                          foreign
                                  , family = binomial(link = "logit"), data = dev)

# The glm command is for "Generalized Linear Models"
# "~" is the separator between the dependent (or target variable) and the independent variables
# Independent variables are separated by the "+" sign
# "data" requires the data frame in the which the variables are stored
# "family" is used to specify the assumed distribution


summary(m1.logit)

val$m1.yhat <- predict(m1.logit, val, type = "response")
# The predict command runs the regression model on the "val" dataset and stores the estimated  y-values, i.e, the yhat.

library(ROCR)
m1.scores <- prediction(val$m1.yhat, val$default)
# The prediction function of the ROCR library basically creates a structure to validate our predictions, "val$yhat" with respect to the actual y-values "val$default"

plot(performance(m1.scores, "tpr", "fpr"), col = "red")
abline(0,1, lty = 8, col = "grey")
# "tpr" and "fpr" are arguments of the "performance" function indicating that the plot is between the true positive rate and the false positive rate.
# "col" is an argument to the plot function and indicates the colour of the line
# "abline" plots the diagonal, "lty" is the line type which is used to create the dashed line


m1.perf <- performance(m1.scores, "tpr", "fpr")
ks1.logit <- max(attr(m1.perf, "y.values")[[1]] - (attr(m1.perf, "x.values")[[1]]))
ks1.logit


  ## 2.2.2: Decision tree with priors  ##

t1.prior <- rpart(default ~ 
                          amt.fac + 
                          age.fac + 
                          duration +
                          chk_acct +
                          history +
                          purpose +
                          sav_acct +
                          employment +
                          install_rate + 
                          pstatus +
                          other_debtor +
                          time_resid +
                          property +
                          other_install + 
                          housing +
                          other_credits +
                          job +
                          num_depend + 
                          telephone + 
                          foreign
                                , data = dev, parms = list(prior = c(0.9, 0.1)))
# Not the difference in the commands for a tree with priors and a tree without one. Here we need to specify the priors along with the formula in the rpart() function command.

plot(t1.prior)
# Plots the trees
text(t1.prior)
# Adds the labels to the trees.

#We don't need to prune this model and can score it right away
val$t1.p.yhat <- predict(t1.prior, val, type = "prob")

#We can plot the ROC curve for the tree with priors.
t1.p.scores <- prediction(val$t1.p.yhat[,2], val$default)
t1.p.perf <- performance(t1.p.scores, "tpr", "fpr")

# Plot the ROC curve
plot(t1.p.perf, col = "blue", lwd = 1)

# Add the diagonal line and the ROC curve of the logistic model, ROC curve of the tree without priors
#plot(t1.p.perf, col = "blue", lwd = 1,add=TRUE)
plot(m1.perf, col = "red", lwd = 1, add = TRUE)
plot(t1.p.perf, col = "green", lwd = 1.5, add = TRUE)
abline(0, 1, lty = 8, col = "grey")
legend("bottomright", legend = c("tree w/o prior", "tree with prior", "logit"), col = c("green", "blue", "red"), lwd = c(1.5, 1, 1))

#KS statistic
ks1.p.tree <- max(attr(t1.p.perf, "y.values")[[1]] -(attr(t1.p.perf, "x.values")[[1]]))
ks1.p.tree

#AUC
t1.p.auc <- performance(t1.p.scores, "auc")
t1.p.auc
