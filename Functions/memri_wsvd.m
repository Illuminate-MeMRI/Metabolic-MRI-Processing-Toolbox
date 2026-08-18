function memri = memri_wsvd(memri, varargin)
% Combine multi-channel MRS data using the WSVD algorithm.
%
% List of required memri fields here
% memri.noise with fields data, labels and domain. Use memri_noise() prior
% if the substructure is absent.
%
% Available options for WSVD
%   reference_channel:  use first coil-index (0, default) as the reference 
%                       channel for amplitude scaling, calculate a
%                       reference channel per voxel (1) or for the volume
%                       (2). reference_channel() is used for both options.
%                       example: ...,'reference_channel', 2);
%   method:             Whitening (1, default), Cholesky (2), ZCA (3)
%                       None (0, no whitening). See WSVD3().
%   identity_matrix:    use identity matrix instead of noise-covariance 
%                       matrix for decorrelation       
%
% Uses WSVD3()
%
% Quincy van Houtum PhD, v01.2026
% quincyvanhoutum@gmail.com

% // --- Parse input and options
opts = struct; opts.method = 1; opts.reference_channel = 0;
if nargin > 1
    for vi = 1:2:numel(varargin), opts.(varargin{vi}) = varargin{vi+1}; end
end


% Given input methods are overruled by options in the memri-struct.
if isfield(memri.nfo, 'wsvd') && isfield(memri.nfo.wsvd, 'identity_matrix')
    if memri.nfo.wsvd.identity_matrix, opts.noisecov = 0;
    else, memri.nfo.wsvd.identity_matrix, opts.noisecov = 1;
    end
    memri_log(memri, 'memri_wsvd: Using identity matrix.');
end

% Create data cell-array: {fid x nchan} x ...
[data, labels, pvec, ncell] = ...
    array2cell(memri.data,  memri.labels, {'fid', 'chan'});    


% // --- Reference channel
if opts.reference_channel == 2 % Volume
    opts.reference_channel = reference_channel(data);
    memri_log(memri, 'memri_wsvd: Reference channel by volume maximum.');
elseif opts.reference_channel == 1 % Per Voxel
    opts.reference_channel = num2cell(cellfun(@(x) ...
        reference_channel({x}), data));
    memri_log(memri, 'memri_wsvd: Reference channel per voxel maximum.');
elseif opts.reference_channel == 0 
    memri_log(memri, 'memri_wsvd: First index used as reference channel.');
    opts.reference_channel = 1;
end

% // --- Combine channels via WSVD
% Different calls for compatibility with all noise covariance and reference
% channel per voxel or volume combinations.
if numel(memri.noise.cov) > 1                                               % Noise-cov per voxel
    memri = memri_log(memri, 'memri_wsvd: parsed noise covariance matrices per voxel.');

    if isscalar(opts.reference_channel)                                         % refChan for volume
        data = cellfun(@(x,y) WSVD3(x, y, opts.method, opts.reference_channel),...
            data, memri.noise.cov, 'UniformOutput', false);
    else                                                                        % refChan per voxel
        data = cellfun(@(x,y,z) WSVD3(x, y, opts.method, z),...
            data, memri.noise.cov, opts.reference_channel, 'UniformOutput', false);
    end

else                                                                        % Noise-cov for volume
    memri = memri_log(memri, 'memri_wsvd: parsed a single noise covariance matrix.');

    if isscalar(opts.reference_channel)                                        % refChan for volume 
        data = cellfun(@(x) ...
            WSVD3(x, memri.noise.cov{1}, opts.method, opts.reference_channel), ...
            data, 'UniformOutput', false);
    else                                                                       % refChan per voxel
        data = cellfun(@(x,y) WSVD3(x, memri.noise.cov{1}, opts.method, y),...
            data, opts.reference_channel, 'UniformOutput', false);
    end
end

% // --- Set output & LOG

% Store used options
memri.nfo.wsvd.opts = opts;

% Rever to initial array type and size
[memri.data, memri.labels] = cell2array(data, labels, pvec, ncell);

% LOG
memri = memri_log(memri, 'memri_wsvd: Combined coil channels using WSVD.');

