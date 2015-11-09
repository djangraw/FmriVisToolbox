% SaveOutMovieSpeed_script.m
%
% Created 6/3/15 by DJ.

%% Load results
load('Big_Buck_Bunny_420s_360p_clips.mat')
load('BigBuckBunny_avgSpeed_byClip.mat')

allSpeed = cat(1,avgSpeed{:});
allSpeed(isnan(allSpeed)) = 0; % nans show up during blackout (0 motion)
tClips = t(iClipStart);
dt = 1/frameRate;
tOrig = (1:length(allSpeed))*dt;
%% Plot results
subplot(3,1,1);
cla; hold on;
plot(tOrig,allSpeed);
hLines = PlotVerticalLines(tClips,'g:');
ylim([0 20])
xlabel('time (s)')
ylabel('Avg Speed (A.U.)');
title(movieFilename,'interpreter','none');
%% Compress with log transform
allSpeed_log = log(allSpeed+1);
upperCutoff = mean(allSpeed_log) + 3*std(allSpeed_log);
lowerCutoff = mean(allSpeed_log) - 3*std(allSpeed_log);
allSpeed_clipped = allSpeed_log;
allSpeed_clipped(allSpeed_clipped > upperCutoff) = upperCutoff;
allSpeed_clipped(allSpeed_clipped < lowerCutoff) = lowerCutoff;

%% Plot results
subplot(3,1,2);
cla; hold on;
plot(tOrig,allSpeed_clipped);
ylim([0 5])
hLines = PlotVerticalLines(tClips,'g:');
plot(get(gca,'xlim'),[0 0],'k-');
xlabel('time (s)')
ylabel('Log Avg Speed (A.U.)');

%% Convolve with HRF
isNewClip = zeros(size(allSpeed));
isNewClip(interp1(tOrig,1:numel(tOrig),tClips,'nearest')) = 1;

hrf = spm_hrf(dt);
allSpeed_hrf = conv(allSpeed_log,[zeros(size(hrf)); hrf],'full');
isNewClip_hrf = conv(isNewClip,[zeros(size(hrf)); hrf],'full');
tHrf = (1:length(allSpeed_hrf))*dt-(length(hrf)-1/2)*dt;

%% Resample to TR times
t0 = -2;
TR = 2;
nTR = 216;
tTR = (1:nTR)*TR+t0;
allSpeed_tr = interp1(tHrf,allSpeed_hrf,tTR,'linear','extrap');
isNewClip_tr = interp1(tHrf,isNewClip_hrf,tTR,'linear','extrap');

%% normalize
allSpeed_norm = (allSpeed_tr-nanmean(allSpeed_tr))/nanstd(allSpeed_tr);
isNewClip_norm = (isNewClip_tr-nanmean(isNewClip_tr))/nanstd(isNewClip_tr);

%% Plot results
subplot(3,1,3);
cla; hold on;
plot(tTR,[allSpeed_norm; isNewClip_norm]);
ylim([-5 5])
hLines = PlotVerticalLines(tClips,'g:');
plot(get(gca,'xlim'),[0 0],'k-');
legend('avg speed','new clip','new clip times')
xlabel('time (s)')
ylabel(sprintf('Avg Speed\n (HRF-convolved and normalized)'));
 
%% Save results
Info = struct('Prefix','AvgSpeedRegressor','Format','1D');
WriteBrik(allSpeed_norm,[],Info);
Info = struct('Prefix','NewClipRegressor','Format','1D');
WriteBrik(isNewClip_norm,[],Info);