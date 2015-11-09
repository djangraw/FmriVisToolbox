function PlotVideoLuminance(lum,t)

% PlotVideoLuminance(lum,t)
% 
% INPUTS:
% - lum is an n-element vector of the luminance in each movie frame.
% - t is an n-element vector of the corresponding times.
%
% Created 4/1/15 by DJ.
% Updated 4/21/15 by DJ.

iClipStart = find(abs(diff(lum))>10)+1;

dt = median(diff(t));
% smooth by convolving with an HRF
hrf = spm_hrf(dt);
smoothLum = conv(lum,[zeros(size(hrf)); hrf],'same');
% smoothLum = SmoothData(lum,2/dt,'full');
% Plot results
cla; hold on;
plot(t,[lum;smoothLum]);
PlotVerticalLines(t(iClipStart),'g:');
% Annotate plot
xlabel('time (s)');
ylabel('luminance from RGB (A.U.)');
legend('raw','convolved with HRF','new clip');
% legend('raw','smoothed (Gaussian, sigma=2s)')
% title(movieFilename,'Interpreter','none');
title('Luminance of movie');
