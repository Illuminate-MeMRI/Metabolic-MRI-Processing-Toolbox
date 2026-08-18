function data = ifft_spatial(data, dim)
% Return the forward FFT of a multidimensional volume over the spatial
% indexes in "dim". i.e. k-space to spatial (time-) domain.
%
% Input
%   data:   complex multidimensional array with its spatial dimension  
%           described in dim.
%           NB. k-Space format:   [-kmax ... -Δk   0   +Δk ... +kmax]
%
%   dim:    list of spatial dimension indexes in data.
%
% Output
%   data:   inverse fourier transform of the input array data
%           format
%
% Method
%   First inverse fftshift each spatial dimension before the inverse FFT, 
%   followed by fftshift.   
%
%   Details: 
%   First, shift the zero-frequency to the start of the dimensions as 
%   required by MATLAB's ifft() implementation. k-Space has zero-frequency 
%   in center and ifftshift() shifts k(center) = 0 to k(1) = 0 i.e. by 
%   swapping the volume. Fourier shift implementation: 
%        fftshift([2 1 0 1 2]) = [1 2 2 1 0] i.e. second shift
%       ifftshift([2 1 0 1 2]) = [0 1 2 2 1] i.e. first shift
%
%   This ensure correct array ordering, however the exact physical (x,y,z)
%   coordinates and corrections for a half-voxel offset for an even-sized 
%   matrix is a different processing method.
% 
% Quincy van Houtum, v2025.12
% Contact: quincyvanhoutum@gmail.com 

% Shift k = zero-freq to start index
% [-k ... -1 | 0 | +1 ... +k] ---> [0 | +1 ... +k | -k ... -1]
for kk = 1:numel(dim), data = ifftshift(data, dim(kk)); end

% Fourier Transform
for kk = 1:numel(dim), data = ifft(data,[], dim(kk)); end

% Shift back
% [x=0  +Δx  +2Δx -3Δx -2Δx -Δx] ---> [-3Δx  -2Δx  -Δx 0   +Δx +2Δx +3Δx] 
for kk = 1:numel(dim), data = fftshift(data, dim(kk)); end
