# WordPredict
Coursera Capstone Project

This is an application that gets user input and then predicts the next word the user may input. Up to five possible word predictions are provided.  

This application was developed for the Coursera Data Science Specialization - Data Science Capstone class.

The data that was used for this project was taken from https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip. 
Only the English language files were used for the purpose of this application.  

The data was sampled at 1/20 ratio to make the calculations faster and the initial load in a reasonable time.  
Afterwards, data was cleaned to increase the accuracy of the prediction. All words were transformed to lowercase; punctuation, numbers, emoticons and extra spaces were removed. Finally profanities were also removed.  

After the data was cleaned, it was all put into a corpus object and then tokenized into N-Grams. Simply put, occurances of words alone, word pairs, word triplets and word quartets in our source data were grouped together and sorted according to how often they appeared.  

This way when a user inputs some words, we could check the last three words and match them with first three words of word quartets. Based on occurance frequency, we could then return the most commonly occuring words as the upcoming fourth word.  

If the given input did not match anything in the word quartets, then we back-off and try to find observations of last two words in word triplets; last word in word pairs; and if that does not work, then we give the 5 most commonly used single words as predictions.  

Link to the presentation: http://rpubs.com/finishim/WordPredict  
Link to the application: https://finishim.shinyapps.io/WordPredict/  
