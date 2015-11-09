% MotionCalculation_script
%
% Created 5/13/15 by DJ.

movieFilename = 'Big_Buck_Bunny_420s_360p.mp4';
tStart = 245;
tEnd = 247;
outFile = 'MovieTest.mat';

[mov, frameRate] = GetMovie(movieFilename,tStart,tEnd);
save(outFile,'mov','frameRate');

%%

[avgSpeed, speed] = motion5multiscale(outFile);

figure(10);
for i=1:12
    iFrame = i*4;
    subplot(2,12,i);
    image(mov(iFrame).cdata);
    title(sprintf('frame %d',iFrame))
    subplot(2,12,12+i);
    image(speed(:,:,iFrame));
    title(sprintf('frame %d',iFrame))
    colormap gray
end

%% chunk up entire movie

movieFilename = 'Big_Buck_Bunny_420s_360p.mp4';
tMovie = 420;
tStep = 20;
tStartVec = 0:tStep:tMovie-1;
nChunks = length(tStartVec);
outFile = cell(1,nChunks);

for i=1:nChunks
    tStart = tStartVec(i);
    tEnd = tStart+tStep;
    outFile{i} = sprintf('BigBuckBunny_%dto%d.mat',tStart,tEnd);

    if ~exist(outFile{i},'file')
        fprintf('Getting block %d/%d...\n',i,length(tStartVec));
        [mov, frameRate] = GetMovie(movieFilename,tStart,tEnd);
        save(outFile{i},'mov','frameRate');    
    end
end


%% OR Chunk up Clip by Clip
movieFilename = 'Big_Buck_Bunny_420s_360p.mp4';
foo = load('Big_Buck_Bunny_420s_360p_clips.mat');
tMovie = 420;
tStartVec = [0 foo.t(foo.iClipStart)];
tEndVec = [foo.t(foo.iClipStart) tMovie];
nChunks = length(tStartVec);
outFile = cell(1,nChunks);

for i=1:nChunks
    tStart = tStartVec(i);
    tEnd = tEndVec(i);
    outFile{i} = sprintf('BigBuckBunny_clip%d.mat',i);

    if ~exist(outFile{i},'file')
        fprintf('Getting block %d/%d...\n',i,nChunks);
        [mov, frameRate] = GetMovie(movieFilename,tStart,tEnd);
        save(outFile{i},'mov','frameRate');    
    end
end




%%
avgSpeed = cell(1,nChunks);
for i=1:nChunks
    fprintf('Calculating motion...\n');
    [avgSpeed{i}, speed] = motion5multiscale(outFile{i});
%     drawnow;
end

%% get avg speed throughout entire movie
figure(197); clf;
avgSpeedAll = cat(1,avgSpeed{:});
dt = 1/frameRate;
t = dt*(1:numel(avgSpeedAll));
plot(t,avgSpeedAll);
xlabel('time (s)');
ylabel('Avg Speed');
title(movieFilename,'interpreter','none');
% add clip times
foo = load('Big_Buck_Bunny_420s_360p_clips.mat');
hold on;
hLines = PlotVerticalLines(foo.t(foo.iClipStart),'g:');

%% save results
speedFilename = 'BigBuckBunny_avgSpeed_byClip.mat';
save(speedFilename,'avgSpeed','outFile','movieFilename','frameRate');
%% find peaks and plot
diffSpeed = diff(avgSpeedAll);
peaks = find(diffSpeed(1:end-1)>0 & diffSpeed(2:end)<=0 & avgSpeedAll(2:end-1)>5)+1;
figure(197); clf;
cla; hold on;
plot(t,avgSpeedAll);
hStars = plot(t(peaks),avgSpeedAll(peaks),'r*');
hLines = PlotVerticalLines(foo.t(foo.iClipStart),'g:');
legend('avg Speed','Peaks','Clips');
xlabel('Time (s)')
ylabel('Speed (A.U.)')
title(movieFilename,'interpreter','none');
% PlotFramesAboveTimes(movieFilename,t(peaks),gca,0.01);
%%
figure(199); clf;
nToPlot = 8;
iStart = 10;
iPeaks = iStart-1+(1:nToPlot);
frames = GetMovieFrames(movieFilename,[t(peaks(iPeaks)-1), t(peaks(iPeaks)), t(peaks(iPeaks)+1)]);

for i=1:nToPlot    
    subplot(3,nToPlot,i);
    image(frames(:,:,:,i)/255);
    subplot(3,nToPlot,nToPlot+i);
    image(frames(:,:,:,nToPlot+i)/255);
    subplot(3,nToPlot,nToPlot*2+i);
    image(frames(:,:,:,nToPlot*2+i)/255);
end


