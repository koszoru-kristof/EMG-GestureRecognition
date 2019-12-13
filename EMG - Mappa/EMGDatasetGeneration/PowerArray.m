function [Pperc,f,PowerDist]= PowerArray(amp,time,N) 

%%  compute FFT of the signal
Ts= mean(diff(time));     %samplingTime
Fs=1/ mean(diff(time)); %SamplingFrequency
L=length(time);
n = 2^nextpow2(L);

Y1 = fft(amp);
P21 = abs(Y1/L);
P11 = P21(1:L/2+1);
P11(2:end-1) = 2*P11(2:end-1);
f = Fs*(0:(L/2))/L;




%% compute Total Power of the signal
Pd1=abs(P11).^2;
P1tot=0;
for i = 1:length(f)-1
    P1_=(Pd1(i)+Pd1(i+1))*(f(i)+f(i+1))/2;
    P1tot=P1tot+P1_;
end
%% compute Percentage of Power of the signal
FreqStep=round(length(f)/N);
Pperc=[];
PowerDist=zeros(length(f),1);
for j=1:FreqStep:length(f)-(FreqStep)
    Ptot=0;
    for i = j:j+FreqStep-1        
        P_=(Pd1(i)+Pd1(i+1))*(f(i)+f(i+1))/2;
        Ptot=Ptot+P_;
    end  
    PowerDist(j:j+FreqStep)=Ptot/P1tot;
    Pperc=[Pperc,Ptot/P1tot];
end
Pperc=[Pperc,1-sum(Pperc)];
PowerDist(end-FreqStep:end)=Pperc(end);

end