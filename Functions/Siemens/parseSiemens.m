function memri = parseSiemens(fp)
% memri = parseSiemens(fp)
%
% Example filepath input fp: 
%       ({'C:\data\CSI.dat', 'C:\data\GE_MS.ima', ...
%         'noise', 'C:\data\noise.dat'});
%
% Parse Siemens raw data export .dat-files for MR spectroscopy and convert 
% to a generalized data-structure, matching parsePhilips.
%
% Also accepts Siemens dicom data as ima-files. Extension IMA in the 
% filename is required.
%
% Corrections:
%           Orientation corrections for proper display        
%           - the kx-dimension is shifted by exactly 1 voxel by multiplying
%             k-space by a linear phaseroll.
%           - the ky- and kz-dimension are flipped.
%
%           OPTIONAL NOISE-FILE INPUT:
%           Using the tag 'noise' followed by the filepath to an MRS data 
%           file (.dat) parses that file as noise-input. 
%               Example:
%               Input fp = {'D:\csi.dat', 'noise', 'D:\noise.data'};
%
% ... used by memri_loadData();
%
% Quincy van Houtum, v02.2026
% quincyvanhoutum@gmail.com


% // --- Noise Tag
ind_noise = find(strcmp(fp, 'noise'));
if ~isempty(ind_noise), fp(ind_noise) = []; end

% // --- Safety check
if ~iscell(fp), fp = {fp}; end
[~, ~, ext] = cellfun(@fileparts, fp, 'UniformOutput', false);


% // --- Load all files into MATLAB-memory
for kk = 1:numel(ext)
    fprintf('\nparseSiemens: loading file \n\t%s\n', fp{kk});
    switch lower(ext{kk})
        case '.dat'
            if isempty(ind_noise) || (kk ~= ind_noise)
                [data_mrs, nfo_mrs] = readTwixData(fp{kk}); % Data
            else
                [data_nse, nfo_nse] = readTwixData(fp{kk}); % Noise
            end
        case '.ima'
            [ima_files, ima_fp] = dicomreadSiemens_getSeries(fp{kk});
            [data_img, nfo_img] = dicomreadSiemens(ima_fp, ima_files);
    end
end

% // --- Parse MRS header info
nfo = twix_parseNFO(nfo_mrs);


% // --- Memri Struct
% DATA
memri.data = data_mrs; 
memri.labels = nfo_mrs.labels; memri.nfo = nfo;


% NOISE
if exist('data_nse', 'var')
   memri.noise.data = data_nse;
   memri.noise.labels = nfo_nse.labels;
   memri.noise.domain = 1;
end

% Miscellaneous
memri.source.files = fp; memri.source.header = nfo_mrs;

% // --- Siemens .dat-file corrections

% Spatial corrections to k-space
ind_spat   = findLabels(memri.labels, {'kx', 'ky', 'kz'});

% Raw DAT-file CSI data requires voxelshift
if ~isnan(ind_spat(1))    
    memri.data = memri_voxelshift(memri.data, [1 0 0], ind_spat, 1);
end

% CSI DAT-file data always requires a flip of kz and ky dimensions
if ~isnan(ind_spat(2))
    memri.data = flip(conj(memri.data), ind_spat(2)); % Flip Ky
end
if ~isnan(ind_spat(3))
    memri.data = flip(conj(memri.data), ind_spat(3)); % Flip Kz
end


% // --- Optional DICOM
if exist('data_img', 'var')
    memri.images.data = data_img; memri.images.nfo = nfo_img;
   
end

