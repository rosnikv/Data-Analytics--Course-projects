data<-read.csv("/root/BDA_project/german.csv")
names(data)
data$purpose <- factor(data$purpose, levels=c('A40','A41','A410','A42','A43','A44','A45','A46',
  'A48','A49'), ordered=TRUE)
data$credit_band <- bin.var(data$credit, bins=3, method='intervals', labels=FALSE)
data$credit_band1 <- bin.var(data$credit, bins=3, method='natural', labels=FALSE)
write.table(data, "/root/BDA_project/german.csv", sep=",", col.names=TRUE, row.names=TRUE, quote=TRUE, na="NA")

