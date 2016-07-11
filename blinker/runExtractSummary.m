
%% VEP setup
% experiment = 'vep';
% blinkDir = 'O:\ARL_Data\VEP\VEPBlinks';

%% Consolidate BCIT statistics
%type = 'ChannelUnref';
type = 'EOGUnref';
experiment = 'BCITLevel0';
blinkDir = 'O:\ARL_Data\BCITBlinks';
excludeTasks ={};
%blinkDir = 'K:\BCITBlinks';
%experiment = 'Experiment X2 Traffic Complexity';
% experiment = 'Experiment X6 Speed Control';
% experiment = 'X3 Baseline Guard Duty';
% experiment = 'X4 Advanced Guard Duty';
% experiment = 'X1 Baseline RSVP';
% experiment = 'Experiment XC Calibration Driving';
% experiment = 'Experiment XB Baseline Driving';
% experiment = 'X2 RSVP Expertise';

%% NCTU
% type = 'Channel';
% blinkDir = 'O:\ARL_Data\NCTU\NCTU_Blinks';
% experiment = 'NCTU_LK';
% excludeTasks = {};

% %% UMICH LSIE
% %type = 'Channel';
% type = 'IC';
% collectionType = 'FILES';
% experiment = 'LSIE_UM';
% blinkDir = 'E:\CTAData\LSIE_UM_Blinks';

%% Shooter
% type = 'ChannelUnref';
% %type = 'EOGUnref';
% collectionType = 'FILES2';
% experiment = 'Shooter';
% blinkDir = 'O:\ARL_Data\Shooter\ShooterBlinks';
% excludeTasks = {'EC', 'EO'};

%% BCI2000
% type = 'Channel';
% experiment = 'BCI2000';
% blinkDir = 'O:\ARL_Data\BCI2000\BCI2000Blinks';
% excludeTasks = {'EyesOpen', 'EyesClosed'};

%% Set up the files for the collection
blinkFile = [experiment 'BlinksNew' type '.mat'];
blinkPropertiesFile = [experiment 'BlinksNewProperties' type '.mat'];
blinkSummaryFile = [experiment 'BlinksNewSummary' type '.mat'];
    
%% Read in the blink data for this collection
load([blinkDir filesep blinkFile]);
load([blinkDir filesep blinkPropertiesFile]);

%% Compute the total number of blinks
dataStarts = zeros(length(blinks), 1);
dataEnds = zeros(length(blinks), 1);
dataNames = cell(length(blinks), 1);
totalBlinks = 0;
datasetMask = false(length(blinks), 1);
for n = 1:length(blinks)
    dataNames{n} = blinks(n).fileName;
    if isempty(blinks(n).usedComponent) || isnan(blinks(n).usedComponent)
       warning('%d: [%s] does not have blinks\n', n, blinks(n).fileName);
       continue; 
    elseif strcmpi(excludeTasks, blinks(n).task)
       continue;
    end
    blinkIndex = find(blinks(n).componentIndices == blinks(n).usedComponent, ...
                    1, 'first');
    blinkPositions = blinks(n).blinkPositions{blinkIndex};
    dataStarts(n) = totalBlinks + 1;
    dataEnds(n) = dataStarts(n) + size(blinkPositions, 2) - 1;
    totalBlinks = totalBlinks + size(blinkPositions, 2);
    datasetMask(n) = 1;
end
fprintf('Experiment %s has %d blinks\n', experiment, totalBlinks);

%% Remove the datasets that are excluded or failed in blink detection
blinks = blinks(datasetMask);
blinkFits = blinkFits(datasetMask);
blinkProperties = blinkProperties(datasetMask);
dataStarts = dataStarts(datasetMask);
dataEnds = dataEnds(datasetMask);

%% Plot the statistics
[dataHeaders, d] = getSummaryHeaders();
bData = zeros(totalBlinks, length(dataHeaders));

files = cell(length(dataHeaders), 1);
for n = 1:length(blinks)
    theseFits = blinkFits{n};
    theseProperties = blinkProperties{n};
    thisData = zeros(length(theseFits), length(dataHeaders));
    badBlinkMask = getBadBlinks(theseFits, theseProperties);
    thisData(:, d.BADMASK) = badBlinkMask(:)';
    %% Consolidate the times
    srate = blinks(n).srate;
    leftBase = cellfun(@double, {theseFits.leftBase});
    thisData(:, d.LEFTBASE) = (leftBase - 1)./srate;
    leftZero = cellfun(@double,{theseFits.leftZero});
    thisData(:, d.LEFTZERO) = (leftZero - 1)./srate;
  
    maxFrame = cellfun(@double,{theseFits.maxFrame});
    thisData(:, d.MAXTIME) = (maxFrame - 1)./srate;

    rightBase = cellfun(@double,{theseFits.rightBase});
    thisData(:, d.RIGHTBASE) = (rightBase - 1)./srate;
    rightZero = cellfun(@double,{theseFits.rightZero});
    thisData(:, d.RIGHTZERO) = (rightZero - 1)./srate;
   
    %% Consolidate duration measurements
    durationTent = cellfun(@double, {theseProperties.durationTent});
    durationZero = cellfun(@double,{theseProperties.durationZero});
    durationBase = cellfun(@double,{theseProperties.durationBase});
    durationHalfBase = cellfun(@double,{theseProperties.durationHalfBase});
    durationHalfZero = cellfun(@double,{theseProperties.durationHalfZero});
    thisData(:, d.DURZERO) = durationZero(:);
    thisData(:, d.DURBASE) = durationBase(:);
    thisData(:, d.DURTENT) = durationTent(:);
    thisData(:, d.DURHALFBASE) = durationHalfBase(:);
    thisData(:, d.DURHALFZERO) = durationHalfZero(:);
    
    %% Consolidate amplitude velocity ratios
    pAVRZero = cellfun(@double,{theseProperties.posAmpVelRatioZero});
    pAVRTent = cellfun(@double,{theseProperties.posAmpVelRatioTent});
    pAVRBase = cellfun(@double,{theseProperties.posAmpVelRatioBase});
    nAVRZero = cellfun(@double,{theseProperties.negAmpVelRatioZero});
    nAVRTent = cellfun(@double,{theseProperties.negAmpVelRatioTent});
    nAVRBase = cellfun(@double,{theseProperties.negAmpVelRatioBase});
    thisData(:, d.pAVRZERO) = pAVRZero(:);
    thisData(:, d.pAVRTENT) = pAVRTent(:);
    thisData(:, d.pAVRBASE) = pAVRBase(:);
    thisData(:, d.nAVRZERO) = nAVRZero(:);
    thisData(:, d.nAVRTENT) = nAVRTent(:);
    thisData(:, d.nAVRBASE) = nAVRBase(:);
    endData = dataStarts(n) + length(theseProperties) - 1;
    bData(dataStarts(n):endData, :) = thisData;
end

%% Create the blink structure
blinkSummary = ...
    struct('collection', [], 'fileNames', [], 'headers', [], 'data', [], 'dataStarts', []);
blinkSummary.collection = experiment;
blinkSummary.fileNames = dataNames;
blinkSummary.headers = dataHeaders;
blinkSummary.data = bData;
blinkSummary.dataStarts = dataStarts;
blinkSummary.dataEnds = dataEnds;

%% Save the data
save([blinkDir filesep blinkSummaryFile], 'blinkSummary', '-v7.3');