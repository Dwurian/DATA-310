# Project 2 Response - DHS Wealth Prediction

This is a report on Project 2. In this project, I use the DHS survey data on Jordan to predict individual's wealth level. 

The first model used is penalized logistic regression. The 30 penalty values is in a geometric sequence that starts with 0.0001 and ends with 0.1. The common ratio is therefore approximately 1.27. The AUC to penalty curve can be found below. Note that the x-axis is not in a linear scale, equidistant points on the x direction share the same ratio instead of difference. 

![lr_plot](lr_plot.png)

Across the penalty values, the top 15 that results in the largest areas under the ROC curve are: 

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

