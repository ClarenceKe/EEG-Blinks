% pop_blinks() - Runs BLINKER for a single EEG dataset.
%
% Usage:
%   >>   [OUTEEG, blinks, blinkFits, blinkProperties, params, com] = ...
%                                pop_blinks(INEEG, params);
%
% Inputs:
%   INEEG      input EEG dataset
%   params     structure with parameters to override defaults
%
% Outputs:
%   OUTEEG     output EEG dataset
%   blinks     blink structure with positions
%   blinkFits  blinkFit structure with shape information about blinks
%   blinkProperties  blinkProperties structure with ocular index values
%   params     structure of parameters actually used
%   com        command string which produced this execution
%
% See also:
%    EEGLAB

% Copyright (C) 2016  Kay Robbins and Kelly Kleifgas, UTSA
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEG, com, blinks, blinkFits, blinkProperties, params] = ...
                                                 pop_blinker(EEG, params)
     com = ''; % Return something if user presses the cancel button
     okay = true;
     blinks = [];
     blinkFits = [];
     blinkProperties = [];
     if nargin < 1
         help(mfilename);
         return;
     elseif isempty(EEG.data)
         warndlg2('The EEG file must be loaded first', ...
             [mfilename '(): Dataset is empty!'])
         return
     elseif size(EEG.data, 3) > 1 % data is epoched
         warndlg2('Blinker requires continuous (unepoched) EEG data', ...
             [mfilename '(): Dataset is epoched!'])
         return
     elseif nargin < 2
         [params, okay] = dlg_blinker(getBlinkerDefaults(EEG));
     end

     %% Return if user pressed cancel or if bad parameters
     if (~okay)
         return;
     end

     %% Extract the blinks
     [blinks, params] = extractBlinksEEG(EEG, params);
     
     %% Finalize the blinks structure
     blinks.fileName = [EEG.filepath EEG.filename];
     blinks.experiment = params.experiment;
     blinks.subjectID = params.subjectID;
     blinks.uniqueName = params.uniqueName;
     blinks.task = params.task;
     blinks.fileName = params.fileName;
     startTime = '';
     try
         startTime = [params.startDate ' ' params.startTime];
         blinks.startTime = datenum(startTime, -1);
     catch Mex
         warning('pop_blinker:BadStartTime', ...
             '%s has invalid start time (%s), using NaN [%s]\n', ...
             blinks.fileName, startTime, Mex.message);
     end

     if isempty(blinks.status)
         blinks.status = 'success';
     end
     if isempty(blinks.usedSignal) || isnan(blinks.usedSignal)
         warning('pop_blinker:NoBlinks', ...
                '%s does not have blinks\n', blinks.fileName);
         return;
     end
     signalNumbers = cellfun(@double, {blinks.signalData.signalNumber});
     signalIndex = find(signalNumbers == abs(blinks.usedSignal), 1, 'first');
     signalData = blinks.signalData(signalIndex);
     
     %% Calculate the blink properties
     [blinkProperties, blinkFits] = extractBlinkProperties(signalData, params);

     try
         if params.dumpBlinkerStructures
             thePath = fileparts(params.blinkerSaveFile);
             if ~exist(thePath, 'dir')
                 mkdir(thePath);
             end
             save(params.blinkerSaveFile, 'blinks', 'blinkFits', ...
                 'blinkProperties', 'params', '-v7.3');
         end
     catch Mex
         fprintf('pop_blinker:SaveStructureError %s\n', Mex.message');
     end
     try
         if params.showMaxDistribution
             showMaxDistribution(blinks, blinkFits);
         end
     catch Mex
         fprintf('pop_blinker:SaveDistributionError %s\n', Mex.message');
     end
     try
         if params.dumpBlinkImages
             traceName = blinks.signalData(signalIndex).signalLabel;
             blinkTrace = blinks.signalData(signalIndex).signal;
             dumpIndividualBlinks(blinks, blinkFits, blinkTrace, ...
                 traceName, params.blinkerDumpDir, params.correlationThresholdTop);
         end
     catch Mex
         fprintf('pop_blinks:SaveDumpImagesError %s\n', Mex.message');
     end
     try
         if params.dumpBlinkPositions
             fileOut = [params.blinkerDumpDir filesep blinks.uniqueName 'leftZeros.txt'];
             dumpDatasetLeftZeros(fileOut, blinkFits, blinks.srate)
         end
     catch Mex
         fprintf('pop_blinks:SaveDumpImagesError %s\n', Mex.message');
     end
     com = sprintf('pop_blinker(%s, %s);', inputname(1), struct2str(params));
end % pop_blinks