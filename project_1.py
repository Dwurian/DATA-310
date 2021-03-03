import tensorflow as tf
import numpy as np
import pandas as pd
from tensorflow import keras
import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler

df = pd.read_csv('out.csv')

ss = StandardScaler()

def model_validation(diff):
    de = np.array(df['prices']) - np.mean(np.array(df['prices']))
    TSS = np.dot(de, np.transpose(de))
    RSS = np.dot(diff, np.transpose(diff))
    MSE = RSS/len(diff)
    MAE = np.sum(np.absolute(diff))/len(diff)
    R_squared = 1- RSS/TSS
    return MSE,MAE,R_squared

# simple model

data = np.array(df.iloc[:,[0,2,3,4]])

data =ss.fit_transform(data)

xs = data[:,[1,2,3]]
ys = data[:,0]

housing = keras.Sequential([keras.layers.Input(shape=[3]),
                            keras.layers.Dense(3),
                            keras.layers.Dense(1)])
housing.compile(optimizer = 'sgd', loss = 'mean_squared_error')

simple = housing.fit(xs, ys, epochs = 1000)

pprice = np.squeeze(housing.predict(xs))

pred = np.stack([pprice, data[:,1], data[:,2], data[:,3]], axis = 1)

pred = ss.inverse_transform(pred)

df[['pprice']] = pred[:,0]

x = np.array(df['prices'])
y = np.array(df['pprice'])
e_simple = y-x
MSE,MAE,R_squared = model_validation(e_simple)

# zipcode-linear model

data_zip_linear = np.array(df.iloc[:,[0,1,2,3,4]])

data_zip_linear =ss.fit_transform(data_zip_linear)

xs_zip_linear = data_zip_linear[:,[1,2,3,4]]
ys_zip_linear = data_zip_linear[:,0]

housing_zip_linear = keras.Sequential([keras.layers.Input(shape=[4]),
                            keras.layers.Dense(4),
                            keras.layers.Dense(1)])
housing_zip_linear.compile(optimizer = 'sgd', loss = 'mean_squared_error')

zip_linear = housing_zip_linear.fit(xs_zip_linear, ys_zip_linear, epochs = 1000)

pprice_zip_linear = np.squeeze(housing_zip_linear.predict(xs_zip_linear))

pred_zip_linear = np.stack([pprice_zip_linear,
                            data_zip_linear[:,1],
                            data_zip_linear[:,2],
                            data_zip_linear[:,3],
                            data_zip_linear[:,4]],
                           axis = 1)

pred_zip_linear = ss.inverse_transform(pred_zip_linear)

df[['pprice_zip_linear']] = pred_zip_linear[:,0]

x = np.array(df['prices'])
y = np.array(df['pprice_zip_linear'])
e_zip_linear = y-x
MSE_zip_linear,MAE_zip_linear,R_squared_zip_linear = model_validation(e_zip_linear)

# embedded model

df[['code']] = 0
zip_list = np.unique(df['zip'])

for i in range(len(df)):
    for j in range(len(zip_list)):
        if df.loc[i, 'zip'] == zip_list[j]:
            df.loc[i, 'code'] = j

data_zip_embed = np.array(df.iloc[:,[0,2,3,4]])

data_zip_embed =ss.fit_transform(data_zip_embed)

xs_numeric = data_zip_embed[:,[1,2,3]]
ys = data_zip_embed[:,0]

cat= np.array(df['code'])

numeric_inputs = tf.keras.layers.Input((3,), name='numeric_inputs')
cat_inputs = tf.keras.layers.Input((1,), name='cat_inputs')

embedding_layer = tf.keras.layers.Embedding(input_dim = 17, output_dim = 10,
                                            input_length=1)
cats = embedding_layer(cat_inputs)
cats = tf.keras.layers.Flatten()(cats)

x = tf.keras.layers.Concatenate()([cats, numeric_inputs])
x = tf.keras.layers.Dense(13, activation='relu')(x)
out = tf.keras.layers.Dense(1, name='output')(x)

housing_zip_embed = tf.keras.models.Model(inputs=[numeric_inputs, cat_inputs], outputs=out)
housing_zip_embed.compile(optimizer = 'sgd', loss = 'mean_squared_error')

zip_embed = housing_zip_embed.fit([xs_numeric, cat], ys, epochs = 1000)

pprice_zip_embed = np.squeeze(housing_zip_embed.predict([xs_numeric, cat]))

pred_zip_embed = np.stack([pprice_zip_embed,
                           data_zip_embed[:,1],
                           data_zip_embed[:,2],
                           data_zip_embed[:,3]],
                          axis = 1)

pred_zip_embed = ss.inverse_transform(pred_zip_embed)

df[['pprice_zip_embed']] = pred_zip_embed[:,0]

x = np.array(df['prices'])
y = np.array(df['pprice_zip_embed'])
e_zip_embed = y-x
MSE_zip_embed,MAE_zip_embed,R_squared_zip_embed = model_validation(e_zip_embed)

# plot model loss
plt.plot(simple.history['loss'], color = 'tab:orange')
plt.title('Model Loss for Non Locational Model')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.savefig('simple_model_loss.png')
plt.show()

# plot error histogram
plt.hist(e_simple, bins = 60, histtype = 'step',
            color = 'tab:orange')
plt.title('Error Histogram for Non Locational Model')
plt.savefig('simple_error_hist.png')
plt.show()

# plot model loss comparison
plt.ylim(0, 3.0)
plt.plot(simple.history['loss'], color = 'tab:orange')
plt.plot(zip_linear.history['loss'], color = 'tab:blue')
plt.plot(zip_embed.history['loss'], color = 'tab:green')
plt.title('Model Loss Comparisons')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['Non Locational', 'Zipcode_Linear', 'Embedded'], loc='upper right')
plt.savefig('model_loss.png')
plt.show()


# plot MSE and MAE
valuation = [[MSE, MAE],
             [MSE_zip_linear, MAE_zip_linear],
             [MSE_zip_embed, MAE_zip_embed]]

val = pd.DataFrame(valuation, index=['Non Locational Model', 'Zipcode-Linear Model', 'Embedded Model'],
                   columns = ['MSE', 'MAE'])
fig = val.plot( kind= 'bar', secondary_y= 'MAE', rot= 0)
plt.title('MSE and MAE of Different Models')
plt.savefig('mse_mae.png')
plt.show()

# plot R-squared
R2 = [R_squared, R_squared_zip_linear, R_squared_zip_embed]
models = ['Non Locational', 'Zipcode-Linear', 'Embedded']
plt.plot(models, R2)
plt.title('R-squared of Different Models')
plt.savefig('R_squared_comparison.png')
plt.show()

# plot error histogram comparisons
e = np.concatenate((e_simple, e_zip_linear, e_zip_embed))
min_e = min(e)
max_e = max(e)
width = min(abs(min_e),max_e)
bins = range(int(-width), int(width), int(width/30))
fig, axs = plt.subplots(3, sharey=True)
fig.suptitle('Histogram of Errors Across Models')
axs[0].hist(e_simple, bins = bins, histtype = 'step',
            color = 'tab:orange', label = 'Non Locational')
axs[1].hist(e_zip_linear, bins = bins, histtype = 'step',
            color = 'tab:blue', label = 'Zipcode-Linear')
axs[2].hist(e_zip_embed, bins = bins, histtype = 'step',
            color = 'tab:green', label = 'Embedded')
fig.legend(loc='upper left')
plt.savefig('error_hist.png')
plt.show()

# scatter asking price vs predictions.
plt.scatter(df['prices'], df['pprice'], color = 'tab:orange')
plt.xlim([0, 1700000])
plt.ylim([0, 2000000])
plt.axline([0, 0], [1, 1])
plt.xlabel('asking price')
plt.ylabel('predictions')
plt.title('Asking Price vs Predictions from Non Locational Model')
plt.savefig('simple.png')
plt.show()

plt.scatter(df['prices'], df[['pprice_zip_linear']], color = 'tab:blue')
plt.xlim([0, 1700000])
plt.ylim([0, 2000000])
plt.axline([0, 0], [1, 1])
plt.xlabel('asking price')
plt.ylabel('predictions')
plt.title('Asking Price vs Predictions from Zipcode-Linear Model')
plt.savefig('zip-linear.png')
plt.show()

plt.scatter(df['prices'], df[['pprice_zip_embed']], color = 'tab:green')
plt.xlim([0, 1700000])
plt.ylim([0, 2000000])
plt.axline([0, 0], [1, 1])
plt.xlabel('asking price')
plt.ylabel('predictions')
plt.title('Asking Price vs Predictions from Embedded Model')
plt.savefig('embedded.png')
plt.show()


val[['R-squared']] = R2
print(val)