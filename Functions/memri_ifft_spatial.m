function memri = memri_ifft_spatial(memri)
% Return the inverse FFT over the spatial indexes of a multidimensional 
% volume i.e. k-space to spatial (time-) domain.
%
% Input
%   memri:  memri-struct with a multidimensional array (memri.data) with 
%           spatial dimension at indexes described in memri.labels.
%
% Output
%   memri:  input struct with the inverse fourier transform of memri.data.
%
% Method
%   First inverse fftshift each spatial dimension before inverse FFT and 
%   followed by a forward fftshift.
%   
% Miscellaneous
% See ifft_spatial() for more details.
%
% Quincy van Houtum, v2025.12
% Contact: quincyvanhoutum@gmail.com 

% Required input
spat_ind = findLabels(memri.labels, {'kx', 'ky', 'kz'});

% Spatial forward fourier transform
memri.data = ifft_spatial(memri.data, spat_ind);
memri.nfo.domain =  1; % Time domain

% LOG
memri = memri_log(memri,...
    'memri_ifft_spatial: Applied iFFT to k-space data.');