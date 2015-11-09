function [U,S,V,FCtc] = PlotFcPca(FC,nPcsToPlot,demeanFC)

% Created 11/6/15 by DJ.

if demeanFC
    fprintf('De-meaning FC...\n')
    meanFC = mean(FC,3);
    FC = FC - repmat(meanFC,1,1,size(FC,3));
end

fprintf('Assembling vector...\n')
nT = size(FC,3);
nFC = numel(nonzeros(triu(FC(:,:,1),1)));
FCvec = nan(nT,nFC);
for i=1:nT
    FCvec(i,:) = nonzeros(triu(FC(:,:,i),1))';
end

fprintf('Running SVD...\n')
[U,S,V] = svd(FCvec);
Snorm = diag(S)/sum(diag(S));

% plot singular values
fprintf('Plotting singular values...\n')
figure(111); clf;
plot(Snorm);
xlabel('principal component index')
ylabel('singular value')

%% get timecourses
fprintf('Getting timecourses...\n')
FCtc = V'*FCvec';

%% plot results
fprintf('Plotting timecourse...\n')
figure(112); clf;
uppertri = tril(ones(size(FC,1)),-1);
upperV = zeros(size(FC,1));
for i=1:nPcsToPlot
    subplot(nPcsToPlot,2,2*i-1);
    upperV(uppertri==1) = V(:,i); 
    imagesc(upperV);
    ylabel(sprintf('PC #%d: SV=%.3g',i,Snorm(i)));
    axis square
    colorbar;
    
    subplot(nPcsToPlot,2,2*i); hold on
    plot(FCtc(i,:));
    xlabel('time of window start (samples)')
    ylabel('activation')
    grid on
    plot([0 0],get(gca,'ylim'),'k-');
end