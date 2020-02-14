close all; 
clear; 
clc;

labels = ["RX", "F", "OH", "R", "L", "DN"];

%% Add the path necessary for zmq

run ./addZmqUtility;

topic = '';
ip    ='tcp://127.0.0.1:5000';

[pub,ok] = Publisher(ip);

if not(ok)
  errormsg('Publisher not initialized correctly');
end

%% Load the trained model

load('training/training_ALE-KK-MAX-RFOHRLDW-2layer.mat');

%% Start acquisition

trial = 1;

while trial == 1
    
    % myo test
    MyoData =[];
    Time_   =[];
    install_myo_mex; % adds directories to MATLAB search path
    dataset = [];
    % act = 0;
    
    %%
    for labeIndex = 1:1  % one acquisition for real time
        
        close all
        Features=[];
   
        disp('START ACQUISITION')
        pause(0.5)
    
        % generate myo instance
        install_myo_mex;
        mm = MyoMex(1);    
        pause(0.1);      
    
        disp('Start recording');
        T = 0.2; % Time of acquisition
        m1 = mm.myoData(1); 
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
            
        mm.delete;
        clear mm; 
        
    end

    clc
    
    result  = [];
    MyoData = MyoData';

    % End acquisition
    
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

%% Predict action

    miniBatchSize = 27;   
    
    YPred = classify(net, X,'MiniBatchSize',miniBatchSize);
    
    Prediction = mode(YPred);
    
    Prediction = string(Prediction);
    
%% Init console

   msg_labels = ["OK", "F", "U", "R", "L", "D"];
   
   index = find(labels(1,:) == Prediction);
   
   msg = char(msg_labels(index));
   
   if (strcmp(msg,''))
       break;
   end
   
   %fprintf(['Publish: '+ msg + ' \n']);
   bool = pub.publish(topic, msg); 


end




