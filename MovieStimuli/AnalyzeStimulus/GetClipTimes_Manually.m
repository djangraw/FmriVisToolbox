% GetClipTimes_Manually
%
% Created 5/14/15 by DJ.
cd /Users/jangrawdc/Documents/Python/multimedia
foo = load('Big_Buck_Bunny_420s_360p_luminance.mat');
iClipStart = find(abs(diff(foo.lum))>10)+1;
% adjust: add by hand
iClipStart = [iClipStart, 711, 2086, 2156, 2218, 3981, 4562, 4834, 5383,...
    5483, 5563, 5643, 6348, 6465, 6655, 6801, 6868, 6916, 7340, 8335, ...
    8848, 9336, 9723];
% adjust: subtract by hand
iClipStart = setdiff(iClipStart,[3720, 3724, 3956, 3959:3963, 4688, ...
    4690, 5286, 5885, 5904, 6475:6479, 6649, 6654, 7207:7210, 7341:7343, ...
    7346, 8962:8963, 9353, 9867, 9869, 9896, 9903, 9924, 9926, 9929:9930]);
iClipStart(foo.t(iClipStart)>420) = [];
%% Check just before & after specific time
iFrame = 8960;%interp1(foo.t,1:length(foo.t),406.1,'nearest');
figure(4); clf;
frames = GetMovieFrames(movieFilename,foo.t(iFrame+(-2:2)));
for i=1:5
    subplot(1,5,i);
    image(frames(:,:,:,i)/255);
    title(sprintf('frame %d',iFrame+i-3));
end

%% Check each iClipStart
isOk = nan(1,numel(iClipStart));
for i=1:numel(iClipStart)
    iFrames = iClipStart(i)+(-2:2);
    frames = GetMovieFrames(movieFilename,foo.t(iFrames));
    for j=1:numel(iFrames)
        if mod(i,2)==1
            subplot(2,numel(iFrames),j);
        else
            subplot(2,numel(iFrames),numel(iFrames)+j);
        end
        image(frames(:,:,:,j)/255);
        title(sprintf('frame %d',iFrames(j)));
    end
    reply = input('Ok? Y/N [Y]:','s');
    if isempty(reply) || reply=='Y'
        isOk(i) = true;
    elseif reply=='N'
        isOk(i) = false;
    end
        
end

%% Save results
t = foo.t;
save Big_Buck_Bunny_420s_360p_clips movieFilename iClipStart t