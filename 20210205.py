import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
from tensorflow import keras

mnist = tf.keras.datasets.mnist

(training_images, training_labels), (test_images, test_labels) = mnist.load_data()

training_images  = training_images / 255.0
test_images = test_images / 255.0

numdraw = tf.keras.models.Sequential([tf.keras.layers.Flatten(input_shape=(28,28)),
                                    tf.keras.layers.Dense(128, activation=tf.nn.relu),
                                    tf.keras.layers.Dense(10, activation=tf.nn.softmax)])

numdraw.compile(optimizer = tf.keras.optimizers.Adam(),
              loss = 'sparse_categorical_crossentropy',
              metrics=['accuracy'])

numdraw.fit(training_images, training_labels, epochs=5)

classification = numdraw.predict(test_images)

labels = [0,1,2,3,4,5,6,7,8,9]

colors = np.full(10, 'tab:gray')

height = classification[42] + 0.1

colors[np.argmax(classification[42])]= 'c'

plt.bar(labels, height, bottom=-0.1, color = colors)

plt.savefig("histogram.png")

plt.show()

plt.close()

plt.imshow(test_images[42])

plt.savefig("test_image.png")

plt.close()

print("1. There are " + str(len(training_images)) + " images, and their dimensions are "
      + str(np.shape(training_images[0])))

print("2. The length of the labels training set is " + str(len(training_labels)))

print("3. There are " + str(len(test_images)) + " images, and their dimensions are "
      + str(np.shape(test_images[0])))

print("5. The test image with the index 42 is categorized as " + str(np.argmax(classification[42])))
