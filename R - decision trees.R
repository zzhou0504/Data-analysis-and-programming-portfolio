rm(list=ls())     
setwd("D:/No Chinese Path Name/Everything R")

library(tree)
library(ISLR)
library(tidyverse)

attach(Carseats)

# split at sales=8
High=ifelse (Sales <=8," No"," Yes ")

# merge with dataset
Carseats =data.frame(Carseats ,High)

# fit classification tree to predict high or not
tree.carseats =tree(High~.-Sales ,Carseats )
summary(tree.carseats)
# gives training error rate
# you want deviance to be small, means good fit

# plot with qualitative variable names
plot(tree.carseats)
text(tree.carseats ,pretty =0)

# tree in words
tree.carseats

# evaluate fit with train and test 
set.seed (2)
train=sample(1: nrow(Carseats ), 200)
Carseats.test=Carseats[-train ,]
High.test=High[-train ]

tree.carseats =tree(High~.-Sales,Carseats,subset =train )
tree.pred=predict(tree.carseats ,Carseats.test,type ="class")
table(tree.pred,High.test)

# cv tree to determine level of tree complexity
set.seed(3)
cv.carseats =cv.tree(tree.carseats,FUN=prune.misclass) # pick classification error rate, instead of default (deviance) to guide CV and pruning
cv.carseats

# plot error rate as function of size and k
par(mfrow =c(1,2))
plot(cv.carseats$size,cv.carseats$dev,type="b")
plot(cv.carseats$k,cv.carseats$dev,type="b")

# prune to get best tree (with 9 terminal nodes)
prune.carseats =prune.misclass(tree.carseats,best =9)
plot(prune.carseats)
text(prune.carseats,pretty =0)

# evaluate this tree
tree.pred=predict(prune.carseats, Carseats.test,type="class")
table(tree.pred,High.test)

