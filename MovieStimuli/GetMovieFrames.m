function [frames,true_times] = GetMovieFrames(movieFilename,times)

% Created 4/20/15 by DJ.
% Updated 4/27/15 by DJ - remove times outside allowable range.

movObj = VideoReader(movieFilename);
movSize = [movObj.Height, movObj.Width];

% crop times
iOkTimes = times>=0 & times<=movObj.Duration;
if sum(iOkTimes)<numel(times)
    fprintf('Cropped to %d allowable times.\n',sum(iOkTimes));
end
times = times(iOkTimes);

nTimes = numel(times);
frames = zeros([movSize,3,nTimes]);
true_times = zeros(size(times));
% set up
for i=1:nTimes
    set(movObj,'CurrentTime',times(i));
    fprintf('Getting frame %d/%d...\n',i,nTimes);
    true_times(i) = movObj.CurrentTime;
    frames(:,:,:,i) = readFrame(movObj);            
end
fprintf('DONE!\n')
