function [mrs, hdr] = readTwixData(fp, removeOS)
% Loads the twix dat-file and returns mri/mrs data with proper labels per
% dimension.
%
% Quincy van Houtum. v05.2025
% quincyvanhoutum@gmail.com

if nargin == 1, removeOS = 0; end

% Twix-loading
twix = mapVBVD(fp);

% Header
hdr = twix.hdr;

% Filename
hdr.filepath = fp;

% Read data dimension and labels
dims = num2cell(twix.image.dataSize);
dims_rng = cellfun(@(x) 1:x, dims,'uniform', 0); % Range

% Dimension labels from header
dims_txt = twix.image.dataDims;
dims_txt = dims_txt(twix.image.dataSize>1);

% --- Correct data labels from twix-file.

% Labels in dat-file
labels_dat_file      = ...
    {'col', 'cha', 'lin', 'par', 'seg', 'ave', 'set', 'phs'}; 
% Library for understandable index-labels: matched in order with 
% "labels_dat_file".
labels_match_library = ...
    {'fid', 'chan', 'ky', 'kz', 'kx', 'aver', 'aver', 'kz'};    
dims_txt_corrected = cell(1,size(dims_txt,2));
for ti = 1:size(dims_txt,2)        
    ind = strcmpi(labels_dat_file, dims_txt{ti});
    if sum(ind) > 0, dims_txt_corrected{ti} = labels_match_library{ind};
    else, dims_txt_corrected{ti} = dims_txt{ti};
    end
end
hdr.labels = dims_txt_corrected;

% --- MRS data

if removeOS
    twix.image.flagRemoveOS = 1; 
    dims_rng{1} = 1:numel(dims_rng{1})/2;    
end

% MRS-data
mrs = squeeze(twix.image(dims_rng{:}));

% --- Clean up

% Free up memory
clear('twix')

% Close file ID
fclose('all');