function memri = memri_loadData(fp, varargin)
% [data, nfo] = memri_loadData(fp)
%
% Main function utilizing Siemens and Philips specific function to load raw
% MRS data and convert it for use with the MeMRI processing pipeline. 
%             --- Raw MRS data converter for MeMRI PP ---
%
% Input
%   fp:     cell-list with filepaths to MRS data files, parameter files and
%           optional matching MR images.
%
%           Supported filetypes: Siemens - '.dat', 
%                                Philips - '.list', '.data', '.txt',        
%                                Both    - '.dcm', 'ima'. (MR images ONLY)
%           [Excluded for beta release (Philips): '.spar', '.sdat']
%
%           IMPORTANT REQUIREMENTS: 
%           List./.data files must have equal filenames.
%           List./.data files require additional protocol txt-file.
%                   If this text-file is not provided, assumes equal
%                   filename to .list/.data files. The user is prompted
%                   for input if the protocol text-file is not found. See
%                   below for required parameters.
%           Dicom image data must match the MRS data volume and TBD.           
%           
%           OPTIONAL NOISE-FILE INPUT:
%           Using the tag 'noise' followed by the filepath to an MRS data 
%           file (.data or .list or .dat) parses that file as noise-input. 
%           Input fp = {'D:\csi.dat', 'noise', 'D:\noise.data'};
%               
%   varargin:
%           boolean to save memri-struct to file automatically (1, default)
%           or only return the output (0).
%
% Output
%   memri:  Struct containing the following fields
%           .data
%           .nfo
%           .labels
%           .domain     spatial frequency domain; k-space (0), spatial
%                       domain; FID (1) sprectral or frequency 
%                       domain; Spectrum (2).
%           .noise      .data\.nfo\.labels\.domain
%           .images
%           .sources    .files\.header
%           .filepath
%
% // --- Corrections applied to the raw MRS data
%   Siemens
%       CSI data: 
%           Orientation corrections for proper display        
%           - the kx-dimension is shifted by exactly 1 voxel by multiplying
%             k-space by a linear phaseroll.
%           - the ky- and kz-dimension are flipped.
%
%   Philips
%       None [for now]
%
%
% // --- Required protocol parameters for spectroscopy data
% Nucleus (-), field-strength (T), bandwidth (Hz), resolution (mm) OR 
% field-of-view (mm), offcenter (mm), orientation (string: tra/sag/cor).
% Future option: angulation?
%
% Uses: parseSiemens.m and parsePhilips.m
%
%
% Quincy van Houtum. v01.2026
% quincyvanhoutum@gmail.com


if nargin == 0
    % UI for file selection of MeMRI data: raw data + txt-header nfo
    [fn, fp, idx] = uigetfile(...
        {'*.dat;*.list;*.data;*.txt;*.ima;*.dcm','Compatible files'; ...
        '*.dat', 'Siemens data'; ...
        '*.list;*.data;*.sdat;*.spar','Philips data'; ...
        '*.txt','Protocol info (Philips)'}, 'Select MeMRI-data...',...
        'MultiSelect','on');
    if idx == 0, return; end
    
    % Combine filepath and name
    if ~iscell(fn), fn = {fn}; end
    fp = cellfun(@(x,y) [fp x], fn, 'UniformOutput', false);
end
% Save file boolean input
if nargin < 2, saveFile = 1; else, saveFile = varargin{1}; end

% Cell-ify
if ~iscell(fp), fp = {fp}; end


% // --- parse according to Siemens or Philips file-standards


% Analyse filepaths extension
[~, ~, ext] = cellfun(@fileparts, fp, 'UniformOutput', false);

isDatFile = sum(strcmp(ext, '.dat'));
if isDatFile
    memri = parseSiemens(fp);
else
    memri = parsePhilips(fp);
end


% // --- Save memri-struct to file
if saveFile
    
    % Store the memri-struct at file-location with same name as mrs-data.
    [fp, fn, ext] = cellfun(@fileparts, memri.source.files,...
        'UniformOutput', false);
    
    % Main filename
    ind = ismember(ext, {'.dat', '.data'}); ind = find(ind,1, 'first');
    memri.filepath = strcat(fp{ind},'\', fn{ind}, '.mat');

    try
        % Save data to file.
        save(memri.filepath, 'memri', '-v7'); % Faster
    catch err
        fprintf('%s\n', err.message);
        fprintf('Saving mat-file using v7.3. Can be time-consuming.');
        % Save data to file.
        save(memri.filepath, 'memri', '-v7.3'); % Can be very slow
    end

end
