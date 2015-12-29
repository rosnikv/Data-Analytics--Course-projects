library(arules)
library(arulesViz)
library(datasets)

# Load the data set
#data(Groceries)
groceries <- read.transactions("/home/freestyler/BDA_project2/groceries.csv", sep = ",")
inspect(groceries[1:2])
print(dim(groceries)[1])

#print each item with support greater than 0.025
itemFrequencyPlot(groceries,support=0.025,cex.names=0.8,xlim=c(0,0.3),type="relative",horiz=TRUE,col="dark red",las=1,xlab=paste("Proportions of Market Baskets containing Item","\n(Item Relative Frequency or Support)"))
#Explore possibilities for combining similar items
#data(Groceries)
#print(head(itemInfo(Groceries)))
#print(levels(itemInfo(Groceries)[["level2"]]))
#LIST(groceries)[1]
summary(groceries)

mm <- t(as(groceries,"ngCMatrix"))
new<- mm*1
new<- as.matrix(new)
#new2<- as.matrix(as.logical(new))
library("MASS")
write.matrix(format(new, scientific=FALSE),file ="/home/freestyler/dat3.csv", sep=",")

rules = apriori(groceries, parameter=list(support=0.01, confidence=0.5))
summary(rules)
#Inspect the top 5 rules in terms of lift:

inspect(head(sort(rules, by ="lift"),5))

#Plot a frequency plot:

itemFrequencyPlot(groceries, topN = 25)



#Scatter plot of rules:

library("RColorBrewer")

plot(rules,control=list(col=brewer.pal(11,"Spectral")),main="")

#Rules with high lift typically have low support.

#The most interesting rules reside on the support/confidence border which can be clearly seen in this plot.



#Plot graph-based visualisation:

subrules2 <- head(sort(rules, by="lift"), 3)

plot(subrules2, method="graph",control=list(type="items",main=""))
