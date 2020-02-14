% close all; 
clear; 
clc;

class = ["RX", "F", "OH", "R", "L", "DN"];

%% Load the trained model and the data

load('training/trainingSIM.mat');

load('Data/SIMULATION-ale.mat');

%%

interest_actions = [1, 2, 3, 4, 5, 6]; 
n_of_classes = length(interest_actions);

% change data wich we are working with
FinalData = select(1, 25, interest_actions, Data_Ale);
Data = FinalData; 

% Transform to cell
temp = cellaF(Data, interest_actions);
Data = temp;

find = 0;
tried = 0;
%%
while(1)
    
tried = tried + 1;

n = round(4000*rand(1));

MyoDataRX = Data{1,1}(:,n:n+400);
MyoDataF = Data{2,1}(:,n:n+400); 
MyoDataOH = Data{3,1}(:,n:n+400); 
MyoDataR = Data{4,1}(:,n:n+400);
MyoDataL = Data{5,1}(:,n:n+400);
MyoDataDN = Data{6,1}(:,n:n+400);

l = 30*rand(1);

if(l<=5)
    MyoData = MyoDataRX;
    action = "RX"
elseif(l>5 && l<=10)
    MyoData = MyoDataF;
    action = "F"
elseif(l>10 && l <=15)
    MyoData = MyoDataOH;
    action = "OH"
elseif(l>15 && l <=20)
    MyoData = MyoDataR;
    action = "R"
elseif(l>20 && l <=25)
   MyoData = MyoDataL;
   action = "L"   
elseif(l>25 && l <=30)
   MyoData = MyoDataDN;
   action = "DN"
end

%% Convert datas to cells

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

%{
X_new = {};
for i=1:length(X)
    pippo=[];
    for j=1:10
        pippo = [pippo, X{i,:}(:,j)'];
    end
    X_new{i,1}=pippo';
end
%}

%% Predict action

    miniBatchSize = 27;   
    
    YPred = classify(net, X,'MiniBatchSize',miniBatchSize);
    
    Prediction = mode(YPred);
    
    hist(YPred);
    
    Prediction = string(Prediction)
    
%   
    if(Prediction == action)
        find = find + 1;
    end
    
    %disp(['find ',num2str(find), '/', num2str(tried)])
     
pause(1);

end