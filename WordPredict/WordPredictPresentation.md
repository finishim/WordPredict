Word Prediction Application - Coursera Data Science Specialization  
Word Prediction Application - Capstone Project
========================================================
author: Nazmi Anik
date: 12/23/2016
autosize: false

<p style="font-size:30px">Purpose of this presentation is to give an overview of the application to predict next word in text input and offer future enhancements.</p>

<p style="font-size:30px">This application was developed for the Coursera Data Science Specialization - Data Science Capstone class.</p>

Data Sources
========================================================

The data that was used for this project was taken from [this link]("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"). Only the English language files were used for the purpose of this application.

Below are the word and line counts of the files used for learning word relationships.

The counts are displayed in the table below:  

| Counts | Blogs | News | Twitter |
|:-----:|:----:|:-------:|:------:|
|   lines  |  899288  |    77259   |    2360148  |
|  words  |  37546246 |   2674536   |   30093369  |

Cleaning the Data
========================================================

The data was sampled at 1/20 ratio to make the calculations faster and the initial load in a reasonable time. It takes about 20 seconds to load the whole data. But then the calculations are relatively faster afterwards.

After the sampling, data was cleaned to increase the accuracy of the prediction. All words were transformed to lowercase. The punctuation, numbers, emoticons and extra spaces were removed. For the emoticons, a library called *qdapRegex* was used. Finally profanities were also removed that were grabbed from [this link](https://gist.github.com/ryanlewis/a37739d710ccdb4b406d).

Prediction Algorithm
========================================================

<p style="font-size:25px">After the data is cleaned, it is all put into a corpus object and then tokenized into N-Grams. Simply put, occurances of words alone, word pairs, word triplets and word quartets in our source data were grouped together and sorted according to how often they appeared.</p>

<p style="font-size:25px">This way when a user inputs some words, the last three words are checked and matched with first three words of word quartets. Based on occurance frequency, the most commonly occuring words as the upcoming fourth word is returned.</p>

<p style="font-size:25px">If the given input is not match anything in the word quartets, then we back-off and try to find observations of last two words in word triplets, then in word pairs, and finally the 5 most commonly used single words as predictions.</p>

<p style="font-size:25px">Future Enhancements:</p>
- <p style="font-size:25px">To improve accuracy, big amount of data was input during the initial load, increasing load time. This could be circumvented in a future release. Instead of using blogs, tweets and news combined, one kind of input could be used based on where the application will be used.</p>
- <p style="font-size:25px"> A loading message warning the user while the data load is going on could be helpful to make sure the user sticks around.</p>

Application and Source Code
========================================================

Here is how the application looks:

![Application Screenshot](app.png)

The link to the application is [here](https://finishim.shinyapps.io/WordPredict/).

The link to the source code is [here](https://github.com/finishim/WordPredict).
