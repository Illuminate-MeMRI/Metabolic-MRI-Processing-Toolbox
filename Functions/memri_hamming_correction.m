function [data, win_acq, win_hamming, corr_mask] = memri_hamming_correction(data, ind_spat, ind_aver)
% Return data corrected for the imperfect hamming window acquisition
% pattern of the finite mrs volume.
% 
% Input
%   data:           complex ND matrix representing raw 2D or 3D k-space 
%                   data and includes averages on index "ind_aver" and 
%                   the spatial dimensions on indexes "ind_spat".
%   ind_spat:       list of the spatial dimension indexes in data.
%   ind_aver:       integer for the averages-dimension index in data i.e.
%                   the dimension containing an acquisition pattern by
%                   summation (see memri_acquisitionPattern.m).
%
% Output
%   data:           data mutliplied by the correction mask.                  
%   win_hamming:    ideal hamming window for data array spatial dimensions.
%   win_acq:        calculated (hamming) acquisition pattern in data
%   corr_mask:      ratio between the ideal hamming window and acquisition
%                   window.
%
% Adapted from acquisitionpatterncheck.m // auteur unknown.
%
% Requirements: acquistionPattern.m, window1D.m, window3D.m
%
% Quincy van Houtum, v12.2025
% quincyvanhoutum@gmail.com

% // --- Calculate acquisition and hamming window

% Get acquisition pattern (window)
win_acq = memri_acquisitionPattern(data, ind_aver);

% Calculate Hamming correction mask via acquisition pattern
sz = size(data, ind_spat); if size(sz) < 3, sz(3) = 1; end
win_hamming = window3D(window1D(sz(1), 'hamming', 'periodic'),...
                       window1D(sz(2), 'hamming', 'periodic'),...
                       window1D(sz(3), 'hamming', 'periodic'));

% Normalise the hamming window to minimizes amplitude reduction due to the 
% normalized acquistion pattern.
win_hamming = win_hamming./(max(win_hamming, [], 'all'));

% // --- Match indexing
% Match win_ham indexing with spatial dimension indexes of data

% #dimensions hamming window and data arrays
ndimsw = ndims(win_hamming); ndimsd = ndims(data); 
% Permute vector
pvec = NaN(1, ndims(data));  pvec(ind_spat) = 1:ndimsw;  
pvec(isnan(pvec)) = ndimsw+1:ndimsd;      
% Permute
win_hamming = permute(win_hamming, pvec); 

% // --- Calculate correction mask
corr_mask = bsxfun(@rdivide, win_hamming, win_acq); % hamming ./ acq. win.
corr_mask(~isfinite(corr_mask)) = 0; % Remove inf values (./0)

% // --- Apply correction mask
data = bsxfun(@times, data, corr_mask); % data .* correction mask
