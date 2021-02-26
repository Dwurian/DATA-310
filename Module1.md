# Module 1 Response

## Convolutions

1. Convolve the filters  
    ![Filter 1](Fil1.svg) and ![Filter 2](Fil2.svg)  
    on the matrix  
    ![Matrix](Matrix.svg).  
    The results are, respectively:  
    ![Result 1](Result_1.svg)  
    ```
    [[ 0, -2, -2,  5,  0, -1,  1],  
     [-1, -2, -2,  1,  0,  0, -2], 
     [ 0,  0, -1,  1,  3, -2,  0],
     [-2,  1, -1,  2,  5,  1,  1],
     [ 1,  2,  2,  5,  5,  1,  0],
     [-1,  1,  6,  5,  3, -2, -1],
     [ 2,  3,  6,  1,  0,  0, -1]]
    ```
    and  
    ![Result 2](Result_2.svg)  
    ```
    [[-1, -1,  1,  0, -3, -1,  0],
     [ 0, -2, -2,  2,  0, -2, -3],
     [ 1, -3,  2,  6,  0,  0,  1],
     [ 1, -1,  0, -1,  1,  2, -2],
     [ 2,  3,  1,  4,  1, -1, -1],
     [ 0,  5,  4,  2,  2,  2,  0],
     [ 3,  4,  1,  3,  2,  1, -3]]
    ```
    
2. The purpose of convolving a filter through an image matrix is to hightlight and/or extract certain features of an image for ease of understanding. 

3. We may want to include more than one filter to hightlight more features and gettinga better understanding of the image. In my handwritten number model, I did not include any filter, because the image from the dataset has been pre-processed. While it is possible that filters might have been applied during the pre-processing, there is no filter applied for my model. 

## MSE

For this exercise, I scraped 400 house listings in New Orleans from Zillow. To model the prices, I used the number of bedrooms, number of bathrooms, and square footage to predict the housing prices. For pre-processing, I used the Standard Scalar on all variables.

1. The MSE of the 10 biggest over-predictions is 518206361093.8301; while the MAE of the 10 biggest over-predictions is 717923.73125; 

2. The MSE of the 10 biggest under-predictions is 7758546415701.57; while the MAE of the 10 biggest under-predictions is 2602884.634375; 

3. The MSE of the 10 most accurate predictions is 162765594.69804686 ; the MAE of the 10 most accurate predictions is 11857.59375; 

4. The 10 most accurate predictions reside in the 31 percentile. This means that the model tends to over-predict. 

5. The weight of the model is `[0.00680757, -0.06489813, 0.300521]`, which means the square footage holds the most weight among the predictors, making it the most significant predictor. 

6. Comparing MSE and MAE, it is not hard to see that MAE is much smaller than MSE. This is because the in calculating MSE, the value of the errors has been squared.  

[Scraping script](zillow_scrape.py)

[Main script for the exercise](20200226.py)
