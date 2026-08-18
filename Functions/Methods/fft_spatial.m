function data = fft_spatial(data, dim)
% Return the forward FFT of a complex multidimensional volume over the 
% spatial indexes in "dim". Example: spatial time-domain to k-space.
%
% Input
%   data:   complex multidimensional array with uits spatial dimension
%           described in dim.           
%           NB. Spatial format: [-3Δx  -2Δx  -Δx 0 +Δx +2Δx +3Δx] 
%
%   dim:    list of spatial dimension indexes in data.
%
% Output
%   data:   inverse fourier transform of the input array data
%           k-space format: [-k ... -1 | 0 | +1 ... +k]
%
% Method
%   First inverse fftshift each spatial dimension before forward FFT, 
%   followed by a second fftshift.
%   
%   Details: 
%   First, shift the spatial center to the start of the dimensions as 
%   required by MATLAB's fft() implementation. The ifftshift() shifts 
%   x(center) = 0 to x(1) = 0 i.e. by swapping the volume. 
% 
% Quincy van Houtum, v2025.12
% Contact: quincyvanhoutum@gmail.com 


% Shift k = zero-freq to start index
% [-3Δx  -2Δx  -Δx x=0 +Δx +2Δx +3Δx] ---> [x=0  +Δx  +2Δx -3Δx -2Δx -Δx]
for kk = 1:numel(dim), data = ifftshift(data, dim(kk)); end

% Fourier Transform
for kk = 1:numel(dim), data = fft(data,[], dim(kk)); end

% Shift back
% [0 | +1 ... +k | -k ... -1] ---> [-k ... -1 | 0 | +1 ... +k]
for kk = 1:numel(dim), data = fftshift(data, dim(kk)); end


