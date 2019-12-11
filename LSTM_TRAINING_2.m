clc 
close all 
clear all


class = ["F", "R", "L", "U", "D", "OK"]; % Which class we got in the data file we upload 


Data = [];
numberacqu = 2; % Starting from 0 the number of acquisition

%% Load Dataset

%[Data, numberacqu] = writedata(25, 1, 6, 'data/EMG_1ac25sec_KK', 2, Data, numberacqu);
%[Data, numberacqu] = writedata(25, 1, 6, 'data/EMG_1ac25sec_MAT', 1, Data, numberacqu);

[Data, numberacqu] = writedata(25, 1, 6, 'data/EMG_1ac25sec_ALE', 2, Data, numberacqu);

save('FinalData2ALE.mat','Data'); % If you wana save
% datas

%%

interest_actions   = [1, 2, 4, 6]; %[ F, R, U, OK];

% interest_actions = [1, 4, 5, 6]  % [F, U, D, OK]
% interest_actions = [1, 2, 3, 6]; % [F, R, L, OK]

n_of_classes = length(interest_actions);

FinalData = select(numberacqu, 25, interest_actions, Data);
Data = FinalData; % chande data wich we are working with
s%% Shuffle Data

rand_pos = randperm(length(Data(1,:)));

for i= 1:length(rand_pos)
    Data_(:,i)= Data(:,rand_pos(i));
end 

Data = Data_;

%% Define Training and Test

% We should use the 10% for the test
n_data = length(Data(end,:));
n_test = n_data*0.1;

XTrain = Data(1:end - 1, 1:end - (n_test));
YTrain = Data(end, 1:end - n_test);

XTest  = Data(1:end - 1, end - n_test:end);
YTest  = Data(end, end - n_test:end);

Train  = [XTrain;YTrain];
Test   = [XTest;YTest];

%% define Labels as categorical Variables

YTrain = string(zeros(1, length(Train(end,:))));
YTest  = string(zeros(1, length(Test(end,:))));

for i=1:length(Train(end,:))
    YTrain(i) = class(Train(end,i)); % With arrays
    %YTrain(i) = class(temp1(i)); % With cells
end

for i=1:length(Test(end,:))
    YTest(i) = class(Test(end,i)); % With arrays
    %YTest(i) = class(temp2(i)); % With cells
end

YTrain = categorical(YTrain);
YTest = categorical(YTest);

%%  Define Layers
% Train the net with that part



layers= [ 
    sequenceInputLayer(8) 
    lstmLayer(100,'OutputMode','sequence') 
    lstmLayer(100,'OutputMode','sequence') 
%     lstmLayer(100,'OutputMode','sequence') 
%     lstmLayer(100,'OutputMode','sequence') 
    fullyConnectedLayer(n_of_classes) 
    softmaxLayer()
    classificationLayer()
    ]


opts = trainingOptions("adam", "MaxEpochs",30, "InitialLearnRate",0.0005, "Plots","training-progress", "GradientThreshold",1, "SequenceLength",100, "LearnRateSchedule","piecewise","LearnRateDropFactor",0.97)
                        %adam               %15                     %0.005
    
net = trainNetwork(XTrain,YTrain,layers,opts)

save('training/trainingFinal2ALEFRUOK_adam.mat','net')



%% TEST

load("training/trainingFinal2ALEFRLOK_rmsprop-81%.mat")

%%
[predClass , score]= classify(net, XTest)

plot(score')

%confusionchart(predClass, YTest)
accuracy=(sum(YTest==predClass))/length(YTest)
%%
C=confusionmat(YTest,predClass)

sum(sum(C))