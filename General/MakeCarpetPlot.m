function MakeCarpetPlot(filename,maskName,Opt,normalize)

% MakeCarpetPlot(filename,maskName,Opt,normalize)
%
% INPUTS:
% -filename is a string indicating the AFNI file you'd like to plot.
% -maskName is a string indicating the AFNI file you'd like to use as a
% mask (only the non-zero voxels in the mask will be plotted).
% -Opt is a struct that can be used as an input to BrikLoad - for example,
% to load a subset of subbricks in the file.
% -normalize is a binary value indicating whether you'd like to normalize
% each voxel to be mean 0 and std dev 1. [default: false]
%
% Created 11/3/15 by DJ.

if ~exist('Opts','var') || isempty(Opt)
    Opt = struct();
end
if ~exist('normalize','var') || isempty(normalize)
    normalize=false;
end

if iscell(filename)
    nFiles = numel(filename);
    for i=1:nFiles
        fprintf('===File %d/%d===\n',i,nFiles)
        h(i)=subplot(nFiles,1,i); cla;
        MakeCarpetPlot(filename{i},maskName,Opt,normalize);
    end
    linkaxes(h);
    return
end

Opt = struct();
fprintf('Loading %s...\n',filename);
[err, V, Info, ErrMessage] = BrikLoad (filename, Opt);
fprintf('Loading Mask %s...\n',maskName);
[err_mask, V_mask, Info_mask, ErrMessage_mask] = BrikLoad (maskName,struct('Frames',1));


sizeV = size(V);
Vvec = reshape(V,prod(sizeV(1:3)),sizeV(4));
if normalize
%     fprintf('De-meaning...\n')    
%     Vvec = (Vvec-repmat(mean(Vvec,2),1,size(Vvec,2)));%./repmat(std(Vvec,[],2),1,size(Vvec,2));
    fprintf('Normalizing...\n')    
    meanV = mean(Vvec,2);
    stdV = std(Vvec,[],2);
    for i=1:size(Vvec,1)
        Vvec(i,:) = (Vvec(i,:) - meanV(i))/stdV(i);
    end
end
    
    fprintf('Plotting...\n')
imagesc(Vvec(V_mask(:)~=0,:));
xlabel('time (TR)');
ylabel('voxel');
title(filename,'Interpreter','None');
colorbar
colormap gray
fprintf('Done!\n')
