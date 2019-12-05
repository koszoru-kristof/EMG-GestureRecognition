clc 
close all 
clear all


%%
class = ["F", "R", "L", "U", "D", "OK"]

%class = ["F", "U", "D", "OK"]


%% Load Dataset
Data = []

%Data = writedata(25, 1, 6, 'EMG_1ac25sec_MAT', 1, Data);
Data = writedata(25, 1, 6, 'data/EMG_1ac25sec_ALE', 2, Data);

% Data = writedata(1, 5, 6, 'EMG_5ac1sec_ALE', 3, Data);
% Data = writedata(1, 5, 6, 'EMG_5ac1sec_MAT', 2, Data);

%%
% Data = writedata(25, 1, 6, 'EMG_1ac25sec_KK', 2, Data);
% Data = writedata(25, 1, 6, 'EMG_1ac25sec_MAT', 1, Data);
% Data = writedata(25, 1, 6, 'EMG_1ac25sec_Ting', 2, Data);
% Data = writedata(25, 1, 6, 'EMG_1ac25sec_MAX', 2, Data);

% actions = [F, R, L, U, D, OK];

%%

% interest_actions = [F, U, D, OK];

interest_actions = [1, 4, 5, 6]
n_of_classes = length(interest_actions)
%save('FinalDataFUDOK2ALE2KK1MAT2MAX.mat','Data');

FinalData = select(2, 25, interest_actions, Data);

save('FinalDataAle2.mat','Data');
%%
Data = FinalData;

 % 50 acq second (0.02 freq.), 8 sensors,

% Amp= readtable('EMG_5Actions30sec.csv');
% XData=[];
% plot( Amp{:,1} )

% YData=[];
% for i=1:n_of_classes
%     class(i)
%     XDataNew=[];
%     j=8*(i-1)+1;
%     XDataNew= Amp{:,j:j+7};
%     XData=[XData,XDataNew'];  
%     for k=1:length(XDataNew)
%         YData=[YData,i]; 
%     end
%     
% end
% 
% Data=[XData;YData]

%% Shuffle Data

rand_pos = randperm(length(Data(1,:)));
length(rand_pos)

for i= 1:length(rand_pos)
    Data_(:,i)= Data(:,rand_pos(i));
end 

Data=Data_;
%% Define Training and Test

XTrain=Data(1:end-1,1:end-1001);
YTrain=Data(end,1:end-1001);

XTest=Data(1:end-1,end-1000:end);
YTest=Data(end,end-1000:end);

Train=[XTrain;YTrain];
Test=[XTest;YTest];

%% define Labels as categorical Variables
%XTrain = Train(1:end-1,:);

YTrain = string(zeros(1, length(Train(end,:))));
YTest  = string(zeros(1, length(Test(end,:))));

% Da ottimizzare (allocazione statica)

for i=1:length(Train(end,:))
    YTrain(i) = class(Train(end,i));
end

for i=1:length(Test(end,:))
    YTest(i) = class(Test(end,i));
end

YTrain = categorical(YTrain);
YTest = categorical(YTest);


%%  Define Layers
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


opts = trainingOptions("adam", "MaxEpochs",15, "InitialLearnRate",0.001, "Plots","training-progress", "GradientThreshold",1, "SequenceLength",100, "LearnRateSchedule","piecewise","LearnRateDropFactor",0.97)
                                        %15                     %0.005
    
net = trainNetwork(XTrain,YTrain,layers,opts)
%%

save('trainingFinalDataAle2-87.7%.mat','net')

% nat=net
% save('pafile.mat','nat')

%% TEST

load("trainingFinalDataAle2.mat")

%%
[predClass , score]= classify(net, XTest)

plot(score')


%confusionchart(predClass, YTest)
accuracy=(sum(YTest==predClass))/length(YTest)
%%
C=confusionmat(YTest,predClass)

sum(sum(C))