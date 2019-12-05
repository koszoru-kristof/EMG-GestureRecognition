%% myo test
close all; 
clear; 
clc;



MyoData=[];
Time_=[];
install_myo_mex()
maxArrayLength=2000;

labels=["F", "OH", "R", "L", "OK"]
%% create myo mex (ONLY FIRST TIME!!!!)
% install_myo_mex; % adds directories to MATLAB search path
% sdk_path = 'C:\myo-sdk-win-0.9.0'; % root path to Myo SDK
% build_myo_mex(sdk_path); % builds myo_mex
dataset=[];


act=0;
%%labels= ["FIST","OPEN_HAND","HAND_RIGHT","HAND_LEFT","OK"]
%%labels= ["UP","DOWN","HAND_RIGHT","HAND_LEFT"]  %%,"FIST", "OPEN_HAND"]
%%labels= ["ONE","TWO","THREE","FOUR","FIVE", "SPIDERMAN", "U","CALL"]


for labeIndex=1:length(labels)
    close all
    Action=labels(labeIndex);
    
    waitingTime=2;
    for p=1:waitingTime
        disp(waitingTime-p);
        disp('HOLD THIS ACTION:   '), disp(labels{labeIndex})
        %pause(1);
    end
    disp('START ACQUISITION')
    %% generate myo instance
    install_myo_mex;
    mm = MyoMex(1);    
    pause(0.1);
    %%
    for k=1:1
        %% collect about T seconds of data
        disp('Start recording');
        T = 10;  
        m1 = mm.myoData(1);
        m1.clearLogs();
        m1.startStreaming();
        pause(1);
        %figure('units','normalized','outerposition',[0 0 1 1])
        initialTime = m1.timeEMG;        
         while m1.timeEMG-initialTime < T
%             if ~isempty(m1.timeEMG_log)
%                 for i=1:8
%                     subplot(3,3,i);
%                     plot(m1.timeEMG_log - m1.timeEMG_log(1),m1.emg_log(:,i)); 
%                     title(sprintf("%s%s%d", Action,"sensor", i));
%                 end
%             end
             pause(0.001);
         end
        
        clear initialTime;
        m1.stopStreaming();
        %%fprintf('Logged data for %d seconds, ',T);
        %%fprintf('EMG samples: %10d\tApprox. EMG sample rate: %5.2f\n',...
        %%length(m1.timeEMG_log),length(m1.timeEMG_log)/T);
        mu=[];
        sigma=[];
        MYOdata=[];
        %maxSignalLength=2000; %(10sec/5msec)
        time= m1.timeEMG_log - m1.timeEMG_log(1);
        %time=time(1:maxArrayLength);
        %%
        for i=1:8   
            act=act+1
            MYOdata(:,i)=[m1.emg_log(:,i)];
        end
        
        
        
        
        %%
        MYOdata=MYOdata(1:maxArrayLength,:);
        MyoData=[MyoData, MYOdata];
        %Time_=[Time_,time]        
    end
%     
    mm.delete;
    clear mm;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
 
end

%%
VarNames={};
for i=1:length(labels)
    for j=1:8
        VarNames_{j}= sprintf('%s%d%s',"Sensor",j,labels(i));
    end
    VarNames={VarNames{:},VarNames_{:}}
end

%%
Dataset=table();
%Time=table();
Dataset{:,:} = MyoData;
%Time{:,:} = time;
%%
Dataset.Properties.VariableNames=VarNames;
%Time.Properties.VariableNames={'Time'};
%%
writetable(Dataset,'EMG_DroneActions20sec.csv','WriteRowNames',true)
%writetable(Time,'TimeEMG_DroneActions20sec.csv','WriteRowNames',true)


%%
clc
Sizes_=size(Dataset);
rr= Sizes_(1);
cc=Sizes_(2); 

A = table2array(Dataset);
amp=A';

size(A)
size(amp)







