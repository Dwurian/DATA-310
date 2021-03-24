# Project 2 Response - DHS Wealth Prediction

This is a report on Project 2. In this project, I use the DHS survey data on Jordan to predict individual's wealth level. 

## Penalized Logistic Regression

The first model used is penalized logistic regression. The 30 penalty values is in a geometric sequence that starts with 0.0001 and ends with 0.1. The common ratio is therefore approximately 1.27. Across the penalty values, the top 15 that results in the largest areas under the ROC curve are: 

```
penalty .metric .estimator  mean     n std_err .config              
      <dbl> <chr>   <chr>      <dbl> <int>   <dbl> <chr>                
 1 0.0001   roc_auc hand_till  0.621     1      NA Preprocessor1_Model01
 2 0.000127 roc_auc hand_till  0.621     1      NA Preprocessor1_Model02
 3 0.000161 roc_auc hand_till  0.621     1      NA Preprocessor1_Model03
 4 0.000204 roc_auc hand_till  0.620     1      NA Preprocessor1_Model04
 5 0.000259 roc_auc hand_till  0.620     1      NA Preprocessor1_Model05
 6 0.000329 roc_auc hand_till  0.620     1      NA Preprocessor1_Model06
 7 0.000418 roc_auc hand_till  0.620     1      NA Preprocessor1_Model07
 8 0.000530 roc_auc hand_till  0.619     1      NA Preprocessor1_Model08
 9 0.000672 roc_auc hand_till  0.618     1      NA Preprocessor1_Model09
10 0.000853 roc_auc hand_till  0.618     1      NA Preprocessor1_Model10
11 0.00108  roc_auc hand_till  0.617     1      NA Preprocessor1_Model11
12 0.00137  roc_auc hand_till  0.615     1      NA Preprocessor1_Model12
13 0.00174  roc_auc hand_till  0.614     1      NA Preprocessor1_Model13
14 0.00221  roc_auc hand_till  0.612     1      NA Preprocessor1_Model14
15 0.00281  roc_auc hand_till  0.609     1      NA Preprocessor1_Model15 
```
Here we can see that the models with penalty values 0.0001, 0.000127, and 0.000161 has the largest AUC, being 0.621. 

The AUC to penalty curve can be found below. Note that the x-axis is not in a linear scale, equidistant points on the x direction share the same ratio in penalty values instead of difference. 

![lr_plot](lr_plot.png)

It appears that the AUC gradually decreased from the first model (penalty value = 0.001) to the 21st model (penalty value = 0.0117210), and stayed steady towards the 24th model (penalty value = 0.0239503), after which the AUC dropped significantly, then stayed steady again from the 27th model (penalty value = 0.0489390) to the 29th model (penalty value = 0.0788046). From this, I think the irrelevant predictors are gradually removed from the model throughout the first to 21st model (penalty value from 0.001 to 0.0117210), after which relevant predictors were removed from the model, resulting in significant drops in the AUC. 

I choose the penalty value of 0.000853168 (the 10th model) because it is represented by the last point in the plot that belongs to the initial gradual descent in AUC. 

The ROC plot of the model is as follows: 

![lr_auc](lr_auc.png)

Here we can see that the model handles the wealth level 5 best, and predicts wealth levels 1 and 4 with good results, but is not as effective at predicting wealth levels 2 and 3. 

## Random Forest

The second model used is random forest.The random forest models all contain 1000 trees, between 1 and 4 predictors are randomly selected, and the minimal node size vary from 1 to 40. Below are the AUC values with their corresponding number of randomly selected predictors and minimal node size. 

![rf_res](rf_res.png)

We can then trace the general outline of AUC against minimal node sizes with different number of randomly selected predictors: 

![rf_res_trace](rf_res_trace.png)

Here we can see that generally speaking, models with 2 randomly selected predictors seem to work best, followed by models with 1 randomly selected predictor, then 3 and 4. Models with any number of predictors seem to increase in effectiveness as minimal node size gets close to 40, with the exception of models with 1 randomly selected predictor showing a slight downward trend. The top model is: 

``` 
   mtry min_n .config              
  <int> <int> <chr>                
1     2    37 Preprocessor1_Model12
``` 

![rf_auc](rf_auc.png)

The prediction outcomes appear to exhibit the same behavior as the penalized logistic regression model, having good performance in wealth levels 1, 4 and 5 but limited performance in wealth level 2 and 3.

