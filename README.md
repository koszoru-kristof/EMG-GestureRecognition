# Gesture recognition with EMG sensors

This repository contains the project developed by Alessandro De Martini, Dal Mas Massimiliano, and Kristóf Koszoru during the academic year 2019/2020. 

## About the project


![EMGProject_image](https://github.com/koszoru-kristof/EMG---Myo-gesture-recognition/blob/f435db0a4ae26560d868a9042739bcb112ec8c69/EMGProject_image.jpg)

The project described in this repository is related to a deep learning application used for serious game applications. An Electromyography sensor (Myo) has been used as a monitor system on the user's arm. The electromagnetic signals of muscle movements are sent to a neural network. The latter is connected with a server-client protocol to a Unity application. Therefore, it is possible to control the movements of a virtual object (e.g., a helicopter) with the gesture of the hand.

The gesture recognition is based on a Machine Learning Classifier developed in MATLAB using the 8 EMG sensors of the MYO bracelet. After the data collection and the model training, the software can recognize 6 predefined actions and send them to the Unity game module via ZMQ to control the Helicopter position and motion.

Project report: [pdf](https://github.com/koszoru-kristof/EMG---Myo-gesture-recognition/blob/f435db0a4ae26560d868a9042739bcb112ec8c69/EmgProject_report.pdf).



## Repository content

- Base-Helicopter-controller: folder with the unity application. It has been created by modifying an already existing project.

- EMG_Main: main folder where the most important script is saved. The same data already acquired is here saved. The main scripts are:
    - __1_MYOAquisition__ which permits to acquire data from Myo sensor;
    - __2_LSTM_TRAINING__ which execute the Neural Network training;
    - __3_RealTimeMyo__ which is used for executing programs in real-time;
    - __4_Simulation__ which is used for executing a simulation using already acquired data;

- ZMQ: folder containing the zmq protocol used for server-client communication. It has to be executed both from MATLAB and Unity.

## Authors

<a href="https://github.com/koszoru-kristof/Myo_EMG-GestureRecognition/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=koszoru-kristof/Myo_EMG-GestureRecognition" />
</a>

Made with [contributors-img](https://contrib.rocks).
