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

[pub,ok] = Publisher(ip);
if not(ok)
  errormsg('Publisher not initialized correctly');
end

pause(1);
i= 0;
while(1)
   %msg = ['World' num2str(i)];
   
   %msg = [num2str(i)];
   
   msg = input('write msg:','s');
   if (strcmp(msg,''))
       break;
   end
   
   fprintf(['Publish: ' msg ' \n']);
   bool = pub.publish(topic, msg); 
   pause(1);
   i = i+1;
end

clear pub;

