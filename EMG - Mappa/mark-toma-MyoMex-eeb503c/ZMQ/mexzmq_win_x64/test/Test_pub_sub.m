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

topic = 'Hello';
ip    ='tcp://127.0.0.1:6655';

[pub,ok] = Publisher(ip);
if not(ok)
  errormsg('Publisher not initialized correctly');
end

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
while(i<4)
   fprintf('Publish: World\n');
   bool = pub.publish(topic, 'World'); 
   pause(1);
   fprintf('Getting Data\n');
   [new, data] = sub.getData(); 
   if new
      fprintf('%d) %s\n', i, data);       
   end
    i = i +1;
   pause(1);
end

sub.stop();

clear pub sub;

