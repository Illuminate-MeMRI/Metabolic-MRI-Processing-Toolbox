function sensitivity_map = sensitivity_map(fid)
% Calculate sensitivity maps using the mean of the FID for the 2nd to 5th
% sample-value for every channel index.
%
% Returned are the maps and the permute vector and matrix size for
% rearranging the data such that the channel dimensions is on the second
% index.
%
% Expects FID x CHAN
%
% 
 
% Calculate maps
sensitivity_map = cellfun(@(x) mean(x(2:5,:),1), fid, 'UniformOutput', 0);