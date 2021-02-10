import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
import random
from tensorflow import keras

mnist = tf.keras.datasets.mnist

(training_images, training_labels), (test_images, test_labels) = mnist.load_data()

training_images = training_images / 255.0
test_images = test_images / 255.0

numdraw = tf.keras.models.Sequential([tf.keras.layers.Flatten(input_shape=(28, 28)),
                                      tf.keras.layers.Dense(512, activation=tf.nn.relu),
                                      tf.keras.layers.Dense(256, activation=tf.nn.relu),
                                      tf.keras.layers.Dense(128, activation=tf.nn.relu),
                                      tf.keras.layers.Dense(64, activation=tf.nn.relu),
                                      tf.keras.layers.Dense(10, activation=tf.nn.softmax)])

numdraw.compile(optimizer=tf.keras.optimizers.Adam(),
                loss='sparse_categorical_crossentropy',
                metrics=['accuracy'])

numdraw.fit(training_images, training_labels, epochs=10)

test_loss, test_acc = numdraw.evaluate(test_images, test_labels, verbose=2)
print('Test accuracy: ', test_acc)

probability_model = keras.Sequential([numdraw, keras.layers.Softmax()])

classification = probability_model.predict(test_images)


random.seed(42)

num = random.randint(0, len(test_images))

print(classification[num])
print(test_labels[num])

class_names = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

def plot_image(i, predictions_array, true_label, img):
  predictions_array, true_label, img = predictions_array, true_label[i], img[i]
  plt.grid(False)
  plt.xticks([])
  plt.yticks([])
  plt.imshow(img, cmap=plt.cm.binary)
  predicted_label = np.argmax(predictions_array)
  if predicted_label == true_label:
    color = 'blue'
  else:
    color = 'red'
  plt.xlabel("{} {:2.0f}% ({})".format(class_names[predicted_label],
                                100*np.max(predictions_array),
                                class_names[true_label]),
                                color=color)

def plot_value_array(i, predictions_array, true_label):
  predictions_array, true_label = predictions_array, true_label[i]
  plt.grid(False)
  plt.xticks(range(10))
  plt.yticks([])
  thisplot = plt.bar(range(10), predictions_array, color="#777777")
  plt.ylim([0, 1])
  predicted_label = np.argmax(predictions_array)
  thisplot[predicted_label].set_color('red')
  thisplot[true_label].set_color('blue')

img = test_images[num]

img = (np.expand_dims(img,0))

predictions_single = probability_model.predict(img)

num_pred = np.argmax(predictions_single[0])

print("1. There are " + str(len(training_images)) + " images, and their dimensions are "
      + str(np.shape(training_images[0])))

print("2. The length of the labels training set is " + str(len(training_labels)))

print("3. There are " + str(len(test_images)) + " images, and their dimensions are "
      + str(np.shape(test_images[0])))

print("5. The test image with the index " + str(num) + " is categorized as " + str(num_pred))

i = num
plt.figure(figsize=(6,3))
plt.subplot(1,2,1)
plot_image(i, classification[i], test_labels, test_images)
plt.subplot(1,2,2)
plot_value_array(i, classification[i],  test_labels)
plt.savefig('fig.png')
plt.show()
