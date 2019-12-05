%% myo test
close all; 
clear; 
clc;
%install_myo_mex();

%% Load the model
load('pqfile.mat');


for trial=1:20

%% myo test

MyoData=[];
Time_=[];

%% create myo mex (ONLY FIRST TIME!!!!)
install_myo_mex; % adds directories to MATLAB search path
% sdk_path = 'C:\myo-sdk-win-0.9.0'; % root path to Myo SDK
% build_myo_mex(sdk_path); % builds myo_mex
dataset=[];

act=0;
for labeIndex=1:1  %length(labels)
    close all
    %Action=labels(labeIndex);
    Features=[];
   
    disp('START ACQUISITION')
    pause(0.5)
    %% generate myo instance
    install_myo_mex;
    mm = MyoMex(1);    
    pause(0.1);      
    
    for k=1:1
        %% collect about T seconds of data
        disp('Start recording');
        T = 0.2; 
        m1 = mm.myoData(1);
        m1.clearLogs();
        m1.startStreaming();
        pause(T);
        %figure('units','normalized','outerposition',[0 0 1 1])
        initialTime = m1.timeEMG;
        
        while m1.timeEMG-initialTime < T
%             if ~isempty(m1.timeEMG_log)
%                 for i=1:8
%                 subplot(3,3,i);
%                 plot(m1.timeEMG_log - m1.timeEMG_log(1),m1.emg_log(:,i)); title(sprintf("%s%s%d", Action,"sensor", i));
%                 end
%             end
            %pause(0.001);
        end
        clear initialTime;
        m1.stopStreaming();
        %fprintf('Logged data for %d seconds, ',T);
%         fprintf('EMG samples: %10d\tApprox. EMG sample rate: %5.2f\n',...
%         length(m1.timeEMG_log),length(m1.timeEMG_log)/T);

        MYOdata=[];
        time= m1.timeEMG_log - m1.timeEMG_log(1);
%         time=time(1:200);
        %%
        mu= mean(m1.emg_log(:,:))';
        MyoData=m1.emg_log(:,:);
        %%
        %MYOdata=MYOdata(1:200,:);
        %MyoData=[MyoData, MYOdata];
        %Time_=[Time_,time];
    end  
    mm.delete;
    clear mm; 
end



clc
result=[];
MyoData=MyoData';
for i = 1:length(MyoData(1,:))
    [predClass(i) , score]= classify(net, MyoData(:,i));
    predClass(i);
    score;   
    result=[result,find(score== max(score))];    
end

final= mode(result);
%hist(result);
labels=["F","L","OH","OK","R"];
labels(final)

pause(1);

end






