% DISC GUI -> DISCO
% Authors: David S. White  & Owen Rafferty
% contact: dwhite7@wisc.edu

% Updates:
% ---------
% 2019-04-07    DSW    v1.0.0
% 2019-04-10    DSW    v1.1.0
%
%--------------------------------------------------------------------------
% Overview:
% ---------
% This program is a graphical front end for the time series idealization 
% algorithm 'DISC' by David S. White.
% Requires MATLAB Statistics and Machine Learning Toolbox
% see src/DISC/runDISC.m for more details. 
%
% Input Variables:
% ----------------
% data = structure to be analyzed. Requires: 
%   data.time_series = observed time series. 
%
% References:
% -----------
% White et al., 2019, (in preparation)

% demo

if ~exist('data', 'var')
    data = loadData();
end

% check if previous operation cancelled to avoid error msg
if isempty(data)
    disp('Action Aborted.')
    clear data;
    return
end

data = initFieldsDISC(data);

% init GUI
discGUI(data);
