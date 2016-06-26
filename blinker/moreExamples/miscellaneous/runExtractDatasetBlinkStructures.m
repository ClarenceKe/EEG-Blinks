%% This extracts blink information for an individual file
%          
%% NCTU blinks
% blinkDir = 'O:\ARL_Data\NCTU\NCTU_Blinks';
% experiment = 'NCTU_LK';
% %type = 'IC';
% type = 'Channel';
% excludeTasks = {};
%% BCIT Examples
% datasetList = [51, 52, 63, 81, 87, 130];
% datasetList = [89, 102, 159, 160];  
% datasetNames = {'T2_M053_S2018_XB', 'T2_M067_S2023_XC',  ...
%             'T2_M126_S2043_XC', 'T2_M128_S2043_X6'};
datasetList = [59, 73, 97];  
datasetNames = {'T2_M022_S2008_XC', 'T2_M037_S2013_XC', 'T2_M061_S2021_XC'};

%% BCIT other examples
experiment = 'BCITLevel0';
blinkDir = 'O:\ARL_Data\BCITBlinks';
%type = 'EOGUnref';
type = 'ChannelUnref';
outputDir = 'O:\ARL_Data\BCITBlinkOutput\data';

%% Read in the blink data for this collection
blinkFile = [experiment 'BlinksNew' type '.mat'];
load([blinkDir filesep blinkFile]);

%%
blinkPropertiesFile = [experiment 'BlinksNewProperties' type '.mat'];
load([blinkDir filesep blinkPropertiesFile]);

%% Save the extracted blink datasets
for k = 1:length(datasetList)
    thisNum = datasetList(k);
    dBlinks = blinks(thisNum);
    dFits = blinkFits(thisNum);
    dProperties = blinkProperties(thisNum);
    uniqueName = dBlinks.uniqueName;
    theName = [experiment 'DatasetBlinks' type uniqueName '.mat'];
    outName = [outputDir filesep theName];
    save(outName, 'dBlinks', 'dFits', 'dProperties', '-v7.3');
end