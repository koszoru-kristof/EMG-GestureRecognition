clc 
close all 
clear all


class = ["RX", "F", "OH", "R", "L", "SM"]; % Which class we got in the data file we upload 


Data = [];
numberacquFILE = 0; % Starting from 0 the number of acquisition, if you don't load files

%% Load files
%{
load('data/EMG_ALE_complessivi_2.6_FRLUDOK.mat');
Data1 = Data;
load('data/EMG_KK_complessivi_1.4_FRLUDOK.mat');
Data2 = Data;
load('data/EMG_MAT_complessivi_2.6_FRLUDOK.mat');
Data3 = Data;
load('data/EMG_MAX_complessivi_2.2_FRLUDOK.mat');
Data4 = Data;
load('data/EMG_Ting_complessivi_2.8_FRLUDOK.mat');
Data5 = Data;

Data = [Data Data1 Data2 Data3 Data4 Data5];
%% Load Dataset
%}

[Data, numberacquFILE] = writedata(25, 1, 6, 'data/EMG3_1ac25sec_ALE', 1, Data, numberacquFILE);
% [Data, numberacquFILE] = writedata(25, 1, 6, 'data/EMG_1ac25sec_MAT', 2, Data, numberacquFILE);
% [Data, numberacquFILE] = writedata(25, 1, 6, 'data/EMG_1ac25sec_KK', 1, Data, numberacquFILE);

% [Data, numberacquFILE] = writedata(1, 5, 6, 'data/EMG_1ac25sec_KK', 2, Data, numberacquFILE);
%[Data, numberacquFILE] = writedata(1, 5, 6, 'data/EMG_5ac1sec_Ting', 4, Data, numberacquFILE);
% [Data, numberacquFILE] = writedata(1, 5, 6, 'data/EMG_5ac1sec_MAT', 3, Data, numberacquFILE);

filename = append('data/EMG2_ALE_DN_', string(numberacquFILE),'_DN','.mat')

save(filename,'Data');
%}

%%

%interest_actions = [1, 2, 3, 6];

% interest_actions = [1, 2, 3, 6]; % [F, R, L, OK]

interest_actions = [1, 2, 3, 4, 5, 6];

n_of_classes = length(interest_actions);


FinalData = select(numberacquFILE, 25, interest_actions, Data);
Data = FinalData; % chande data wich we are working with

%% Create some cells from arrays

temp = cellaF(Data, interest_actions);
Data = temp;

%% Define X/Y

X = {};
Y = [];


for ii = 1:length(Data)
    
    temp = Data{ii,1};
    
    X{ii,1} = temp(1:8, 1:end);
    Y(ii,1) = temp(9, 1)';
    
end


%%
X_ = {};
Y_ = [];

X_fin = {};
Y_fin = [];

for ii = 1:length(X)   
    
    % how many elements each cell
    temp = X{ii,1};

    n_acquisition = 10;
    leng = round(length(X{ii,1})/(n_of_classes * n_acquisition) - 0.5);
    
    n_cells = round(leng*n_of_classes - 0.5);
    
    for jj = 0:(leng-1)
        num = jj*ii+1;
        X_{jj+1,1} = temp(1:8, 1 + n_acquisition*(jj):n_acquisition*(jj+1));
        Y_(jj+1) = Y(ii);  
    end
    
    X_fin = {X_fin{:,:} X_{:,1}};
    Y_fin = [Y_fin Y_];
    
end

X_ = X_fin';
Y_ = Y_fin';

%% Train and Test

X_test = {};
Y_test = [];

test = [];

% How many test elements

tot = leng * n_of_classes;
jump = 10; % every two elements a test
num_test = round(tot/jump - 0.5);
jj = 1;

for ii = 1:(num_test)
   
	X_test{jj,1} = X_{jump*(ii), 1}; % X_test{jj,1} = X_(salto*(ii), 1);
    test = [test jump*(ii)];
	Y_test(jj) = Y_(jump*(ii));  
    
    jj = jj + 1;
   
end

Y_test = Y_test';

% Create Train cell

% Invert test vector, in order to delete the X elements starting from le end
temp = [];

for i = 1:length(test)
    temp = [test(1,i) temp];    
end

test = temp;

% Delete X elements already present in test cell. Be careful, X change

for i = 1:length(test)
    X_(test(1,i)) = [];  
    Y_(test(1,i)) = [];
end

X_train = X_;
Y_train = Y_;

%% Define Labels as categorical Variables

temp1 = "";
temp2 = "";

for i = 1:length(Y_train(:,1))
    temp1(i) = class(Y_train(i));
end

for i = 1:length(Y_test(:,1))
    temp2(i) = class(Y_test(i)); % With cells
end

Y_train = temp1';
Y_test = temp2';

Y_train = categorical(Y_train);
Y_test  = categorical(Y_test);

%% Clear Workspace and plot the first Observation

clc
clear FinalData numberacqu temp Data ii n jj...
    X_fin Y_fin X Y salto leng num_test tot ...
    X_ Y_ test test1 num n_part i temp1 temp2...
    Data1 Data2 Data3 Data4 Data5

figure
plot(X_train{1}')
title("Training Observation 1")
numFeatures = size(X_train{1},1);
legend("Feature " + string(1:numFeatures),'Location','northeastoutside')

%% Define Training algorithm

% Train the net with that part

% Layers
inputSize = 8;
numHiddenUnits = 150;
numClasses = n_of_classes;

layers = [ ...
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(n_of_classes*100)
    dropoutLayer(0.3) % Dropout layer
    fullyConnectedLayer(n_of_classes)
    softmaxLayer
    classificationLayer]

% Options

maxEpochs = 100;
miniBatchSize = 27;

options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'GradientThreshold',1, ...
    'Verbose',false, ...
    'Plots','training-progress');

    
net = trainNetwork(X_train,Y_train,layers,options);

%% Save training datas

save('training/training_ALE-RFOHRLSM-2layer.mat','net')


%% Test the net

load("training/training_ALE-KK-MAT(6.6)_-FRLOK-1layer.mat")

%%

miniBatchSize = 27;

YPred = classify(net, X_test,'MiniBatchSize',miniBatchSize);

acc = sum(YPred == Y_test)./numel(Y_test)

% Confusion matrix
C = confusionmat(Y_test,YPred)

trace(C)