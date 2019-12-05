% close all
% clear all
% clc
% 
% Data = readtable('EMG_DroneActions30sec.csv');
% 
% 
% %%
% VarNames= Data.Properties.VariableNames
% 
% %%
% interestedVarNames_=[];
% 
% for i=1:8 
%     newVArName=sprintf("%s%d%s", 'Sensor', i,'UP');
%     interestedVarNames_ = {interestedVarNames_, newVArName]
% end
% 
% 
% %% 
% 
% find( VarNames(:) == {"Sensor8HAND_LEFT"})


%% 
close all
clear all
clc

A=[1 1 1 43 1 1 1 1 1 54 1 1 1 229;
   1 1 1 43 1 1 1 1 1 54 1 1 1 229]
unique(A(1,:))

idx=[]
nofinterest= [54 , 43 , 229]

for i=1:length(nofinterest)
    
    newidx=find(A(1,:)==nofinterest(i));
    idx= [idx, newidx]
end 


newA= A(:,idx)




%%
%interestedVarNames = VarNames(1:8)