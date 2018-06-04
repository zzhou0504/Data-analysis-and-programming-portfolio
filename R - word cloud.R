rm(list=ls())     
setwd("D:/No Chinese Path Name/Everything R")
library(tidyverse)

library(tm)
library("tm") 
library("SnowballC") # for text stemming
library("wordcloud") # word-cloud generator
library("RColorBrewer") # color palettes

# Read the text file from internet
filePath <- "http://www.sthda.com/sthda/RDoc/example-files/martin-luther-king-i-have-a-dream-speech.txt"
text <- readLines(filePath)

# Load the data as a corpus
docs <- Corpus(VectorSource(text))

# see text content
inspect(docs)

# replace special characters with space
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")

# clean text
# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("blabla1", "blabla2")) 
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# Text stemming
# docs <- tm_map(docs, stemDocument)

# build term-document matrix
dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)

# build word cloud
set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 3,
          max.words=100, scale=c(4,.5), random.order=FALSE, rot.per=0.35, colors=brewer.pal(8, "Dark2"))

res<-rquery.wordcloud(filePath, type ="file", lang = "english",
                      min.freq = 1,  max.words = 200)

# when plotting, make sure plot window is big enough