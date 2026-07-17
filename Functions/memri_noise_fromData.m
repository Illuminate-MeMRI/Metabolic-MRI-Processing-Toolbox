function memri = memri_noise_fromData(memri, masksize)
% Create noise-vectors per voxel in memri-data using spectral data itself.
% Using a double-sided noise-mask of 25% of the #samples i.e. 1/8th of
% #samples of both tails of the spectrum. Will overwrite any noise data or
% information already present in memri-struct!
%
% If the data is in k-space (nfo.domain = 0), or time-domain (nfo.domain =
% 1), the data will be FFT-ed to the frequency domain.
%
% Quincy van Houtum, PhD; v08.2025
% quincyvanhoutum@gmail.com

% // --- Create noise from data
% This requires data in the spatial frequency domain, automatic fft is
% applied if memri.data is in k-space or time domain.

% // --- Handle variable input arg
if nargin < 1, masksize = NaN; end

% #Samples
szd = size(memri.data); nS = szd(1);

% Masksize from input arg - NaN, use default size, char ('all') use full
% sample range.
if nargin == 1,  masksize = round(nS./4); end
if isnan(masksize), masksize = round(nS./4); end
if ischar(masksize), masksize = nS; end

% Double sided noise mask indexes
sz_mask_sided = [round(masksize./2) masksize-round(masksize./2)];
noise_mask = [1:sz_mask_sided(1) (nS - sz_mask_sided(2) + 1):nS];

% Check for time/freq domain and transform if needed
tmp_data = memri.data;
if memri.nfo.domain == 1, tmp_data = memri_fft(memri.data); end
if memri.nfo.domain == 0
    % Get k-space indexes
    ind_spat = findLabels(memri.labels, {'kx','ky','kz'});
    ind_spat(isnan(ind_spat)) = [];
    % FFT of k-space
    tmp_data = fft_spatial(memri.data, ind_spat);             
    tmp_data = fft(tmp_data);
end
% tmp_data is noise from the main data-set in the frequency domain.

% Calculate indexing for noise-mask data and get noise sample
cut_ind = arrayfun(@(x) 1:x, szd, 'UniformOutput', 0);
cut_ind{1} = noise_mask; memri.noise.data = tmp_data(cut_ind{:});
memri.noise.domain = 2; memri.noise.labels = memri.labels;

% LOG noise creation
% memri_log(something something);
