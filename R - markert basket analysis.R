rm(list=ls())     
setwd("D:/No Chinese Path Name/Everything R")

# e.g. association rules:
# * Assume there are 100 transactions by customers
# 10 of them bought milk, 8 bought butter and 6 bought both of them
# bought milk => bought butter
# support = P(Milk & Butter) = 6/100 = 0.06
# confidence = support/P(Butter) = 0.06/0.08 = 0.75, proportion of transactions wher customers bought both
# OR: the probability of finding the RHS of the rule in transactions under the condition that these transactions also contain the LHS
# lift = confidence/P(Milk) = 0.75/0.10 = 7.5
# OR: the ratio of the observed support to that expected if X and Y were independent (effect)

library(tidyverse)
library(readxl)
library(knitr)
library(ggplot2)
library(lubridate)
library(arules)
library(arulesViz)
library(plyr)

# pre-processing

retail = read_excel('Online Retail.xlsx')
# remove missing values
retail = retail[complete.cases(retail), ] 
# converting types
retail = mutate(retail, Description = as.factor(Description), Country = as.factor(Country))
retail$Date = as.Date(retail$InvoiceDate)
retail$Time = format(retail$InvoiceDate,"%H:%M:%S")
retail$InvoiceNo = as.numeric(as.character(retail$InvoiceNo))
glimpse(retail)

# what time do people purchase?

retail$Time = as.factor(retail$Time)

ggplot(data=retail,aes(x=Time)) + 
  geom_histogram(stat="count",fill="indianred")

# how many items each customer buy?

detach("package:plyr", unload=TRUE)
retail %>% 
  group_by(InvoiceNo) %>% 
  summarize(n_items = mean(Quantity)) %>%
  ggplot(aes(x=n_items))+
  geom_histogram(fill="indianred", bins = 100000) + 
  geom_rug()+
  coord_cartesian(xlim=c(0,80))

# top 10 best sellers

group_by(retail, StockCode, Description) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# transform transactions into items bought together

retail_sorted = retail[order(retail$CustomerID),]
library(dplyr)
itemList = ddply(retail,c("CustomerID","Date"), 
                  function(df1)paste(df1$Description, 
                                     collapse = ","))

# remove customer ID and date bc we don't need them
itemList$CustomerID = NULL
itemList$Date = NULL
colnames(itemList) = c("items")
# write into new csv file
write.csv(itemList,"market_basket.csv", quote = FALSE, row.names = TRUE)

tr = read.transactions('market_basket.csv', format = 'basket', sep=',')
summary(tr)

# see item frequency
itemFrequencyPlot(tr, topN=20, type='absolute')

# set rules and order by confidence
rules=apriori(tr, parameter = list(supp=0.001, conf=0.8))
rules=sort(rules, by='confidence', decreasing = TRUE)
summary(rules)
inspect(rules[1:10])
# interpretation: 100% (confidence) of customers who bought WOBBLY CHICKEN also bought DECORATION

plot(rules[1:10], method = "graph")
plot(rules[1:10], method = "grouped")
