function memri = memri_fft_spatial(memri)
% Return the inverse FFT of a complex multidimensional volume over the 
% spatial indexes in "dim". Expects data in memri.data and requires
% memri.labels to find the correct spatial indexes querying kx, ky and kz.
%
% Input
%   memri:          struct with fields data and labels. The labels describe
%                   the dimensions in data.
%
% Output
%   memri.data:     inverse fourier transform of the data in memri.data
%
% Method
%   First inverse fftshift each spatial dimension before inverse FFT, 
%   followed by forward fftshift.
%   
% Miscellaneous
% Expects the zero-frequency of k-space at position (1,1,1)
% i.e. a shift of the zero-frequency to center is required.
% 
% Quincy van Houtum, v2025.12
% Contact: quincyvanhoutum@gmail.com 

% Required input
spat_ind = findLabels(memri.labels, {'kx', 'ky', 'kz'});

% Spatial forward fourier transform
memri.data = fft_spatial(memri.data, spat_ind);
memri.nfo.domain = 1; % Time domain

% LOG
memri = memri_log(memri, 'memri_fft_spatial: Applied FFT to k-space data.');