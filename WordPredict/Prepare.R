library(rJava)
library(stringi)
library(NLP)
library(tm)
library(RWeka)
library(ggplot2)
library(qdapRegex)
library(slam)
library(reshape2)


# Function to Clean the Input
inputCleaner <- function(input,profanity){
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
    #Remove Profanity
    cleanInput <- removeWords(cleanInput,profanity)
}

nextWord <- function(cleanInput,unigramDF,bigramDF,trigramDF){

    nWords <- stri_count_words(cleanInput)
    #user input word count is zero
    if(nWords == 0){
        #return first 5 highest frequency words
        return(unigramDF[1:5,2])
    }
    #user input word count is one
    if(nWords == 1){
        vlookup <- subset(bigramDF,Word1 == cleanInput)
        #if there is no match, return first 5 common words
        if(nrow(vlookup) == 0){return(unigramDF[1:5,2])}
        #return first 5 matched non-NA words
        if(nrow(vlookup) > 5){return(vlookup[1:5,4])}
        return(vlookup[1:nrow(vlookup),4])
    }
    #user input word count is two
    if(nWords == 2){
        input1 <- unlist(stri_split(cleanInput,regex = " "))[1]
        input2 <- unlist(stri_split(cleanInput,regex = " "))[2]
        vlookup <- subset(trigramDF,Word1 == input1 & Word2 == input2)
        #if there is no match, check out the last word in bigrams
        if(nrow(vlookup) == 0){
            vlookup <- subset(bigramDF,Word1 == input2)
            #if there is no match, return first 5 common words
            if(nrow(vlookup) == 0){return(unigramDF[1:5,2])}
            #otherwise return first 5 non-NA matched words
            if(nrow(vlookup) > 5){return(vlookup[1:5,4])}
            return(vlookup[1:nrow(vlookup),4])
        }
        #return first 5 matched non-NA words
        if(nrow(vlookup) > 5){return(vlookup[1:5,5])}
        return(vlookup[1:nrow(vlookup),5])
    }
    #user input word count is equal to or more than three
    if(nWords >= 3){
        #grab the last three words
        input1 <- tail(unlist(stri_split(cleanInput,regex = " ")),3)[1]
        input2 <- tail(unlist(stri_split(cleanInput,regex = " ")),3)[2]
        input3 <- tail(unlist(stri_split(cleanInput,regex = " ")),3)[3]
        vlookup <- subset(quadgramDF,Word1 == input1 & Word2 == input2 & Word3 == input3)
        #if there is no match, check out the last two words in trigrams
        if(nrow(vlookup) == 0){
            vlookup <- subset(trigramDF,Word1 == input2 & Word2 == input3)
            #if there is no match, check out the last word in bigrams
            if(nrow(vlookup) == 0){
                vlookup <- subset(bigramDF,Word1 == input2)
                #if there is no match, return first 5 common words
                if(nrow(vlookup) == 0){return(unigramDF[1:5,2])}
                #otherwise return first 5 non-NA matched words
                if(nrow(vlookup) > 5){return(vlookup[1:5,4])}
                return(vlookup[1:nrow(vlookup),4])
            }
            #return first 5 matched non-NA words
            if(nrow(vlookup) > 5){return(vlookup[1:5,5])}
            return(vlookup[1:nrow(vlookup),5])
        }
        #return first 5 matched non-NA words
        if(nrow(vlookup) > 5){return(vlookup[1:5,6])}
        return(vlookup[1:nrow(vlookup),6])
    }
}