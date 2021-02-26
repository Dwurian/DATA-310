import tensorflow as tf
import numpy as np
import pandas as pd
from tensorflow import keras

from sklearn.preprocessing import StandardScaler

df = pd.read_csv('out.csv')

ss = StandardScaler()

housing = keras.Sequential([keras.layers.Dense(units = 1, input_shape=[3])])
housing.compile(optimizer = 'sgd', loss = 'mean_squared_error')

x1 = np.array(df['no_beds'])
x2 = np.array(df['baths'])
x3 = np.array(df['sqft'])

xs = np.stack([x1, x2, x3], axis=1)
ys = np.array(df['prices']).reshape(-1,1)

xss = ss.fit_transform(xs)
yss = ss.fit_transform(ys)

housing.fit(xss, yss, epochs = 1000)

pprice = np.squeeze(housing.predict(xss))

x = np.array(df['prices'])
y = ss.inverse_transform(pprice)
diff = y - x

MSE = np.dot(diff, np.transpose(diff))/len(diff)
MAE = np.sum(np.absolute(diff))/len(diff)

diff.sort()
ten_over = diff[-10:]
ten_under = diff[:10]

MSE_over = np.dot(ten_over, np.transpose(ten_over))/10
MAE_over = np.sum(np.absolute(ten_over))/10
MSE_under = np.dot(ten_under, np.transpose(ten_under))/10
MAE_under = np.sum(np.absolute(ten_under))/10

diff_abs = np.copy(diff)
diff_abs = np.absolute(diff_abs)
diff_abs.sort()

ten_acc = diff_abs[:10]
MSE_acc = np.dot(ten_acc, np.transpose(ten_acc))/10
MAE_acc = np.sum(ten_acc)/10

print ("The Mean Squared Error of the entire model is:", MSE,
       "; the Mean Absolute Error of the entire model is:", MAE)
print ("The Mean Squared Error of the 10 biggest over-predictions is:", MSE_over,
       "; the Mean Absolute Error of the 10 biggest over-predictions is:", MAE_over)
print ("The Mean Squared Error of the 10 biggest under-predictions is:", MSE_under,
       "; the Mean Absolute Error of the 10 biggest under-predictions is:", MAE_under)
print ("The Mean Squared Error of the 10 most accurate predictions is:", MSE_acc,
       "; the Mean Absolute Error of the 10 most accurate predictions is:", MAE_acc)

most_accurate_index = 0
for i in range(0,len(diff)):
    if diff[i] * diff[i+1] < 0:
        if diff[i]+diff[i+1] > 0:
            most_accurate_index = i
        else:
            most_accurate_index = i+1
        break

percentile = round(most_accurate_index/len(diff) * 100)
print("The 10 most accurate predictions reside in the", percentile, "percentile. ")

print("The weights of the predictors are:", str(housing.weights))