function memri = memri_pca_denoising(memri, varargin)
% Apply principle component analysis denoising following the Marchenko
% Pastur distribution.
%
%
% Accepts memri data-struct generated via the memri-processing toolbox.
% OR?
%
%
% Opts: mask size, svd method
%
% Quincy van Houtum, v02.2026
% quincyvanhoutum@gmail.com
%
%                          UNDER CONSTRUCTION
%

% Process input
% Matlab' svd-econ = 0, custom faster = 1 (svd-econ)
patch_size = 5; do_svd = 1; svdstr = 'custom';
if nargin > 1
    indp = cellfun(@(x) strcmp(x, 'patchsize'), varargin);
    if sum(indp), patch_size = varargin{indp+1}; end

    inds = cellfun(@(x) strcmp(x, 'svd'), varargin);
    if sum(inds), do_svd = varargin{inds+1}; 
        if do_svd == 0, svdstr = 'default'; end
    end    
end

% Reshape data % ---------------------------------------------------- %

% Cell-ify to: {nS x Kx x Ky x Kz x nChan} x Other
[data, labels, pvec, ncell] = array2cell(memri.data, memri.labels, ...
    {'fid', 'kx', 'ky', 'kz', 'chan'});
sz_cell = size(data);
chan_ind = 5; % Channel dimension forced at index-5

% Reshape to cell-list
data = reshape(data,[],1);

% Number of volumes to PCA-denoise (fid x kx x ky x kz x nchan) x nVolumes.
% nVolumes is therefor product of possible other extra dimensions
nVolumes = size(data,1);

% PCA Denoising % --------------------------------------------------- %

% % NFO update for user
memri_log(memri, 'PCA: Applying PCA-denoising. Patch size:', patch_size);
memri_log(memri, ['PCA: SVD-Method, ' svdstr]);

% Principle Component Analysis - Denoising
dt = 0;
for vi = 1:nVolumes
    tic
    data{vi} = ...
        csi_pca_denoising(data{vi}, chan_ind, patch_size, do_svd);
    dt = dt + toc;
end

% Processing-time output
memri_log(memri, 'PCA: Denoising applied. Duration (s):', dt );
fprintf('%f\n', dt);

% Revert Reshape % --------------------------------------------------- %

% Undo cell array to list
data = reshape(data, sz_cell);

% Undo array to cell
[memri.data, memri.labels] = cell2array(data, labels, pvec, ncell);

