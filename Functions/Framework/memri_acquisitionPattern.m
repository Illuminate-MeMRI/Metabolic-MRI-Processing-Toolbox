function acqpat = memri_acquisitionPattern(mrs, ind_aver)
% Returns the acquisition pattern (hamming weighted acq.) using the raw
% k-space data (mrs) and the number of sampled averages.
%
% Finds non-zero voxels via summation of the FID and returns a voxel-mask. 
% The mask is summed over the averages-index and divided by the maximum
% number of averages in all voxel to calculate a weighted acquisition map.
%
% Input
%       mrs:        Complex multidimensional array [FID x X x Y etc ...]
%       ind_aver:   Index of the average dimension (NSA).
%
% Output
%       acqpat:     Acquisition pattern array.
%
% Quincy van Houtum, v04.2025.
% quincyvanhoutum@gmail.com

% Output container
% acqpat = zeros(size(mrs,2:ndims(mrs))); 
acqpat = zeros([1 size(mrs,2:ndims(mrs))]); 
% All non zero voxels set to one
% acqpat( (squeeze(sum(abs(mrs), 1))) > 0 ) = 1;
acqpat( ((sum(abs(mrs), 1))) > 0 ) = 1;
% Average over nsa-index minus one as we removed the FID dimension
% acqpat = sum(acqpat, ind_aver-1);  
acqpat = sum(acqpat, ind_aver);  
% Normalize to max #nsa per voxel in volume
acqpat = acqpat./max(acqpat,[], 'all'); % 'all' is faster than acqpat(:)
