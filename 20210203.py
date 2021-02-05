import tensorflow as tf
import numpy as np

from tensorflow import keras

model = keras.Sequential([keras.layers.Dense(units = 1, input_shape=[1])])
model.compile(optimizer = 'sgd', loss = 'mean_squared_error')

xs = np.array([-1.0, 0.0, 1.0, 2.0, 3.0, 4.0],dtype = float)
ys = np.array([-2.0, 1.0, 4.0, 7.0, 10.0, 13.0],dtype = float)

model.fit(xs, ys, epochs = 500)

first_ans = np.squeeze(model.predict([7.0]))

model.fit(xs, ys, epochs = 500)

second_ans = np.squeeze(model.predict([7.0]))

housing = keras.Sequential([keras.layers.Dense(units = 1, input_shape=[1])])
housing.compile(optimizer = 'sgd', loss = 'mean_squared_error')

bed = np.array([4.0, 3.0, 5.0, 4.0, 2.0, 3.0], dtype = float)
pricek = np.array([399.0, 97.0, 347.5, 289.0, 250.0, 229.0], dtype = float)

housing.fit(bed, pricek, epochs = 500)

pricepred = np.squeeze(housing.predict(bed))

print("1. First answer: " + str(first_ans) + ", Second answer: " + str(second_ans))

print("2. Predicted prices (according to numbers of bedrooms) for these houses are: \n" + str(pricepred) + "\n The difference between actual prices and predicted prices are:  \n" + str(pricek - pricepred))
