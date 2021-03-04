# Gesture recognition with EMG sensors

Gesture recognition with MYO armband and various machine learning techniques. Model predictions used for controlling virtual helicopter in real-time in a unity3D environment.

![EMGProject_image](https://github.com/koszoru-kristof/EMG---Myo-gesture-recognition/blob/f435db0a4ae26560d868a9042739bcb112ec8c69/EMGProject_image.jpg)


## About the project

An Electromyography sensor array (Myo Armband) has been used for data collection, carefully placed to the user's forearm. The electrical activity of muscle movements are sent to a feed-forward neural network for classification purposes. The network predictions are sent to a Unity application with a server-client protocol. Therefore, it is possible to control the movements of a virtual object (e.g., a helicopter) with the predefined gestures.

The gesture recognition is based on a Machine Learning Classifier using LSTM cells developed in MATLAB utilizing the 8 EMG sensors of the Myo bracelet. After the data collection and the model training, the software can recognize 6 predefined actions and send them to the Unity game module via ZMQ to control the Helicopter position and motion.

Detailed description: [Project report](https://github.com/koszoru-kristof/EMG---Myo-gesture-recognition/blob/f435db0a4ae26560d868a9042739bcb112ec8c69/EmgProject_report.pdf).


## Project structure

- Base-Helicopter-controller: folder with the unity application. It has been created by modifying an already existing project.

- EMG_Main: main folder where the most important script is saved. The same data already acquired is here saved. The main scripts are:
    - __1_MYOAquisition__ which permits to acquire data from Myo sensor;
    - __2_LSTM_TRAINING__ which execute the Neural Network training;
    - __3_RealTimeMyo__ which is used for executing programs in real-time;
    - __4_Simulation__ which is used for executing a simulation using already acquired data;

- ZMQ: folder containing the ZMQ protocol used for server-client communication. It has to be executed both from MATLAB and Unity.

## Authors

<a href="https://github.com/koszoru-kristof/Myo_EMG-GestureRecognition/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=koszoru-kristof/Myo_EMG-GestureRecognition" />
</a>

* [Alessandro De Martini](https://github.com/AlessandroDeMartini)
* [Dal Mas Massimiliano](https://github.com/max-codeware)
* [Kristóf Koszoru](https://github.com/koszoru-kristof)

