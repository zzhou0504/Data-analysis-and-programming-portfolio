
rm(list=ls())     
setwd("D:/No Chinese Path Name/Everything R")

library(ISLR) # the data

Hitters=na.omit(Hitters) # remove NAs

x=model.matrix(Salary~.,Hitters)[,-1] 
# x in lasso has to be a matrix (like a 2d list with each obs as a vector of predictor values); 
# "response~all predictors, data"; 
# model.matrix transforms qualitative predictors into dummies
# [,-1] removes header from original data
y=Hitters$Salary # response

library(glmnet) # alpha=1 for lasso, =0 for ridge

grid=10^seq(10,-2,length=100) # select range of lambda values, from 10^10 to 10^-2, 100 different values

ridge.mod=glmnet(x,y,alpha=0,lambda=grid) 
coef(ridge.mod) # coefficients are stored in matrix with 20 rows (predictors+header) and 100 cols (100 lambdas)

# use predict
# get coefs for a new lambda, e.g. 50
predict(ridge.mod, s=50, type="coefficients")[1:20,] # show rows 1-20 and all cols

# separate sample into test and training obs
# approach: ramdomly choose a subset of numbers between 1-n - as indices
set.seed(1)
train=sample(1:nrow(x), nrow(x)/2) # sample(what to sample from, size is half)
test=(-train)
y.test=y[test] # just the y from test subset

ridge.mod=glmnet(x[train,], y[train], alpha=0, lambda=grid,thresh=1e-12) # using xs and ys from training subset, ridge, same lambda grid, 
ridge.pred=predict(ridge.mod, s=4, newx=x[test,]) # model from traning, using new lambda=4, fit model in test xs, gives predict test ys
mean((ridge.pred-y.test)^2) # test MSE

# see if ridge does better than simple OLS
ridge.pred.ols=predict(ridge.mod, s=0, newx=x[test,]) # still using predict, set lambda=0 makes it equivalent to OLS
mean((ridge.pred.ols-y.test)^2) # see MSE of OLS

# in general, we don't choose lambda, CV does it
# cv.glmnet() does 10 folds by default

set.seed(1)
cv.out=cv.glmnet(x[train,], y[train], alpha=0)
plot(cv.out) # gives graph with log_lambda and MSE
bestlam=cv.out$lambda.min # extract best lambda that gives min MSE
bestlam

ridge.pred=predict(ridge.mod, s=bestlam, newx=x[test,]) # take model from training, use best lambda, take xs from test, predict ys
mean((ridge.pred-y.test)^2) # see MSE of cv ridge

# refit ridge model to ALL data, using best lambda
out=glmnet(x,y,alpha=0)
predict(out, type="coefficients",s=bestlam)[1:20,]

### lasso ###

lasso.mod=glmnet(x[train,], y[train], alpha=1, lambda=grid) # same steps except alpha=1
plot.glmnet(lasso.mod,xvar="lambda")

set.seed(1)
cv.out=cv.glmnet(x[train,], y[train], alpha=1)
plot(cv.out)
bestlam=cv.out$lambda.min
lasso.pred=predict(lasso.mod, s=bestlam, newx=x[test,])
mean((lasso.pred-y.test)^2)

# lasso produces similar MSE to ridge, but coefs are sparse
out=glmnet(x,y,alpha=1,lambda=grid)
lasso.coef=predict(out, type="coefficients", s=bestlam)[1:20,] # refit steps: run lasso, use best lambda from cv in predict
lasso.coef

