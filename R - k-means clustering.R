rm(list=ls())     
setwd("D:/No Chinese Path Name/Everything R")

library(datasets)
head(iris)
library(ggplot2)
# initial visual explorations show differences in petal length and width among species
ggplot(iris, aes(Petal.Length, Petal.Width, color = Species)) + geom_point()

set.seed(20)
irisCluster = kmeans(iris[, 3:4], 3, nstart = 20) # second argument specifies k=3 because we know there are 3 species
irisCluster

# compare clusters with true species
table(irisCluster$cluster, iris$Species)

# plot clusters
irisCluster$cluster = as.factor(irisCluster$cluster)
ggplot(data=iris, aes(Petal.Length, Petal.Width, color = irisCluster$cluster)) + geom_point()
