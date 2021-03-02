clear all
close all 
clc

%% INDICE:                          #0
% #0  INDICE
% #1  INTRODUZIONE
% #2  CARICARE LE TABELLE CON I DATI 
% #3  VISUALIZZIAMO I GRAFICI (ROW DATA)      
% #4  MOVING AVERAGE (MA)
% #5  VISUALIZZIAMO I GRAFICI DEI DATI FILTRATI  
% #6  CALCOLO DELLE FEATURES
% #7  TROVO I SENSORI CON MINOR DISPERSIONE  
% #9  SHUFFLE THE LINE RANDOM    
% #10 DEFINE TRAINING AND TESTING DatasetMean
% #11 Salvo i DatasetMeans             
% #12 Load DatasetMeans
% #13 Example of Moving Average


%% INTRODUZIONE:                    #1
%Questa lezione punta ad analizzare le basi di acquisizione del segnale con
%MYO.
%Inoltre introdurremo le basi del Machine Learning e vedremo come si allena
%un modello a riconoscere dei Pattern.


%COSA è MYO:
% Il MYO un dispositivo commerciale che acquisisce con 8 sensori lo stato
%di attivazione dei muscoli superficiali. 
%Ogni sensore è una placchetta Emg rettangolare. 
% https://www.youtube.com/watch?v=ecDlv6R9hR0


%COSA è UN SENSORE EMG:
%Un sensore EMG misura la differenza di Potenziale tra due punti lungo
%l'estenzione del muscolo. (vedi grafici) 

% EMG (ElettroMioGrafia) IN MEDICINA: 
% https://www.auxologico.it/prestazione/elettromiografia

%% CARICARE LE TABELLE CON I DATI           #2
%%  Per Gestire solo 2 Azioni ( 16 colonne e 1 Time array)
% EmgTable = readtable('EMG_FistAndOpenHand.csv'); %carico il DatasetMean con il comando readtable
% %ora la variabile EmgDatasetMean è una tabella (simile ad una matrice) con
% %tutte le ampiezze dei sensori
% TimeTable= readtable('TimeEMG_FistAndOpenHand.csv'); %carico i dati del tempo con il comando readtable

%% Per Gestire tutte e 5 le Azioni ( 40 colonne (8 colonne per ogni azione) e 1 Time array)
% EmgTable = readtable('Tables/EMG_5Actions30sec.csv'); %carico il DatasetMean con il comando readtable
% EmgTable = readtable('Tables/EMG_6DroneActions30sec.csv');
EmgTable = readtable('Tables/EMG_8Actions30sec.csv');
% TimeTable= readtable('Tables/TimeEMG_5Actions30sec.csv'); %carico i dati del tempo con il comando readtable
% TimeTable= readtable('Tables/TimeEMG_6DroneActions30sec.csv');
TimeTable= readtable('Tables/TimeEMG_8Actions30sec.csv');
%%  VISUALIZZIAMO I GRAFICI (ROW DATA)          #3

NdiAzioni=8; % lo uso dopo per il for cycle così itero sul numero di azioni, prima solo 2 azioni poi tutte e 5
NdiSensori= 8; 
FreqDiCampionamento=200; 
% time=TimeTable{1:end};
%Actions= ["FIST","OPEN_HAND","HAND_RIGHT","HAND_LEFT","OK"] %sono le 5 azioni che andiamo ad analizzare
%Actions= ["UP","DOWN","HAND_RIGHT","HAND_LEFT","FIST", "OPEN_HAND"]
Actions= ["ONE","TWO","THREE","FOUR","FIVE", "SPIDERMAN", "U","CALL"]

% ORA CREIAMO 2 for cycles uno per iterare sugli 8 
% sensori dentro ad un altro for cyle per iterare lungo le Azioni (2 o 5)
%OGNI AZIONE è Descritta da 8 sensori 
% la variabile i varierà tra 1 e 8 --> per rapresentare i sensori
%la variabile "j" varierà tra 1 e 5 --> per descrivere le azioni 
% la variabile index= i+(j-1)*8 serve solo per andare a prendere la colonna
% giusta di EmgTable per andare a prendere i-esimo sensore della j-esima
% azione. 
% Esempio: se valuto la terza azione, "HAND_RIGHT" (j=3),  dovrò prendere le
% colonne dalla index=1+(3-1)*8= 17  fino alla colonna index=8+(3-1)*8= 24

for j=1:NdiAzioni    %itero sul numero di Azioni 
    Action=Actions(j);
    figure(j)
    for i=1:NdiSensori     % è lo stesso che scrivere "per i che va da 1 a 8" 
        index=i+(j-1)*8
        Titolo= sprintf("%s%s%d", Action,"sensor", i)              %sprintf serve per creare variabili char (parole) in maniera automatica
        %usare "sprintf" mi evita di dover scrivere ogni titolo a mano
        subplot(3,3,i);
        plot(TimeTable{1:end,1},EmgTable{1:end, index}); 
        title(Titolo);        
    end    %fine dell'iterazione sui sensori 
end        %fine dell'iterazione sulle azioni

%% MOVING AVERAGE, filtro i dati              #4
% % https://www.investopedia.com/terms/m/movingaverage.asp#what-is-a-moving-average
% % https://www.investopedia.com/terms/s/sma.asp 
 EmgTableMod= EmgTable;

%% Machine LEARNING
%% https://lorenzogovoni.com/machine-learning-e-funzionamento/
%%  Preparo il DatasetMean per il Training e il Testing del modello di ML #8
AmplificationFactor=1000;
EmgTableMod1= EmgTable;
DatasetMean=table();
DatasetMeanSigma=table();
DatasetMeanPow=table();
MAinterval=100;   %finestra di osservazione di 1 sec , dato che campiona a 200Hz, ovvero ogni 50 millisecondi (Tsampling= 1/F = 1/200H = 50ms)
for j=1:NdiAzioni    %itero sul numero di Azioni 
    Azione=Actions(j)
    muData=table();
    sigmaData=table();
    PowArrData=table();
    for i=1:NdiSensori     % è lo stesso che scrivere "per i che va da 1 a 8" 
        index=i+(j-1)*8;
        mu=[];
        sigma=[];   % https://it.wikipedia.org/wiki/Varianza     LO CHIAMO SIGMA MA IN REALTà è sigma^2  (LA VARIANZA)
        PowArr=[];
        for p=1:MAinterval:length(EmgTableMod{:,index})-MAinterval      %itero sull'array ogni 200 righe (MAinterval=200) calcolo media e varianza
            newSignal=EmgTableMod{p:p+MAinterval,index};
            newTime= TimeTable{p:p+MAinterval,1};
            new_mu=mean(abs(newSignal));        %calcolo la nuova media delle 200 righe in questione
            new_sigma=var(abs(newSignal))*AmplificationFactor;  %calcolo la nuova varianza delle 200 righe in questione, Amplifico di un fattore grande per poter vedere meglio le differenze 
            mu=[mu;new_mu];   %salvo il nuovo valore nell'array delle medie
            sigma=[sigma;new_sigma];    %salvo il nuovo valore nell'array delle varianze
            N=6;
            [newPowArr, newfreqArr,newPowerDist]= PowerArray(newSignal,newTime,N) ;
            PowArr=[PowArr;newPowArr];
        end
        muData{:,i} = mu;           %salvo l'array delle medie come nuova riga tabella  muData(la riga i-esima)
        sigmaData{:,i} = sigma;     %salvo l'array delle varianze come nuova riga della tabella sigmaData(la riga i-esima)
        PowArrData{:,(i-1)*N+1:N*i} = PowArr; 
    end    %fine dell'iterazione sui sensori 
    muData{:,9} = Azione;
    sigmaData{:,9} = Azione;
    PowArrData{:,8*N+1} = Azione;
    DatasetMean=[DatasetMean;muData];
    DatasetMeanSigma=[DatasetMeanSigma; sigmaData];
    DatasetMeanPow= [DatasetMeanPow;PowArrData];
end
figure(66)
plot(newfreqArr,newPowerDist);
%%
VarNames= {'Sesor1','Sesor2','Sesor3','Sesor4','Sesor5','Sesor6','Sensor7', 'Sensor8','label'}
VarNamesSigma= {'Sesor1Sigma','Sesor2Sigma','Sesor3Sigma','Sesor4Sigma','Sesor5Sigma','Sesor6Sigma','Sensor7Sigma', 'Sensor8Sigma','label'}
DatasetMean.Properties.VariableNames=VarNames;
DatasetMeanSigma.Properties.VariableNames=VarNamesSigma;

%% PUT ALL TOGETHER THE DATASETs
Dataset=table();
Dataset= [DatasetMean(:,1:end-1),DatasetMeanSigma(:,1:end-1),DatasetMeanPow(:,1:end-1),DatasetMean(:,end)];
%Dataset= [DatasetMean(:,1:end-1),DatasetMeanSigma(:,1:end-1),DatasetMean(:,end)];
% Dataset= DatasetMean;
% Dataset=DatasetMeanSigma;

%% Plot Features in the 3D space
close all

figure(30)
for j=1:8   
    subplot(3,3,j)
    scatter(DatasetMean{1:9,j},DatasetMeanSigma{1:9,j},30,[0,0,1] ); 
    hold on 
    scatter(DatasetMean{10:18,j},DatasetMeanSigma{10:18,j},30,[0,1,0] ); 
    scatter(DatasetMean{19:27,j},DatasetMeanSigma{19:27,j},30,[1,0,0] ); 
    scatter(DatasetMean{28:36,j},DatasetMeanSigma{28:36,j},30,[0,0,0]); 
    scatter(DatasetMean{37:45,j},DatasetMeanSigma{37:45,j},30,[1,1,0] ); 
    title( sprintf("%s%d", "Sensor_", j))  
    xlabel('medie')
    ylabel('varianze')
end

a=0

%% SHUFFLE THE LINE RANDOM          #9
DatasetMeanShuffle = Dataset(randperm(size(DatasetMean, 1)), :)
%% DEFINE TRAINING AND TESTING DatasetMean  #10 
DatasetMeanSize=size(DatasetMeanShuffle);   %capisco quante righe e colonne ho 
NdiRighe=DatasetMeanSize(1);            %assegno a questa variabile il numero di samples del DatasetMean
porzionediTraining= 90;             %definisco le proporzioni di Training e Testing
NofTrainingrows=round((NdiRighe/100*porzionediTraining))    %capisco in proporzione quanti samples( righe) definisce a porzione scelta 
Train=table();
Test=table();
Train=DatasetMeanShuffle(1:NofTrainingrows,:);      %assegno la porzione scelta al Training 
Test=DatasetMeanShuffle(NofTrainingrows+1:end,:);       %assegno la porzione rimanente al Testing

%% Salvo i DatasetMeans        #11
writetable(Train,'EMGTrainRT.csv','WriteRowNames',true)
writetable(Test,'EMGTestRT.csv','WriteRowNames',true)

%% Load DatasetMeans            #12
Train = readtable('EMGTrainRT.csv');
Test = readtable('EMGTestRT.csv');


%%  Train and Train         #13
[success, validation,compare] = train_and_test(Train,Test);
compare
success









