function [tcClustered, iCluster, order]  = ClusterRois(tc,nClusters)

% Use k-means to find clusters of ROIs (based on their timecourses).
%
% [tcClustered, iCluster, order]  = ClusterRois(tc,nClusters)
%
% INPUTS:
% -tc is a nxt matrix containing the timecourse of activity in each ROI (as
% extracted, for example, using GetTimecourseInRoi.m.
% -nClusters is a scalar indicating the number of clusters you would like
% to extract.
%
% OUTPUTS:
% -tcClustered is the input matrix tc with the rows reordered so that
% clusters are near each other.
% -iCluster is an n-element vector in which iCluster(i) is the number of
% the cluster to which ROI i belongs.
% -order is an n-element vector in which order(i) is the new index of rois
% in tcClustered. That is, tcClustered(i,:) = tc(order(i),:).
%
% Created 11/18/15 by DJ.


iCluster_orig = kmeans(tc',nClusters); % rows are points, cols are variables

[iCluster, order] = sort(iCluster_orig,'ascend'); % reorder to group clusters together
tcClustered = tc(order,:); % apply ordering to tc