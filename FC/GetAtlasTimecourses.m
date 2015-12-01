function tc = GetAtlasTimecourses(datafile, atlasfile, subbrick)

% Created 11/6/15 by DJ.

% load atlas
fprintf('Loading atlas...\n');
Opt = struct('Frames',subbrick);
[err,atlas,atlasInfo,ErrMsg] = BrikLoad(atlasfile,Opt);

% load data
fprintf('Loading data...\n');
[err,data,dataInfo,ErrMsg] = BrikLoad(datafile);

% reshape data
fprintf('Reshaping data...\n');
sizeData = size(data);
nVoxels = prod(sizeData(1:3));
nT = sizeData(4);
data2d = reshape(data,nVoxels,nT);
atlasvec = atlas(:);

% get tc in each atlas parcellation
fprintf('Extracting timecourses...\n');
nParc = max(atlas(:));
tc = nan(nParc,nT);
for i=1:nParc
    tc(i,:) = mean(data2d(atlasvec==i,:),1);
end

fprintf('Done!\n')
