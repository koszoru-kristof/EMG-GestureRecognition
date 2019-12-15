function [sample] = ExtractFeatures(EmgTableMod,TimeTable)
NdiSensori=8;
sample=table();
muData=table();
sigmaData=table();
PowArrData=table();
AmplificationFactor=1000;
    for i=1:NdiSensori     % è lo stesso che scrivere "per i che va da 1 a 8" 
        index=i;
        mu=[];
        sigma=[];   % https://it.wikipedia.org/wiki/Varianza     LO CHIAMO SIGMA MA IN REALTà è sigma^2  (LA VARIANZA)
        PowArr=[];
        %for p=1:MAinterval:length(EmgTableMod{:,index})-MAinterval      %itero sull'array ogni 200 righe (MAinterval=200) calcolo media e varianza
            newSignal=EmgTableMod{:,index};
            newTime= TimeTable{:,1};
            new_mu=mean(abs(newSignal));        %calcolo la nuova media delle 200 righe in questione
            new_sigma=var(abs(newSignal))*AmplificationFactor;  %calcolo la nuova varianza delle 200 righe in questione, Amplifico di un fattore grande per poter vedere meglio le differenze 
            mu=[mu;new_mu];   %salvo il nuovo valore nell'array delle medie
            sigma=[sigma;new_sigma];    %salvo il nuovo valore nell'array delle varianze
            N=6;
            [newPowArr, newfreqArr,newPowerDist]= PowerArray(newSignal,newTime,N) ;
            PowArr=[PowArr;newPowArr];
        %end
        muData{:,i} = mu;           %salvo l'array delle medie come nuova riga tabella  muData(la riga i-esima)
        sigmaData{:,i} = sigma;     %salvo l'array delle varianze come nuova riga della tabella sigmaData(la riga i-esima)
        PowArrData{:,(i-1)*N+1:N*i} = PowArr; 
    end    %fine dell'iterazione sui sensori 
    
VarNames= {'Sesor1','Sesor2','Sesor3','Sesor4','Sesor5','Sesor6','Sensor7', 'Sensor8'}
VarNamesSigma= {'Sesor1Sigma','Sesor2Sigma','Sesor3Sigma','Sesor4Sigma','Sesor5Sigma','Sesor6Sigma','Sensor7Sigma', 'Sensor8Sigma'}
muData.Properties.VariableNames=VarNames;
sigmaData.Properties.VariableNames=VarNamesSigma;

 sample=   [muData,sigmaData,PowArrData];    
    
    
end