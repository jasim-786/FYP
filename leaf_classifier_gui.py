import tkinter as tk
from tkinter import filedialog
from tkinter import messagebox
from PIL import Image, ImageTk  # For displaying images in the GUI
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import img_to_array, load_img
from tensorflow.keras.models import Model
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Conv2D, MaxPooling2D, DepthwiseConv2D, BatchNormalization, LeakyReLU, Concatenate, Input

# Model architecture (reuse your hybrid model definition)
def inceptionv3_base(input_shape=(224, 224, 3)):
    inputs = Input(shape=input_shape)

    x = Conv2D(32, (3, 3), strides=(2, 2), padding='valid', activation=None)(inputs)
    x = LeakyReLU(alpha=0.1)(x)
    x = Conv2D(32, (3, 3), padding='valid', activation=None)(x)
    x = LeakyReLU(alpha=0.1)(x)
    x = Conv2D(64, (3, 3), padding='same', activation=None)(x)
    x = LeakyReLU(alpha=0.1)(x)
    x = MaxPooling2D(pool_size=(3, 3), strides=(2, 2), padding='valid')(x)

    x = Conv2D(80, (1, 1), padding='valid', activation=None)(x)
    x = LeakyReLU(alpha=0.1)(x)
    x = Conv2D(192, (3, 3), padding='valid', activation=None)(x)
    x = LeakyReLU(alpha=0.1)(x)
    x = MaxPooling2D(pool_size=(3, 3), strides=(2, 2), padding='valid')(x)

    x = GlobalAveragePooling2D()(x)
    return Model(inputs, x)

def custom_cnn_base(input_shape=(224, 224, 3)):
    inputs = Input(shape=input_shape)

    x = Conv2D(32, (3, 3), strides=(2, 2), padding='same')(inputs)
    x = BatchNormalization()(x)
    x = LeakyReLU(alpha=0.1)(x)

    x = DepthwiseConv2D((3, 3), padding='same')(x)
    x = BatchNormalization()(x)
    x = LeakyReLU(alpha=0.1)(x)
    x = Conv2D(64, (1, 1), padding='same')(x)
    x = BatchNormalization()(x)
    x = LeakyReLU(alpha=0.1)(x)

    x = DepthwiseConv2D((3, 3), strides=(2, 2), padding='same')(x)
    x = BatchNormalization()(x)
    x = LeakyReLU(alpha=0.1)(x)
    x = Conv2D(128, (1, 1), padding='same')(x)
    x = BatchNormalization()(x)
    x = LeakyReLU(alpha=0.1)(x)

    x = GlobalAveragePooling2D()(x)
    return Model(inputs, x)

inception_base = inceptionv3_base(input_shape=(224, 224, 3))
custom_cnn_base = custom_cnn_base(input_shape=(224, 224, 3))

inputs = Input(shape=(224, 224, 3))
inception_features = inception_base(inputs)
custom_cnn_features = custom_cnn_base(inputs)

x = Concatenate()([inception_features, custom_cnn_features])
x = Dense(1024, activation='relu')(x)
outputs = Dense(10, activation='softmax')(x)

hybrid_model = Model(inputs, outputs)

# Load the saved weights
weights_path = "F:\Githubfyp\model_weights.weights.h5"  # Replace with the correct weights path
hybrid_model.load_weights(weights_path)
print("Model weights loaded successfully!")

# Class names
class_names = ['Brown_Rust', 'Healthy', 'Yellow_Rust', 'Class4', 'Class5', 'Class6', 'Class7', 'Class8', 'Class9', 'Class10']

# Function to preprocess and predict the image
def predict_image(image_path, model, class_names):
    image = load_img(image_path, target_size=(224, 224))
    image_array = img_to_array(image) / 255.0
    image_array = np.expand_dims(image_array, axis=0)

    predictions = model.predict(image_array)
    predicted_class_idx = np.argmax(predictions)
    predicted_class = class_names[predicted_class_idx]
    return predicted_class, predictions[0]

# GUI Setup
def upload_and_predict():
    file_path = filedialog.askopenfilename(filetypes=[("Image files", "*.jpg;*.jpeg;*.png")])
    if not file_path:
        return

    try:
        predicted_class, probabilities = predict_image(file_path, hybrid_model, class_names)

        # Display the image and prediction
        img = Image.open(file_path).resize((224, 224))
        img = ImageTk.PhotoImage(img)
        panel.configure(image=img)
        panel.image = img

        result_label.config(text=f"Predicted Class: {predicted_class}")
    except Exception as e:
        messagebox.showerror("Error", f"An error occurred: {str(e)}")

# Create the main application window
root = tk.Tk()
root.title("Leaf Disease Classifier")

# Add a button to upload and predict
upload_button = tk.Button(root, text="Upload Image", command=upload_and_predict)
upload_button.pack(pady=10)

# Add a panel to display the image
panel = tk.Label(root)
panel.pack()

# Add a label to display the result
result_label = tk.Label(root, text="Prediction will appear here.", font=("Helvetica", 16))
result_label.pack(pady=10)

# Run the GUI loop
root.mainloop()
