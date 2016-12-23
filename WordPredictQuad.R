library(rJava)
library(stringi)
library(NLP)
library(tm)
library(RWeka)
library(ggplot2)
library(qdapRegex)
library(slam)
library(reshape2)

#Read all the lines of the 3 files
fileName="en_US.blogs.txt"
con=file(fileName,open="r")
lineBlogs=readLines(con, encoding = 'UTF-8') 
close(con)

fileName="en_US.news.txt"
con=file(fileName,open="r")
lineNews=readLines(con, encoding = 'UTF-8') 
close(con)

fileName="en_US.twitter.txt"
con=file(fileName,open="r")
lineTwitter=readLines(con, encoding = 'UTF-8')
close(con)

#Sample the Files
set.seed(123)
index <- sample(1:length(lineBlogs),length(lineBlogs)/20)
subLineBlogs <- lineBlogs[index]
set.seed(123)
index <- sample(1:length(lineNews),length(lineNews)/20)
subLineNews <- lineNews[index]
set.seed(123)
index <- sample(1:length(lineTwitter),length(lineTwitter)/20)
subLineTwitter <- lineTwitter[index]

#Clean up the Data
#combine everything
sample <- c(subLineBlogs,subLineNews,subLineTwitter)
#To Lower Case
cleanSample <- stri_trans_tolower(sample)
#Remove Punctuation
cleanSample <- removePunctuation(cleanSample,preserve_intra_word_dashes = TRUE)
#Remove Numbers
cleanSample <- removeNumbers(cleanSample)
#Remove Whitespace
cleanSample <- stripWhitespace(cleanSample)
#Replace Accented Words, Emojis
cleanSample <- rm_emoticon(cleanSample)
#cleanSample <- iconv(cleanSample, to = "ASCII//TRANSLIT")
#Remove Profanity
profanity <- readLines(con <- file("./profanity.txt", "r"))
close(con)
#source: https://gist.github.com/ryanlewis/a37739d710ccdb4b406d
cleanSample <- removeWords(cleanSample,profanity)

rm(lineBlogs)
rm(lineNews)
rm(lineTwitter)
rm(subLineBlogs)
rm(subLineNews)
rm(subLineTwitter)
rm(con)
rm(fileName)
rm(profanity)
rm(index)

#Create the Corpus
corpus <- VCorpus(VectorSource(cleanSample))

#Build the functions to tokenize
unigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 1))
bigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
trigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
quadgramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 4, max = 4))

#Create TermDocumentMatrix
unigram <- TermDocumentMatrix(corpus, control = list(tokenize = unigramTokenizer))
bigram <- TermDocumentMatrix(corpus, control = list(tokenize = bigramTokenizer))
trigram <- TermDocumentMatrix(corpus, control = list(tokenize = trigramTokenizer))
quadgram <- TermDocumentMatrix(corpus, control = list(tokenize = quadgramTokenizer))

#Cleanup
rm(corpus,sample,cleanSample)

#Convert to sorted Data Frames
unigramN <- sort(row_sums(unigram, na.rm = T), decreasing = T)
bigramN <- sort(row_sums(bigram, na.rm = T), decreasing = T)
trigramN <- sort(row_sums(trigram, na.rm = T), decreasing = T)
quadgramN <- sort(row_sums(quadgram, na.rm = T), decreasing = T)

unigramDF <- melt(unigramN)
unigramDF$Word <- rownames(unigramDF)
colnames(unigramDF)[which(names(unigramDF) == "value")] <- "Frequency"

bigramDF <- melt(bigramN)
bigramDF$Word <- rownames(bigramDF)
colnames(bigramDF)[which(names(bigramDF) == "value")] <- "Frequency"
bigramDF <- cbind(bigramDF,colsplit(bigramDF$Word, pattern = " ", c("Word1", "Word2")))

trigramDF <- melt(trigramN)
trigramDF$Word <- rownames(trigramDF)
colnames(trigramDF)[which(names(trigramDF) == "value")] <- "Frequency"
trigramDF <- cbind(trigramDF,colsplit(trigramDF$Word, pattern = " ", c("Word1", "Word2", "Word3")))

quadgramDF <- melt(quadgramN)
quadgramDF$Word <- rownames(quadgramDF)
colnames(quadgramDF)[which(names(quadgramDF) == "value")] <- "Frequency"
quadgramDF <- cbind(quadgramDF,colsplit(quadgramDF$Word, pattern = " ", c("Word1", "Word2", "Word3","Word4")))

saveRDS(unigramDF, file = "./unigramDF.RData")
saveRDS(bigramDF, file = "./bigramDF.RData")
saveRDS(trigramDF, file = "./trigramDF.RData")
saveRDS(quadgramDF, file = "./quadgramDF.RData")