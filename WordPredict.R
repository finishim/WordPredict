library(rJava)
library(stringi)
library(NLP)
library(tm)
library(RWeka)
library(ggplot2)
library(qdapRegex)
library(slam)
library(reshape2)
library(markovchain)
#library(caTools)

url_train <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"

if(!file.exists('en_US.blogs.txt')){
    #check if .zip file exists
    if(!file.exists('.\\data\\Coursera-SwiftKey.zip')){
        download.file(url=url_train,".\\data\\Coursera-SwiftKey.zip")
    }
    
    #check if file is already unzipped
    if(!file.exists('.\\data\\final\\en_US')){
        unzip('.\\data\\Coursera-SwiftKey.zip',exdir='.\\data')
    }
    
    #copy the files into the working directory
    #source: http://stackoverflow.com/questions/2384517/using-r-to-copy-files
    flist <- list.files(".\\data\\final\\en_US", "^en_US.+[.]txt$", full.names = TRUE)
    file.copy(flist, ".\\")
}

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

#Get the length of the longest line in each file
lenBlogs<-stri_length(lineBlogs)
lenNews<-stri_length(lineNews)
lenTwitter<-stri_length(lineTwitter)

#Summarize the File Sizes
lines <- c(length(lineBlogs),length(lineNews),length(lineTwitter))
wordBlogs <- sum(stri_count_words(lineBlogs))
wordNews <- sum(stri_count_words(lineNews))
wordTwitter <- sum(stri_count_words(lineTwitter))
words <- c(wordBlogs,wordNews,wordTwitter)
table <- as.data.frame(rbind(lines,words))
colnames(table) <- c("Blogs","News","Twitter")
table

#Sample the Files
set.seed(123)
index <- sample(1:length(lineBlogs),length(lineBlogs)/100)
subLineBlogs <- lineBlogs[index]
set.seed(123)
index <- sample(1:length(lineNews),length(lineNews)/100)
subLineNews <- lineNews[index]
set.seed(123)
index <- sample(1:length(lineTwitter),length(lineTwitter)/100)
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

# set.seed(123)
# split = sample.split(cleanSample, 0.7)
# train <- subset(cleanSample, split == T)
# valid <- subset(cleanSample, split == F)

#Remove Unused variables to conserve RAM
rm(lineBlogs)
rm(lineNews)
rm(lineTwitter)
rm(subLineBlogs)
rm(subLineNews)
rm(subLineTwitter)
rm(wordTwitter)
rm(wordBlogs)
rm(wordNews)
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
#Create TermDocumentMatrix
unigram <- TermDocumentMatrix(corpus, control = list(tokenize = unigramTokenizer))
bigram <- TermDocumentMatrix(corpus, control = list(tokenize = bigramTokenizer))
trigram <- TermDocumentMatrix(corpus, control = list(tokenize = trigramTokenizer))

#Cleanup
rm(corpus,sample,cleanSample)

#Save the TDM's
saveRDS(unigram, file = "./unigram.RData")
saveRDS(bigram, file = "./bigram.RData")
saveRDS(trigram, file = "./trigram.RData")
#Convert to sorted Data Frames
unigramN <- sort(row_sums(unigram, na.rm = T), decreasing = T)
bigramN <- sort(row_sums(bigram, na.rm = T), decreasing = T)
trigramN <- sort(row_sums(trigram, na.rm = T), decreasing = T)

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
#colnames(dataframe)[which(names(dataframe) == "columnName")] <- "newColumnName"
#source: http://stackoverflow.com/questions/6081439/changing-column-names-of-a-data-frame-in-r

saveRDS(unigramDF, file = "./unigramDF.RData")
saveRDS(bigramDF, file = "./bigramDF.RData")
saveRDS(trigramDF, file = "./trigramDF.RData")

#Cleanup
rm(unigramN, bigramN, trigramN)

#Explore the N-Grams 
# unigrams appearing more than 1000 times
findFreqTerms(unigram, lowfreq = 1000)
# bigrams apprering more than 200 times
findFreqTerms(bigram, lowfreq = 200)
# trigrams apprering more than 50 times
findFreqTerms(trigram, lowfreq = 50)

#Plot the NGrams
#source: https://rpubs.com/bjpzhao/Data-Science-Capstone-Milestone
uni20 <- unigramDF[1:20,]
bi20 <- bigramDF[1:20,]
tri20 <- trigramDF[1:20,]
#Top20 single words
g <- ggplot(uni20, aes(x=Word,y=Frequency), ) + geom_bar(stat="Identity", fill="blue") + geom_text(aes(label=Frequency), vjust=-0.2) + theme(axis.text.x=element_text(angle=90, hjust=1))
g
#Top 20 word pairs
h <- ggplot(bi20, aes(x=Word,y=Frequency), ) + geom_bar(stat="Identity", fill="blue") + geom_text(aes(label=Frequency), vjust=-0.2) + theme(axis.text.x=element_text(angle=90, hjust=1))
h
#Top 20 word triplets
j <- ggplot(tri20, aes(x=Word,y=Frequency), ) + geom_bar(stat="Identity", fill="blue") + geom_text(aes(label=Frequency), vjust=-0.2) + theme(axis.text.x=element_text(angle=90, hjust=1))
j

#Cleanup
rm(uni20,bi20,tri20, g, h, j)

input <- "In accordance"
inputCleaner <- function(input){
    #To Lowercase
    cleanInput <- stri_trans_tolower(input)
    #Remove Punctuation
    cleanInput <- removePunctuation(cleanInput,preserve_intra_word_dashes = TRUE)
    #Remove Numbers
    cleanInput <- removeNumbers(cleanInput)
    #Remove Whitespace
    cleanInput <- stripWhitespace(cleanInput)
    #Replace Accented Words, Emojis
    cleanInput <- rm_emoticon(cleanInput)
    #cleanSample <- iconv(cleanSample, to = "ASCII//TRANSLIT")
    #Remove Profanity
    cleanInput <- removeWords(cleanInput,profanity)
}
cleanInput <- inputCleaner(input)