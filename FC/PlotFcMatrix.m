function [FC_ordered,order,idx_ordered] = PlotFcMatrix(FC,clim,atlas,nClusters)

% [FC_ordered,order,idx_ordered] = PlotFcMatrix(FC,clim,atlas,nClusters)
%
% INPUTS:
% 
% OUTPUTS:
%
% Created 12/23/15 by DJ.

if ~exist('nClusters','var') || isempty(nClusters) || isequal(nClusters,0)
    showClusters = false;
elseif numel(nClusters)==1 
    idx = ClusterRoisSpatially(atlas,nClusters);
    showClusters = true;
else
    idx = nClusters;
    nClusters = numel(unique(idx));
    showClusters = true;
end
if ~exist('clim','var') || isempty(clim);
    clim = [GetValueAtPercentile(FC(:),2), GetValueAtPercentile(FC(:),98)];
end

% reorder FC matrix
if showClusters
    [idx_ordered,order] = sort(idx,'ascend');
    FC_ordered = FC(order,order);
else
    FC_ordered = FC;
    order = 1:size(FC,1);
    idx_ordered = ones(size(order));
end

% plot FC
cla; hold on;
hImg = imagesc(FC_ordered);
set(hImg,'ButtonDownFcn',@ShowFcRow);
% add cluster rectangles
if showClusters
    iClusters = unique(idx_ordered);
    nClusters = numel(iClusters);
    colors = distinguishable_colors(nClusters);
    iClusterEdge = [1; find(diff(idx_ordered)>0); numel(idx_ordered)];
    hGridVert = PlotVerticalLines(iClusterEdge,'k');
    hGridHori = PlotHorizontalLines(iClusterEdge,'k');
    for i=1:nClusters        
        hRect(i) = rectangle('position',[iClusterEdge(i), iClusterEdge(i), iClusterEdge(i+1)-iClusterEdge(i),iClusterEdge(i+1)-iClusterEdge(i)],...
            'edgecolor',colors(i,:),'linewidth',2);
        set(hRect(i),'ButtonDownFcn',{@ShowCluster,i});    
    end
    set([hGridVert,hGridHori],'ButtonDownFcn',@ShowFcRow);    
end
% annotate plot
set(gca,'ydir','reverse','clim',clim)
xlim([0.5 size(FC_ordered,1)+0.5]);
ylim([0.5 size(FC_ordered,2)+0.5]);
xlabel('ROI');
ylabel('ROI');
axis square
colorbar;   

% ROI plot function
function ShowCluster(hObject,eventdata,iCluster)     
    
    % Create atlas for vis
    atlasIdx = MapValuesOntoAtlas(atlas,idx);
    atlasR = atlasIdx/(nanmax(idx)*2);
    % Create green overlay  
    atlasG = atlasR;
    atlasG(atlasIdx==iCluster) = 1;
    % Create blue overlay
    atlasB = atlasR;    
    % Get position
    roiPos = GetAtlasRoiPositions(atlasIdx);
    % Plot result
    GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iCluster,:)));
end

% ROI plot function
function ShowFcRow(hObject,eventdata)     
    
    % get row
    hObject = gca;%get(objHandle,'Parent');
    coords = get(hObject,'CurrentPoint');
    coords = coords(1,1:2);
    iRow = round(coords(2));
    iRow = max(0,min(iRow,size(FC_ordered,1)));
    % get reordered atlas
    invOrder = zeros(size(order));
    for k=1:numel(order)
        invOrder(k) = find(order==k);
    end
    atlas_ordered = MapValuesOntoAtlas(atlas,invOrder);
    % get overlay
    overlay = FC_ordered(iRow,:);
    overlay(overlay<clim(1)) = clim(1); % clip at color limits
    overlay(overlay>clim(2)) = clim(2); % clip at color limits
    overlay = overlay/max(abs(clim));
    % Create atlas for vis
    atlasScaled = atlas_ordered/(nanmax(atlas_ordered(:))*2);
    % Create red overlay    
    atlasR = MapValuesOntoAtlas(atlas_ordered,overlay.*(overlay>0));
    % create green overlay
    atlasG = atlasScaled;
    atlasG(atlas_ordered==iRow) = 1;
    % Create blue overlay
    atlasB = MapValuesOntoAtlas(atlas_ordered,-overlay.*(overlay<0));
    % Get position
    roiPos = GetAtlasRoiPositions(atlas_ordered);
    % Plot result
    GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iRow,:)));
    fprintf('displaying connectivity with ROI %d\n',iRow);
end
end