#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Word Prediction"),
  
  # Sidebar with a text input 
  sidebarLayout(
    sidebarPanel(
       textInput("text", "Enter text here:", value = ""),
       helpText("Once you start filling this out, next word will be predicted with up to 5 alternatives."),
       helpText("It could take about 20 seconds for the initial load, please wait.")
    ),
    
    # Show the predictions
    mainPanel(
        
        verbatimTextOutput("result")
    )
  )
))
