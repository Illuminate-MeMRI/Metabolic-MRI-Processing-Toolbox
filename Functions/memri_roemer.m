function memri = memri_roemer(memri, varargin)
% Combine multi-dimentional multi-coil-channel MRS data using Roemer method
% aiming for optimal SNR. Will convert the data (if necessary) to the 
% time-domain before coil combination is applied, and returns data in the 
% initial domain. K-space is NOT supported (see memri_fft_spatial).
%
% This function is based on the method described in:
%              Roemer et al, 10.1002/mrm.1910160203 
%
% Input
%   memri:        memri-struct created and used by the memri-ptb with the
%                 data in memri.data and the sub-struct noise containing 
%                 the noise (cov)ariance matrix or matrices.
%                 Use memri_noise() to generate a noise-covariance matrix
%                 before calling this function, or use the identity matrix
%                 (see below).
% 
% (Optional)
%   noisecov      use the noise-covariance matrix (1, default) or the 
%                 identity-matrix (0). Example: ...,'noisecov', 1);
% 
% Output
%   memri         updated memri-struct compatible with memri-ptb. 
% 
%
% Requires: memri_fft(), sensitivity_map(), roemer().
%
% sensemap(data) - or memri_fieldmap
% spatial time or frequency domain data


% // --- Handle input arguments and set options
opts.noisecov = 1;
if nargin > 1
    for vi = 1:2:numel(varargin), opts.(varargin{vi}) = varargin{vi+1}; end
end

% Given input arguments are overruled by options in the memri-struct.
if isfield(memri.nfo, 'roemer') && isfield(memri.nfo.roemer, 'identity_matrix')
    if memri.nfo.roemer.identity_matrix, opts.noisecov = 0;
    else, memri.nfo.roemer.identity_matrix, opts.noisecov = 1;
    end
end

% // --- Parse input data
% Check array size, channel index, noise-covariance matrix and data domain.

% Data dimensions and channel Index
sz = arrayfun(@(x) size(memri.data,x), 1:numel(memri.labels));
chan_ind = findLabels(memri.labels,{'chan'});

% Noise covariance matrix or ID-matrix
if ~opts.noisecov
    nchan = size(memri.data, chan_ind); noisecov = diag(ones(nchan,1));
    memri_log('Roemer: Using identity matrix.');
else
    noisecov = memri.noise.cov;    
end

% Data domain: spatial FID (1).
doFFT = 0; if memri.nfo.domain == 2, memri = memri_ifft(memri); doFFT = 1; end


% // --- Required input maps
% Convert data to cell array, calculate fieldmaps i.e. sensitivity maps.

% Data to cellarray 
[fid, labels, pvec, ncell] = ...
    array2cell(memri.data, memri.labels, {'fid', 'chan'});

% Sensitivity map
senseMap = sensitivity_map(fid);


% // --- Apply ROEMER method
if isscalar(noisecov)
    fid = cellfun(@(x,y) roemer(x,y,noisecov{:}), fid, senseMap, ...
        'UniformOutput',false);
else % For noise-cov per voxel
    fid = cellfun(@(x,y,z) roemer(x,y,z), fid, senseMap, noisecov,...
        'UniformOutput',false);
end


% // --- Post processing and output
[memri.data, memri.labels] = cell2array(fid, labels, pvec, ncell);
memri.noise.sensitivityMap = senseMap;


% FFT to original input domain
if doFFT, memri = memri_fft(memri); end



