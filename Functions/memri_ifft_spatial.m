function data = memri_ifft_spatial(data, dim)
% Return the forward FFT of a multidimensional volume over the spatial
% indexes in "dim".
%
% Input
%   data:   multidimensional array with spatial dimension at indexes 
%           described in dim. 
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


% Shift zero-freq to center
for kk = 1:numel(dim), data = fftshift(data, dim(kk)); end

% Fourier Transform
for kk = 1:size(dim,2), data = fft(data,[], dim(kk)); end

% Shift back
for kk = 1:numel(dim), data = ifftshift(data, dim(kk)); end
