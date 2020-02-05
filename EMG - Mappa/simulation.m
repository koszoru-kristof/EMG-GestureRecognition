% close all; 
clear; 
clc;

class = ["RX", "F", "OH", "R", "L", "DN"];

%% Load the trained model and the data

load('training/training_ALE-KK-MAX-RFOHRLDW-2layer');

load('Data/TOT-SIMULAZIONE.mat');


%%z

interest_actions = [1, 2, 3, 4, 5, 6]; 
n_of_classes = length(interest_actions);

% change data wich we are working with
FinalData = select(1, 25, interest_actions, Data);
Data = FinalData; 

% Transform to cell
temp = cellaF(Data, interest_actions);
Data = temp;

%%

while(1)
    
n = round(9000*rand(1));

MyoDataRX = Data{1,1}(:,n:n+40);
MyoDataF = Data{2,1}(:,n:n+40); 
MyoDataOH = Data{3,1}(:,n:n+40); 
MyoDataR = Data{4,1}(:,n:n+40);
MyoDataL = Data{5,1}(:,n:n+40);
MyoDataDN = Data{6,1}(:,n:n+40);

l = 30*rand(1);

if(l<=5)
    MyoData = MyoDataRX;
    action = "RELAX"
elseif(l>5 && l<=10)
    MyoData = MyoDataF;
    action = "FIST"
elseif(l>10 && l <=15)
    MyoData = MyoDataOH;
    action = "OPEN HEND"
elseif(l>15 && l <=20)
    MyoData = MyoDataR;
    action = "RIGHT"
elseif(l>20 && l <=25)
   MyoData = MyoDataL;
   action = "LEFT"   
elseif(l>25 && l <=30)
   MyoData = MyoDataDN;
   action = "DOWN"
end

% Convert datas to cells

X = {MyoData};

X_fin = {};

n_acquisition = 10;

for ii = 1:length(X)   
    
    % how many elements each cell
    temp = X{ii,1};
    leng = round(length(X{ii,1})/(n_acquisition) - 0.5);
    
    for jj = 0:(leng-1)
        num = jj*ii+1;
        X_{jj+1,1} = temp(1:8, 1 + n_acquisition*(jj):n_acquisition*(jj+1));
    end
    
    X_fin = {X_fin{:,:} X_{:,1}};
    
end

X = X_fin';

% Predict action

    miniBatchSize = 27;   
    
    YPred = classify(net, X,'MiniBatchSize',miniBatchSize);
    
    Prediction = mode(YPred);
    
    hist(YPred);
    
    Prediction = string(Prediction)
    
%

pause(1.5);

end