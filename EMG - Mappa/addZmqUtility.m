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

zmq_paradigm = {'ZMQ\mexzmq_win_x64\publisher',genpath('mark-toma-MyoMex-eeb503c')};

for i=1:numel(zmq_paradigm)
    addpath(zmq_paradigm{i});   
end;

end

