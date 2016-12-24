Word Prediction Application - Coursera Data Science Specialization  
Word Prediction Application - Capstone Project
========================================================
author: Nazmi Anik
date: 12/23/2016
autosize: true

Purpose of this presentation is to give an overview of the application to predict next word in text input and offer future enhancements.

This application was developed for the Coursera Data Science Specialization - Data Science Capstone class.
Data Sources
========================================================

The data that was used for this project was taken from [this link]("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"). Only the English language files were used for the purpose of this application.

Below is the code run to get the word and line counts of the files used for learning word relationships.  


```r
lines <- c(length(lineBlogs),length(lineNews),length(lineTwitter))
wordBlogs <- sum(stri_count_words(lineBlogs))
wordNews <- sum(stri_count_words(lineNews))
wordTwitter <- sum(stri_count_words(lineTwitter))
words <- c(wordBlogs,wordNews,wordTwitter)
table <- as.data.frame(rbind(lines,words))
colnames(table) <- c("Blogs","News","Twitter")
table
```
The counts are displayed in the table below:  

| Counts | Blogs | News | Twitter |
|:-----:|:----:|:-------:|:------:|
|   lines  |  899288  |    77259   |    2360148  |
|  words  |  37546246 |   2674536   |   30093369  |
 

Cleaning the Data
========================================================

The data was sampled at 1/20 ratio to make the calculations faster and the initial load in a reasonable time.  
Afterwards, data was cleaned to increase the accuracy of the prediction. All words were transformed to lowercase; punctuation, numbers, emoticons and extra spaces were removed. Finally profanities were also removed.  

```r
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
#Remove Profanity
profanity <- readLines(con <- file("./profanity.txt", "r"))
close(con)
#source: https://gist.github.com/ryanlewis/a37739d710ccdb4b406d
cleanSample <- removeWords(cleanSample,profanity)
```

Prediction Algorithm
========================================================

After the data was cleaned, it was all put into a corpus object and then tokenized into N-Grams. Simply put, occurances of words alone, word pairs, word triplets and word quartets in our source data were grouped together and sorted according to how often they appeared.  

This way when a user inputs some words, we could check the last three words and match them with first three words of word quartets. Based on occurance frequency, we could then return the most commonly occuring words as the upcoming fourth word. The code below shows this:  

```r
 if(nWords >= 3){
        #grab the last three words
        input1 <- tail(unlist(stri_split(cleanInput,regex = " ")),3)[1]
        input2 <- tail(unlist(stri_split(cleanInput,regex = " ")),3)[2]
        input3 <- tail(unlist(stri_split(cleanInput,regex = " ")),3)[3]
        vlookup <- subset(quadgramDF,Word1 == input1 & Word2 == input2 & Word3 == input3)
        #return first 5 matched non-NA words
        if(nrow(vlookup) > 5){return(vlookup[1:5,6])}
        return(vlookup[1:nrow(vlookup),6])
    }
```

If the given input did not match anything in the word quartets, then we back-off and try to find observations of last two words in word triplets; last word in word pairs; and if that does not work, then we give the 5 most commonly used single words as predictions.  

Application and Source Code
========================================================

Here is how the application looks:  
![Application Screenshot](app.png)  
The link to the application is [here]().  
The link to the source code is [here]().
