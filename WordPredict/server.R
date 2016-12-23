# Load Libraries
library(rJava)
library(stringi)
library(NLP)
library(tm)
library(RWeka)
library(ggplot2)
library(qdapRegex)
library(slam)
library(reshape2)
library(shiny)

# Load already created ngram data frames 
unigramDF <- readRDS(file="./unigramDF.RData")
bigramDF <- readRDS(file="./bigramDF.RData")
trigramDF <- readRDS(file="./trigramDF.RData")

# Load the functions
source(file="./Prepare.R")

# Load the Profanity Filter file
profanity <- readLines(con <- file("./profanity.txt", "r"))
close(con)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    wordPredict <- reactive({
        # Get the input
        textIn <- input$text
        
        # Clean the input
        cleanInput <- inputCleaner(textIn,profanity)
        
        # Predict the next word
        prediction <- nextWord(cleanInput,unigramDF,bigramDF,trigramDF)
    })
    
    output$result <- renderText({
        wordPredict()

    })
  
})