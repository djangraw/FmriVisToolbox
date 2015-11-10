function MakeCarpetPlot(filename,maskName,Opt,normalize)

% Draw a 'Carpet Plot' that shows the activity in every voxel over time.
%
% MakeCarpetPlot(filename,maskName,Opt,normalize)
%
% INPUTS:
% -filename is a string indicating the AFNI file you'd like to plot, or a
% matrix of the data itself, or a cell array of strings/matrices you'd like
% to plot in seperate subplots.
% -maskName is a string indicating the AFNI file you'd like to use as a
% mask (only the non-zero voxels in the mask will be plotted), or a matrix
% of the same size as the 'filename' input.
% -Opt is a struct that can be used as an input to BrikLoad - for example,
% to load a subset of subbricks in the file.
% -normalize is a binary value indicating whether you'd like to normalize
% each voxel to be mean 0 and std dev 1. [default: false]
%
% Created 11/3/15 by DJ.
% Updated 11/10/15 by DJ - added matrix input option, comments.

% Handle inputs
if ~exist('Opts','var') || isempty(Opt)
    Opt = struct();
end
if ~exist('normalize','var') || isempty(normalize)
    normalize=false;
end

% Call recursively if more than one filename is given
if iscell(filename)
    nFiles = numel(filename);
    for i=1:nFiles
        fprintf('===File %d/%d===\n',i,nFiles)
        h(i)=subplot(nFiles,1,i); cla;
        MakeCarpetPlot(filename{i},maskName,Opt,normalize);
    end
    % Link all the axis limits together
    linkaxes(h);
    return
    
% Get the data brick
elseif ischar(filename)
    % Load the file
    fprintf('Loading %s...\n',filename);
    [err, V, Info, ErrMessage] = BrikLoad (filename, Opt);
else
    % the input is a matrix
    V = filename;
    filename = 'Matrix given as input';
end

% Get the mask
if ischar(maskName)
    % Load the mask (just the first frame)
    fprintf('Loading Mask %s...\n',maskName);
    [err_mask, V_mask, Info_mask, ErrMessage_mask] = BrikLoad (maskName,struct('Frames',1));
else
    V_mask = maskName;
%     maskName = 'Mask given as input';
end

% Convert the masked 4d matrix to a 2d matrix
sizeV = size(V);
Vvec = reshape(V,prod(sizeV(1:3)),sizeV(4));
% Normalize to mean 0 and stddev 1
if normalize
    fprintf('Normalizing...\n')    
    meanV = mean(Vvec,2);
    stdV = std(Vvec,[],2);
    % Loop is faster than repmat due to memory constraints
    for i=1:size(Vvec,1)
        Vvec(i,:) = (Vvec(i,:) - meanV(i))/stdV(i);
    end
end

% Plot results
fprintf('Plotting...\n')
imagesc(Vvec(V_mask(:)~=0,:));
% Annotate plot
xlabel('time (TR)');
ylabel('voxel');
title(filename,'Interpreter','None');
colorbar
colormap gray

fprintf('Done!\n')
