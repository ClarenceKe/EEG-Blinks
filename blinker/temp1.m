% %% temp
% %fighan = showMaxDistribution(blinks, blinkFits, params);
% 
% 
% %%
% % signalData = blinks.signalData(3);
% % blinkFits = fitBlinks(signalData.signal, signalData.blinkPositions);
% % 
% % %%
% % signalData = blinks.signalData(3);
% % blinkPositions = signalData.blinkPositions;
% % startBlinks = blinkPositions(1, :);
% % endBlinks = blinkPositions(2, :);
% % x = startBlinks(2:end) - endBlinks(1:end-1);
% % x = x/1024;
% % y = find(x <= 0.05);
% 
% %%
% % signalData = blinks.signalData;
% % blinkPositions = signalData.blinkPositions(:, 30:34);
% % figure
% % plot(signalData.signal(blinkPositions(1, 1):blinkPositions(2, 5)));
% % 
% % %%
% a = fitBlinks(signalData.signal, blinkPositions);
% % 
% % [blinkProps, blinkFits] = extractBlinkProperties(signalData, params)
% % [a, b] = blinkFit(signalData, blinkPositions);
% % [blinkProps, blinkFits] = extractBlinkProperties(signalData, params);

%%
% params = struct();
% [EEG, com, blinks, blinkFits, blinkProperties, params] = ...
%                                                  pop_blinker(EEG, params);

%%
% blinkStatistics = getBlinkStatistics(blinks, blinkFits, blinkProperties);
% blinkStatistis.blinkFileName = 'temp';

%%
outputBlinkStatistics(1, blinkStatistics);

 