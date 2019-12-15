
close all; 
clear; 
clc;

labels = ["F", "R", "L", "U", "D", "OK"];

path(pathdef);
clc;

% Add the path necessary for zmq
run ./addZmqUtility;

topic = '';
ip    ='tcp://127.0.0.1:5000';

[pub,ok] = Publisher(ip);
if not(ok)
  errormsg('Publisher not initialized correctly');
end

pause(1);

%% Load the trained model
load('training/training-ALE-FRLOK.mat');

%% Start acquisition

for trial = 1:20
    
    % myo test

    MyoData =[];
    Time_   =[];

    %% create myo mex (ONLY FIRST TIME!!!!)
    
    install_myo_mex; % adds directories to MATLAB search path
    dataset = [];

    act = 0;
    
    %%
    for labeIndex = 1:1  %length(labels) - just one cause real time
        
        close all
        Features=[];
   
        disp('START ACQUISITION')
        pause(0.5)
    
        % generate myo instance
        install_myo_mex;
        mm = MyoMex(1);    
        pause(0.1);      
    
            for k=1:1
                % collect about T seconds of data
                disp('Start recording');
                T = 0.2; 
                m1 = mm.myoData(1); % Time of acquisition
                m1.clearLogs();
                m1.startStreaming();
                pause(T);
                
                initialTime = m1.timeEMG;
        
                clear initialTime;
                
                m1.stopStreaming();

                MYOdata=[];
                
                time = m1.timeEMG_log - m1.timeEMG_log(1);
                
                mu = mean(m1.emg_log(:,:))';
                MyoData = m1.emg_log(:,:);

            end  
            mm.delete;
            clear mm; 
    end

%%
    clc
    
    result  = [];
    MyoData = MyoData';

%% Simulation of MyoData

% %{

clc
clear all
close all

labels = ["F", "R", "L", "OK"];

load('training/training_ALE-KK-MAT(6.6)_-FRLOK.mat');
load('data/EMG_MAX_complessivi_2.2_FRLUDOK.mat');

% MyoData is a vector 8 x 400(data/s)*time(s) 25 sec -> 8x60000

interest_actions = [1, 2, 3, 6]; 
n_of_classes = length(interest_actions);

FinalData = select(1, 25, interest_actions, Data);
Data = FinalData; % change data wich we are working with

temp = cellaF(Data, interest_actions);
Data = temp;
%%

while(1)
    
n = round(4000*rand(1));

MyoDataF = Data{1,1}(:,n:n+200);
MyoDataR = Data{2,1}(:,n:n+200); 
MyoDataL = Data{3,1}(:,n:n+200); 
MyoDataOK = Data{4,1}(:,n:n+200);

% %}

close all
clc
<<<<<<< HEAD

l = 20*rand(1);

if(l<=5)
    MyoData = MyoDataR;
    "right"
elseif(l>5 && l<=10)
    MyoData = MyoDataL;
    "left"
elseif(l>10 && l <=15)
    MyoData = MyoDataOK;
    "OK"
else
    MyoData = MyoDataF;
    "FIRST"
end

%% Convert datas to cells
=======
%MyoData = MyoDataL;
>>>>>>> f2dcc4d1f86a203a37d641408faba20b80e88387

X = {MyoData};

X_fin = {};

n_acquisition = 15;

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

%% Predict action

    miniBatchSize = 27;   
    
    YPred = classify(net, X,'MiniBatchSize',miniBatchSize);
    
    Prediction = mode(YPred)
    hist(YPred);
    
    msg = string(Prediction);
    
    %i=0;
    %for ii = 1:length(YPred)
    %    if(YPred(ii,1) == "OK")
        i = i + 1;
    %    end
    %end
    pause(1)
end    
%%
% pause(1);

%% Init console

close all;
   
   if (strcmp(msg,''))
       break;
   end
   
   fprintf(['Publish: ' msg ' \n']);
   bool = pub.publish(topic, msg); 
   pause(1);


end



