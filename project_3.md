# Project 3 Response - Geo Raster

This is a report of Project 2. In this project, I used geospatial variables to model the population of the Irbid Governorate of Jordan. I chose this region because it is the most densely populated governorate of the country. 

[irbid](irbid.png)
Simplified map of the Irbid Governorate

[irbid_loc](irbid_loc.png)
Location of the Irbid Governorate in Jordan

[pop](pop.png)
Population of the Irbid Governorate

I first used the linear regression model for my prediction. The resulted prediction is as follows: 

[pop_lr](pop_lr.png)

Then the difference between the prediction and the actual population can be seen below: 

[diff_lr](diff_lr.png)

Then the plot of the mean error, mean absolute error, and root mean squared error are as follows: 

[me_lr](me_lr.png)
Mean error

[mae_lr](mae_lr.png)
Mean absolute error

[rmse_lr](rmse_lr.png)
Root mean squared error

Then I used the random forest model. For some reason, the resulted prediction is uniform in all areas: 

[pop_rf](pop_rf.png)

Therefore the difference between the prediction and the actual population can be seen below: 

[diff_rf](diff_rf.png)

The plot of the mean error, mean absolute error, and root mean squared error are as follows: 

[me_rf](me_rf.png)
Mean error

[mae_rf](mae_rf.png)
Mean absolute error

[rmse_lr](rmse_lr.png)
Root mean suqared error

Judging from the results above, linear regression model is the more accurate model, since the results of random forest show no variation. 

The spatial variation throughout the selected area may be attributed to the existence of metropolitan areas. The area with the largest difference and variance in the linear regression model is where the city of Irbid is located, the largest city of the region and the second largest metropolitan area in Jordan. Although some characteristics of urban areas can be reflected by night time light, this variable is not the best indicator of urban areas, since the density of urban residential areas might result in a small difference of night time light from the rural areas. 
