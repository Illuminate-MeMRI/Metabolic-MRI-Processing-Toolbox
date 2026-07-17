function data = memri_ifft_spatial(memri, varargin)
% Return the forward FFT of a multidimensional volume over the spatial
% indexes in "dim".
%
% Input
%   memri:  memri-struct with multidimensional array with spatial dimension 
%           at indexes described in memri.labels.
%   dim:    [1 x N] list of spatial indexes in data
%
% Output
%   data:   inverse fourier transform of the input array data
%
% Method
%   First forward fftshift each spatial dimension before forward FFT, 
%   followed by inverse fftshift.
%   
% Miscellaneous
%
% 
% Quincy van Houtum, v2025.12
% Contact: quincyvanhoutum@gmail.com 

% Required input
spat_ind = findLabels(memri.labels, {'kx', 'ky', 'kz'});

% Spatial forward fourier transform
memri.data = memri_fft_spatial(memri.data, spat_ind);
memri.nfo.domain = 1; % Time domain

% LOG
memri = memri_log(memri, 'memri_script: Applied FFT to k-space data.');