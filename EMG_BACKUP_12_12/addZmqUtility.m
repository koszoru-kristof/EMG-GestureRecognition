% --------------------------------------------------------------
%
%   Add path to class used for managing ZMQ paradigm from matlab
%       - Publisher
%       - Subscriver
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

function [  ] = addZmqUtility(  )
filename = which(mfilename);
[pathstr,~,~] = fileparts(filename);

zmq_paradigm = {'subscriber','publisher'};

for i=1:numel(zmq_paradigm)
    addpath([pathstr,'\',zmq_paradigm{i}]);   
end;

end

