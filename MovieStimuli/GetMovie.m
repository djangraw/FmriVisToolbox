function [mov, frameRate] = GetMovie(movieFilename,tStart,tEnd)

% [mov, frameRate] = GetMovie(movieFilename,tStart,tEnd)
% [mov, frameRate] = GetMovie(movObj,tStart,tEnd)
%
% INPUTS:
% -movieFilename is a string indicating the filename of a movie in the
% current path.
% -tStart and tEnd are scalars indicating the desired start and end time in
% the movie.
% -movObj is a movie object loaded with VideoReader.
%
% OUTPUTS:
% -mov is a vector of structs with 3D field cdata, one for each frame.
% -frameRate is a scalar indicating the number of frames per second.
%
% Created 4/28/15 by DJ.
% Updated 5/14/15 by DJ - allow movObj input

if ischar(movieFilename)
    fprintf('Loading movie...\n');
    movObj = VideoReader(movieFilename);
else
    movObj = movieFilename;
end
% get sie
vidWidth = movObj.Width;
vidHeight = movObj.Height;
frameRate = movObj.FrameRate;

% edit times
if tStart<0
    fprintf('tStart was <0... changing to 0.\n');
    tStart = 0;
end
if tEnd>movObj.Duration
    fprintf('tEnd was > duration of movie... changing to %f.\n',movObj.Duration);
    tEnd = movObj.Duration;
end

% Create a movie structure array, mov.
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);

% Read one frame at a time until the end of the video is reached.
set(movObj,'CurrentTime',tStart);
k = 1;
fprintf('Getting ~%d frames...\n',(tEnd-tStart)*movObj.FrameRate)
while movObj.CurrentTime<tEnd && hasFrame(movObj)
    if mod(k,100)==0
        fprintf('%d\n',k);
    else
        fprintf('.');
    end
    mov(k).cdata = readFrame(movObj);
    k = k+1;
end
fprintf('\n')