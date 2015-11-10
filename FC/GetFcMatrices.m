function FC = GetFcMatrices(tc,winLength)

% Construct functional connectivity matrices using the sliding window
% correlation method.
%
% FC = GetFcMatrices(tc,winLength)
%
% INPUTS:
% -tc is a nxt matrix containing the timecourse of activity in each ROI (as
% extracted, for example, using GetTimecourseInRoi.m.
% -winLength is a scalar indicating the width of the window to use for
% correlation (in samples).
%
% OUTPUTS:
% -FC is an nxnx(t-winLength) matrix in which FC(i,j,k) is the functional
% connectivity between ROI i and ROI j in the window containing times
% k-1+(1:winLength). 
% 
% Created 11/6/15 by DJ.
% Updated 11/10/15 by DJ - comments.

% get # of windows
[nParc,nT] = size(tc);
nWin = nT-winLength;

% get FC between them
fprintf('Getting sliding-window FC in %d windows...\n',nWin);
FC = nan(nParc,nParc,nWin);
for i=1:nWin
    fprintf('window %d/%d...\n',i,nWin)
    iInWin = (1:winLength) + i - 1; % indices in window
    FC(:,:,i) = corr(tc(:,iInWin)'); % find corellation between all ROIs at once
end
fprintf('Done!\n')