# Electromagnetic sensor used in gesture recognition

This repository contains the project developed by Alessandro De Martini, Dal Mas Massimiliano, and Kristóf Kozoru. 

## Short description

The project described in this repository is related to a deep learning application used for serious game applications. An electromagnetic sensor (Myo) has been used as a monitor system on the user's arm. The electromagnetic signals of muscle movements are sendt to a neural network. The latter is connected with a server-client protocol to a Unity application. Therefore, it is possible to control the movements of a virtual object (e.g., a helicopter) with the gesture of the end.

The gesture recognition is based on a Machine Learning Classifier developed in MATLAB using the 8 EMG sensors of the MYO bracelet. After the data collection and the model training, the software can recognize 6 predefined actions and send them to the Unity game module via ZMQ to control the Helicopter position and motion.

Detailed information of the process, the choices made and the results are available on the paper written by the creators: [Project's report]().

![alt text](https://github.com/[username]/[reponame]/blob/[branch]/image.jpg?raw=true)


## Repository content

- Base-Helicopter-controller: folder with the unity application. It has been created by modifying an already existing project.

- EMG_Main: main folder where the most important script is saved. The same data already acquired is here saved. The main scripts are:
    - __1_MYOAquisition__ which permits to acquire data from Myo sensor;
    - __2_LSTM_TRAINING__ which execute the Neural Network training;
    - __3_RealTimeMyo__ which is used for executing programs in real-time;
    - __4_Simulation__ which is used for executing a simulation using already acquired data;

- ZMQ: folder containing the zmq protocol used for server-client communication. It has to be executed both from MATLAB and Unity.

