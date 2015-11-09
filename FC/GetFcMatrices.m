function FC = GetFcMatrices(tc,winLength)

% Created 11/6/15 by DJ.

% get # of windows
[nParc,nT] = size(tc);
nWin = nT-winLength;

% get FC between them
fprintf('Getting sliding-window FC in %d windows...\n',nWin);
FC = nan(nParc,nParc,nWin);
for i=1:nWin
    fprintf('window %d/%d...\n',i,nWin)
    iInWin = (1:winLength) + i - 1;
    FC(:,:,i) = corr(tc(:,iInWin)');
end
fprintf('Done!\n')