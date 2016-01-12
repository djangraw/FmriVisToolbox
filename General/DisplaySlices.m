function hAxes = DisplaySlices(dataBrick, dim, iSlices, whSubplots,clim)

% Created 12/22/15 by DJ.
nSubplots = numel(iSlices);
if ~exist('whSubplots','var') || isempty(whSubplots)   
    whSubplots = [ceil(sqrt(nSubplots)), ceil(nSubplots/ceil(sqrt(nSubplots)))];
end
if ~exist('clim','var') || isempty(clim)   
    clim = [GetValueAtPercentile(dataBrick(~isnan(dataBrick) & dataBrick~=0),2), GetValueAtPercentile(dataBrick(~isnan(dataBrick) & dataBrick>0),98)];
end

% extract slices and labels
if dim==1
    slices = permute(dataBrick(iSlices,:,:),[3 2 1]);
    xlbl = 'y';
    ylbl = 'z';
elseif dim==2    
    slices = permute(dataBrick(:,iSlices,:),[3 1 2]);
    xlbl = 'x';
    ylbl = 'z';
elseif dim==3
    slices = permute(dataBrick(:,:,iSlices),[2 1 3]);    
    xlbl = 'x';
    ylbl = 'y';
end
    
% plot
dimLabels = {'Sagittal','Coronal','Axial'};
clf;
for i=1:nSubplots
    hAxes(i) = subplot(whSubplots(1),whSubplots(2),i);
    imagesc(slices(:,:,i));
    % annotate plot
    set(gca,'ydir','normal','clim',clim);
    xlabel(xlbl);
    ylabel(ylbl);   
    title(sprintf('%s slice %d',dimLabels{dim},iSlices(i)));
    axis square
end
% make colorbar
hAxes(nSubplots+1) = axes('Position',[90 5 5 90]/100,'clim',clim,'visible','off');
colorbar;


