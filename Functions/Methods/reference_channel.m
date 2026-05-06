function refChannel = reference_channel(fid)
% Find the coil channel with the most signal and return the corresponding
% channel index.
%
% This function simply checks for the maximum absolute value of the fid or 
% spectrum for every voxel and every channel and returns the latter its 
% index.
%
% Input
% fid       cell-array with complex data representing a spectrum or fid
%           i.e. {fid x chan} x M x N x P ... etc.
%
% Quincy van Houtum Phd, v09.2025
% quincyvanhoutum@gmail.com

% Real values
fid_abs = cellfun(@abs, fid, 'UniformOutput', false);

% Maximum per channel per voxel
mx_val_perchan_pervox = cellfun(@max, fid_abs, 'UniformOutput', false);

% Maximum value per voxel with its channel-number
[mx_val_pervox, mx_val_pervox_chanind] = ...
    cellfun(@max, mx_val_perchan_pervox, 'UniformOutput', false);

% Maximum from all voxels with its voxel-number
[~, mx_val_voi] = max(cell2mat(mx_val_pervox));

% Reference channel
% Thus: max(fid_real{mx_val_voi}(:,refChannel)) == mx_val
refChannel = mx_val_pervox_chanind{mx_val_voi};