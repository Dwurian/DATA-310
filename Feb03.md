# Feb 3 Informal Response

## Question 1
According to Maroney, traditional programming is writing the rules, feeding the data and then asking the machine to compile the answers, while machine learning 
is feeding the data and answers to the machine and the asking the machine to learn the rules. 

## Question 2
The first answer is `21.99785`, and the second answer is `21.99998`. They are different because machine learning accounts for the probability that the true relationship is 
nonlinear outside the given data range. 

## Question 3
When using the numbers of bedrooms to predict the price, the actual prices and predicted prices can be seen in the chart below: 

| |228 Church St|160 Holly Point Rd|760 New Point Comfort Hwy|6138 E River Rd|984 Finchetts Wharf Rd|4403 New Point Comfort Hwy|
|:-:|-:|-:|-:|-:|-:|-:|
|**Actual Price (thousand dollars)**|399.00|  97.00|347.50|289.00|250.00|229.00|
|**Predicted Price (thousand dollars)**|299.81076|234.55469|365.0668|299.81076|169.29863|234.55469|
|**Price Markup (thousand dollars)**|99.1892395|-137.5546875|-17.56680298|-10.8107605|80.70137024|-5.5546875|

Therefore, based on the model, 160 Holly Point Rd, 760 New Point Comfort Hwy, 6138 E River Rd, and 4403 New Point Comfort Hwy are good deals because their actual price is lower 
than the predicted price, and 228 Church St is the worst deal because its actual price has the highest markup from the predicted price.  
However, this model is very simple, taking into  account only the number of bedrooms of a house while ignoring other factors like size, facilities, neighborhood, etc. 

[Script for this excercise](20210203.py)
