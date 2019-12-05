clc 
close all 
clear all


%%
class=["F", "R", "L", "U","D" "OK"]
n_of_classes=length(class)

%% Load Dataset
%Amp= readtable('EMG_5Actions30sec.csv');
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
%%

T=readtable('EMG_DroneActions50sec.csv');
Data=table2array(T);
%
 
%% Shuffle Data

rand_pos = randperm(length(Data(1,:)));
length(rand_pos);
for i= 1:length(rand_pos)
    Data_(:,i)= Data(:,rand_pos(i));
end 

Data=Data_
%% Define Test

XTrain=Data(1:end-1,1:end-1001);
YTrain=Data(end,1:end-1001);
XTest=Data(1:end-1,end-1000:end);
YTest=Data(end,end-1000:end);

Train=[XTrain;YTrain];
Test=[XTest;YTest];

%% define Labels as categorical Variables
% XTrain=Train(1:end-1,:);
% 
% YTrain=[];
% YTest=[];
% 
% for i=1:10000%length(Train(end,:))
%     YTrain=[YTrain, class(Train(end,i))];
% end
% 
% for i=1:1000%length(Test(end,:))
%     YTest=[YTest, class(Test(end,i))];
% end
% YTrain=categorical(YTrain);
% YTest=categorical(YTest);

XTrain = Train(1:end-1,:);

YTrain = zeros(1, length(Train(end,:)));
YTest  = zeros(1, length(Test(end,:)));

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


opts=trainingOptions("adam", "MaxEpochs",15, "InitialLearnRate",0.005, "Plots","training-progress", "GradientThreshold",1, "SequenceLength",100, "LearnRateSchedule","piecewise","LearnRateDropFactor",0.97)

    
net = trainNetwork(XTrain,YTrain,layers,opts)
save('pqfile.mat','net')
% nat=net
% save('pafile.mat','nat')

%% TEST
load("net.mat")
%%
[predClass , score]= classify(net, XTest)

plot(score')


%confusionchart(predClass, YTest)
accuracy=(sum(YTest==predClass))/length(YTest)
%%
C=confusionmat(YTest,predClass)

sum(sum(C))
%%

