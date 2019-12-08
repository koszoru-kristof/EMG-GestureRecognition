clc 
close all 
clear all


class = ["F", "R", "L", "U", "D", "OK"]; % Which class we got in the data file we upload 


Data = [];
numberacqu = 4; % Starting from 0 the number of acquisition

%% Load Dataset

[Data, numberacqu] = writedata(25, 1, 6, 'data/EMG_1ac25sec_KK', 2, Data, numberacqu);
%[Data, numberacqu] = writedata(25, 1, 6, 'data/EMG_1ac25sec_MAT', 1, Data, numberacqu);

[Data, numberacqu] = writedata(25, 1, 6, 'data/EMG_1ac25sec_ALE', 2, Data, numberacqu);

save('FinalData2ALE.mat','Data'); % If you wana save
% datas

%%

%interest_actions   = [1, 2, 4, 6]; %[ F, R, U, OK];

interest_actions = [1, 4, 5, 6];  % [F, U, D, OK]
% interest_actions = [1, 2, 3, 6]; % [F, R, L, OK]

n_of_classes = length(interest_actions);

FinalData = select(numberacqu, 25, interest_actions, Data);
Data = FinalData; % chande data wich we are working with

%% Create some cells from arrays

temp = cellaF(Data, interest_actions);
Data = temp;

%% Define X/Y

X = {};
Y = [];


for ii = 1:length(Data)
    
    temp = Data{ii,1};
    n = 0.1*length(Data{ii,1});
    
    X{ii,1} = temp(1:8, 1:end);
    Y(ii,1) = temp(9, 1)';
    
end


%%
X_ = {};
Y_ = [];

X_fin = {};
Y_fin = [];

for ii = 1:length(X)   

    temp = X{ii,1};
    
    leng = 640/length(X);
    
    n_part = round(length(X{ii,1})/leng - 0.5)/4;    
        
    for jj = 0:(leng-1)
        num = jj*ii+1;
        X_{jj+1,1} = temp(1:8, 1 + n_part*(jj):n_part*(jj+1));
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

tot = leng * 4;
jump = 2; % every two elements a test
num_test = tot/jump;
jj = 1;

for ii = 1:(num_test)
   
	X_test{jj,1} = X_{jump*(ii), 1}; % X_test{jj,1} = X_(salto*(ii), 1);
    test = [test jump*(ii)];
	Y_test(jj) = Y_(jump*(ii));  
    
    jj = jj + 1;
   
end

Y_test = Y_test';

% Create Train cell

% Invert test vector, in order to delete the x elements starting from le end
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
    X_ Y_ test test1 num n_part i temp1 temp2

figure
plot(X_train{1}')
title("Training Observation 1")
numFeatures = size(X_train{1},1);
legend("Feature " + string(1:numFeatures),'Location','northeastoutside')

%% Define Training algorithm

% Train the net with that part

% Layers
inputSize = 8;
numHiddenUnits = 100;
numClasses = n_of_classes;

layers = [ ...
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
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

save('training/trainingFinal2ALE2KKFRUOK_adam(new).mat','net')


%% Test the net

load("training/trainingFinal2ALE2KKFRUOK_adam(new).mat")

YPred = classify(net,X_test,'MiniBatchSize',miniBatchSize);

acc = sum(YPred == Y_test)./numel(Y_test)


% Confusion matrix

C = confusionmat(Y_test,YPred)

sum(sum(C))