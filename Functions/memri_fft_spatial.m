function data = memri_fft_spatial(data, dim)
% Return the inverse FFT of a complex multidimensional volume over the 
% spatial indexes in "dim". 
%
% Input
%   data:   complex multidimensional array with spatial dimension at  
%           indexes described in dim. 
%   dim:    list of spatial dimension indexes in data.
%
% Output
%   data:   inverse fourier transform of the input array data
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


% Shift zero-freq to center
for kk = 1:numel(dim), data = ifftshift(data, dim(kk)); end

% Fourier Transform
for kk = 1:size(dim,2), data = ifft(data,[], dim(kk)); end

% Shift back
for kk = 1:numel(dim), data = fftshift(data, dim(kk)); end