clc 
close all 
clear all


class = ["RX", "F", "OH", "R", "L", "DN"]; % Which class we got in the data file we upload 


Data = []; 
numberacquFILE = 0; % Starting from 0 the number of acquisition, if you don't load files

%% Load files

% Alessandro datas

load('data/EMG2_ALE_DN_1_DN.mat');
Data2 = Data;
Data2(9,:) = 6;

load('data/EMG2_ALE_complessivi_1_RXFOHRLSM.mat');
Data1 = Data;

% We want to remove an action from the second file adding a new one. We
% acquire the down later

interest_actions = [1, 2, 3, 4, 5];
FinalData = select(numberacquFILE, 25, interest_actions, Data1);

Data1 = FinalData;

% Kristóf datas

load('data/EMG3_KK_DN_1.mat');
Data4 = Data;
Data4(9,:) = 6;

load('data/EMG2_KK_complessivi_1_RXFOHRLSM1.mat');
Data3 = Data;
position = [];

interest_actions = [1, 2, 3, 4, 5];

FinalData = select(numberacquFILE, 25, interest_actions, Data3);
Data3 = FinalData; % chande data wich we are working with

% Massimiliano datas

load('data/EMG3_Max_RxFOhRLDn1.mat');
Data5 = Data;

% Put all the data together

Data = [Data1 Data2 Data3 Data4 Data5]; 

%% If necessary Load Dataset from csv file

[Data, numberacquFILE] = writedata(25, 1, 1, 'EMG2_1ac25sec_ALE1-06', 1, Data, numberacquFILE);

filename = append('data/EMG2_ALE_DN_1_DN', string(numberacquFILE),'.mat');

save(filename,'Data');

%%

interest_actions = [1, 2, 3, 4, 5, 6]; % Number of the action

n_of_classes = length(interest_actions);

% If you want to select some actions from the file.
FinalData = select(numberacquFILE, 25, interest_actions, Data);
Data = FinalData;

%% Create some cells from arrays

temp = cellaF(Data, interest_actions);
Data = temp;

% Define X/Y -> sensor aplitude / action

X = {};
Y = [];

for ii = 1:length(Data)   
    temp = Data{ii,1};    
    X{ii,1} = temp(1:8, 1:end);
    Y(ii,1) = temp(9, 1)';   
end

clear Data1 Data2 Data3 Data4 Data5 FinalData;

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

% Define training and test part
X_test = {};
Y_test = [];
test = [];

% How many test elements
tot = leng * n_of_classes;
jump = 6; % every six elements a test
num_test = round(tot/jump - 0.5);
jj = 1;

for ii = 1:(num_test-1)
	X_test{jj,1} = X_{jump*(ii), 1}; % X_test{jj,1} = X_(salto*(ii), 1);
    test = [test jump*(ii)]; % Save the position of the test cell
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

%% Clear Workspace and plot Observation s

figure
hold on
plot(X_train{1}', 'linestyle','-','linewidth',1)
grid on 
xlabel('Sample')
ylabel('Amplitude')
numFeatures = size(X_train{1},1);
legend("Sensor " + string(1:numFeatures),'Location','northeastoutside')
hold off

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

maxEpochs = 50;
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

save('training/training_ALE-KK-MAX-RFOHRLDW-2layer.mat','net')


%% Test the net and plot the confusion matrix

load("training/training_ALE-KK-MAX-RFOHRLDW-2layer.mat")

miniBatchSize = 27;

YPred = classify(net, X_test,'MiniBatchSize',miniBatchSize);

acc = sum(YPred == Y_test)./numel(Y_test)

C = confusionmat(Y_test,YPred)

trace(C)