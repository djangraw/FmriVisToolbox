function PlotConnectivityOnCircle(atlas,nClusters,FC,threshold)

% Plot the ROIs, colored according to their cluster, around the unit
% circle. Then plot arcs connecting functionally connected ROIs.
% Clicking on any outside marker will show its ROI, and clicking on an arc
% will show the two ROIs that it connects.
%
% PlotConnectivityOnCircle(atlas,nClusters,FC,threshold)
% PlotConnectivityOnCircle(atlas,idx,FC,threshold)
%
% INPUTS:
% -atlas is a 3d matrix in which each voxel has a value according to its
% ROI (1:n). Voxels with value 0 are considered outside the brain.
% -nClusters is a scalar indicating the number of clusters that the atlas
% should be grouped into (using ClusterRoisSpatially.m). [default = no
% clustering]. OR... 
% -idx is an n-element vector of the cluster to which each roi belongs.
% [default = 1:n]
% -groupClusters is a binary value indicating whether ROIs in the same
% cluster should be plotted together around the circle instead of according
% to their x,y position. [default = true]
% -marker is a string indicating the marker you'd like to use to plot the
% positions (see 'help plot' for options). [default = '-']
%
% OUTPUTS:
% -roiPos_circle is an nx2 matrix where each row is the (x,y) position of
% that ROI on the circle.
% -h is an m-element vector of handles to each of the plotted clusters,
% where m=max(idx).
%
% Created 11/24/15 by DJ.
% Updated 11/30/15 by DJ - allow idx input, default nClusters.

% Set defaults
if ~exist('threshold','var') || isempty(threshold)
    threshold = 0;
end
if isempty(nClusters)
    nClusters = max(atlas(:));
    idx = 1:nClusters;
elseif numel(nClusters)==1
    % Get clusters
    idx = ClusterRoisSpatially(atlas,nClusters);
else
    idx = nClusters;
end
% name clusters
cluster_names = cell(nClusters*2,1);
sides= 'RL';
for i=1:2
    for j=1:nClusters
        cluster_names{(i-1)*nClusters+j} = sprintf('%s cluster %d',sides(i),j);
    end
end
% cluster_names = {'R Brainstem','R Subcortical','R Cerebellum','R Limbic','R Occipital','R Temporal','R Parietal','R Insula','R Motor','R Prefrontal',...
%     'L Brainstem','L Subcortical','L Cerebellum','L Limbic','L Occipital','L Temporal','L Parietal','L Insula','L Motor','L Prefrontal'};
% Plot positions
roiPos_circle = PlotRoisOnCircle(atlas,idx,true,cluster_names);

% Put FC on scale where max(abs(FC))-->3 and abs(threshold)-->0
FCnorm = zeros(size(FC));
FCnorm(FC>threshold) = (FC(FC>threshold)-threshold)/(max(abs(FC(:)))-threshold)*3;
FCnorm(FC<-threshold) = (FC(FC<-threshold)+threshold)/(max(abs(FC(:)))-threshold)*3;

% Plot arcs between positions
h = nan(size(FC));
for i=1:size(FC,1)
    for j=(i+1):size(FC,2);
        % Find midpoint on the circle to use as center of arc
        cart_mid = mean(roiPos_circle([i j],:),1);
        theta_mid = cart2pol(cart_mid(1),cart_mid(2));
        [x_mid,y_mid] = pol2cart(theta_mid,1.2);
        % Draw the arc        
        if FCnorm(i,j)>0
            h(i,j) = DrawArc([x_mid;y_mid], roiPos_circle(i,:)', roiPos_circle(j,:)');
            set(h(i,j),'color','r','linewidth', FCnorm(i,j));
            set(h(i,j),'ButtonDownFcn',{@ShowRois,i,j})
        elseif FCnorm(i,j)<0
            h(i,j) = DrawArc([x_mid;y_mid], roiPos_circle(i,:)', roiPos_circle(j,:)');
            set(h(i,j),'color','b','linewidth', -FCnorm(i,j));
            set(h(i,j),'ButtonDownFcn',{@ShowRois,i,j})
        end
        
    end
end

set(gca,'xtick',[],'ytick',[])

% ROI plot function
function ShowRois(hObject,eventdata,iRoi,jRoi)     
    
    % Create atlas for vis
    atlasR = atlas;
    for k=1:max(atlas(:))
        atlasR(atlas==k) = idx(k)/(max(idx)*2);
    end
    % Create green overlay  
    atlasG = atlasR;
    atlasG(atlas==iRoi) = 1;
    % Create blue overlay
    atlasB = atlasR;
    atlasB(atlas==jRoi) = 1;   
    % Get position
    roiPos = GetAtlasRoiPositions(atlas);
    % Plot result
    GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iRoi,:)));
end

end