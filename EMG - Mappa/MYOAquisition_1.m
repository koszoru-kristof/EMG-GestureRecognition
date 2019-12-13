clc 
clear all
close all

Data = []
%%


labels = ["DN", "F", "OH", "R", "L", "SM", "QQ"] %Fist, OpenHand, Right, Left, Up, Down

for k = 1:1
    
    labels(k)        
    disp('START ACQUISITION')
    pause(0.5)
    
    for trial=1:1
        %% myo test

        MyoData=[];
        Time_=[];

        %% create myo mex (ONLY FIRST TIME!!!!)
    
        install_myo_mex; % adds directories to MATLAB search path
        dataset=[];

        act=0;
        %%for labeIndex=1:1  %length(labels)
        close all
        %Action=labels(labeIndex);
        Features = [];
        
        %% generate myo instance
        install_myo_mex;
        mm = MyoMex(1);    
        pause(0.1);      

        %% collect about T seconds of data
            
        disp('Start recording');
        T = 25; 
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
        %fprintf('EMG samples: %10d\tApprox. EMG sample rate: %5.2f\n',...
        % length(m1.timeEMG_log),length(m1.timeEMG_log)/T);

        MYOdata = [];
        time = m1.timeEMG_log - m1.timeEMG_log(1);

        MyoData = m1.emg_log(:,:);
        mm.delete;
        clear mm; 
        
        % Last element is k, ones create an array of all ones
        newData = [MyoData'; ones(1,length(MyoData(:,1)))*k]; 
        Data    = [Data, newData];
    
        labels(k)
    

    end
    

    filename = append('EMG_1ac25sec_ALE1-06', labels(k), '.mat' )
    save(filename,'Data')
    
    
    disp(' NEXT GESTURE WILL COME, ATTENTION ! WAITTT')
    disp(labels(k+1))
    pause(10)
    
end


%% 

Dataset = table();
Dataset{:,:} = Data;
writetable(Dataset,'EMG3_1ac25sec_ALE1.csv','WriteRowNames',true)


