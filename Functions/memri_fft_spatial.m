function memri = memri_fft_spatial(memri)
% Return the forward FFT of a complex multidimensional volume over the 
% spatial indexes in "dim". Expects data in memri.data and requires
% memri.labels to find the correct spatial indexes querying kx, ky and kz.
% i.e. spatial time-domain to k-space.
% 
%
% Input
%   memri:  memri-struct with a multidimensional array (memri.data) with 
%           spatial dimension at indexes described in memri.labels.
%
% Output
%   memri:  input struct with the fourier transform of memri.data.
%
% Method
%   First inverse fftshift each spatial dimension before forward FFT, 
%   followed by a second fftshift.
%   
% Miscellaneous
% See fft_spatial() for more details.
%
% Quincy van Houtum, v2025.12
% Contact: quincyvanhoutum@gmail.com 

% Required input
spat_ind = findLabels(memri.labels, {'kx', 'ky', 'kz'});

% Spatial forward fourier transform
memri.data = fft_spatial(memri.data, spat_ind);
memri.nfo.domain = 0; % k-Space domain

% LOG
memri = memri_log(memri, ...
    'memri_fft_spatial: Applied FFT to spatial MRS data.');