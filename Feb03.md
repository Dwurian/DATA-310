# Feb 3 Informal Response

1. According to Maroney, traditional programming is writing the rules, feeding the data and then asking the machine to compile the answers, while machine learning 
is feeding the data and answers to the machine and the asking the machine to learn the rules. 

2. The first answer is `21.99785`, and the second answer is `21.99998`. They are different because machine learning accounts for the probability that the true relationship is 
nonlinear outside the given data range. 

3. When using the numbers of bedrooms to predict the price, the resulting difference between actual prices and predicted prices are: `[99.1892395  -137.5546875   -17.56680298 
-10.8107605    80.70135498   -5.5546875]`. Therefore, based on the model, the second, third, fourth, and sixth houses are good deals because their actual price is lower than the 
predicted price, and the first house is the worst deal because its actual price has the highest markup from the predicted price.  
    However, this model is very simple, taking into  account only the number of bedrooms of a house while ignoring other factors like size, facilities, neighborhood, etc. 

    [Script for this excercise](20210203.py)
