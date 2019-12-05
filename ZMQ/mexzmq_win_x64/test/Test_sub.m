% --------------------------------------------------------------
%
% Istanciate one pulisher that publishes the message "World" with topic
% "Hello" and one subscriber to that publisher
%
% --------------------------------------------------------------
%======================================================================%
%                                                                      %
%  Autors: Paolo Bevilaqua                                             %
%          Valerio Magnago                                             %
%          University of Trento                                        %
%          paolo.bevilaqua@unitn.it                                    %
%          valerio.magnago@unitn.it                                    %
%                                                                      %
%======================================================================%

%% Init console
clear all;
close all;
path(pathdef);
clc;

% Add the path necessary for zmq
run ../addZmqUtility;

topic = '';
ip    ='tcp://127.0.0.1:5000';

[sub,ok] = Subscriber(ip,topic);
if not(ok)
  errormsg('Subscriber not initialized correctly');
end

ok = sub.start();
if not(ok)
  errormsg('Error while starting subscriber');
end

pause(1);
i= 0;
while(i<200)
   [new, data] = sub.getData(); 
   if new
      fprintf('\n%s\n', data);  
   else
      fprintf('.');
   end
   i = i +1;
   pause(0.1);
end

sub.stop();

clear sub;

