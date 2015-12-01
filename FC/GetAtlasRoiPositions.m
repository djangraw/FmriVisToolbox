function roiPos = GetAtlasRoiPositions(atlasfile,subbrick)

% Created 11/24/15 by DJ.

if ischar(atlasfile)
% load atlas
    fprintf('Loading atlas...\n');
    Opt = struct('Frames',subbrick);
    [err,atlas,atlasInfo,ErrMsg] = BrikLoad(atlasfile,Opt);
else
    atlas = atlasfile; % atlas brick is first input
end


% Get ROIs
nROIs = numel(unique(atlas(atlas~=0)));

roiPos = nan(nROIs,3);
for i=1:nROIs
    [r,c,v] = ind2sub(size(atlas),find(atlas == i));
    roiPos(i,:) = [mean(r),mean(c),mean(v)];
end
    