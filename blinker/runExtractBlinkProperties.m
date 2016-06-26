%% Run the blink statistics given
pop_editoptions('option_single', false, 'option_savetwofiles', false);
%type = 'IC';
%type = 'EOGUnref';
%type = 'Channel';

%% VEP setup
% experiment = 'vep';
% blinkDir = 'O:\ARL_Data\VEP\VEPBlinks';

%% Miscellaneous
% blinkDir = 'D:\Research\BlinkerLeftovers\VideoHTML';
% blinkFile = 'ARL_BCIT_T1_M051_S1026PREPICABlinks.mat';
% blinkStatsFiles = 'ARL_BCIT_T1_M051_S1026PREPICAStatsOut.mat';

% blinkDir = 'E:\CTAData\LSIE_UM_Blinks';
% blinkFile = 'LSIEBlinks.mat';
% blinkStatsFiles = 'LSIEStatsOut.mat';

%% BCIT Examples
collectionType = 'FILES';
experiment = 'BCITLevel0';
type = 'ChannelUnref';
%type = 'EOG';
%type = 'IC';
blinkDir = 'O:\ARL_Data\BCITBlinks';
%blinkDir = 'K:\BCITBlinks';
% experiment = 'Experiment X2 Traffic Complexity';
% experiment = 'Experiment X6 Speed Control';
% experiment = 'X3 Baseline Guard Duty';
% experiment = 'X4 Advanced Guard Duty';
% experiment = 'X1 Baseline RSVP';
% experiment = 'Experiment XC Calibration Driving';
% experiment = 'Experiment XB Baseline Driving';
% experiment = 'X2 RSVP Expertise';

%% VEP
% blinkDir = 'O:\ARL_Data\VEP\VEPBlinks';
% experiment = 'VEP';

%% NCTU
% blinkDir = 'O:\ARL_Data\NCTU\NCTU_Blinks';
% experiment = 'NCTU_LK';
% %type = 'IC';
% type = 'Channel';

%% Shooter
%type = 'ChannelUnref';
% type = 'EOGUnref';
% experiment = 'Shooter';
% blinkDir = 'O:\ARL_Data\Shooter\ShooterBlinks';

%% BCI2000
% type = 'Channel';
% experiment = 'BCI2000';
% blinkDir = 'O:\ARL_Data\BCI2000\BCI2000Blinks';

% %% UMICH LSIE
% organizationType = 'UM';
% type = 'ChannelUnref';
% undoReference = false;
% collectionType = 'FILES';
% experiment = 'LSIE_UM';
% blinkDir = 'E:\CTADATA\Michigan\EEG_blinks2';

% %% Dreams
% organizationType = 'Dreams';
% type = 'ChannelUnref';
% %type = 'EOGUnref';
% undoReference = false;
% collectionType = 'FILES';
% experiment = 'Dreams';
% pathName = 'E:\CTADATA\WholeNightDreams\data\level0';
% blinkDir = 'E:\CTADATA\WholeNightDreams\data\blinks';
% byType = 'EEG';
% %byType = 'EOG';

%% Update file names with the experiment
blinkFile = [experiment 'BlinksNew' type '.mat'];
blinkPropertiesFile = [experiment 'BlinksNewProperties' type '.mat'];

%% Set the base level
baseLevel = 0;

%% Load the data
load([blinkDir filesep blinkFile]);
blinkFits = cell(1, length(blinks));
blinkProperties = cell(1, length(blinks));

%% Fit the blinks
for n = 1:length(blinks)
    fprintf('Dataset %d:\n', n);
    dBlinks = blinks(n);
    if isempty(dBlinks.usedComponent) || isnan(dBlinks.usedComponent)
        warning('%d: [%s] does not have blinks\n', n, dBlinks.fileName);
        blinkProperties{n} = NaN;
        blinkFits{n} = NaN;
        continue;
    end
    blinkIndex = find(dBlinks.componentIndices == dBlinks.usedComponent, ...
        1, 'first');
    [blinkProperties{n}, blinkFits{n}] = extractBlinkProperties( ...
        dBlinks.blinkComponents(blinkIndex, :), ...
        dBlinks.blinkPositions{blinkIndex}, dBlinks.srate);
end

%% Save the property structures in a file
save([blinkDir filesep blinkPropertiesFile], 'blinkFits', 'blinkProperties', '-v7.3');