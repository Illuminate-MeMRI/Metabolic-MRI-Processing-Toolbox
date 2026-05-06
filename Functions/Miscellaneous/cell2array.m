function [data, labels] = cell2array(data, labels, pvec, ncell)
% Reverts the array2cell operation, returning the data array invert-permute
% by pvec. Requires the initial number of labels in the cell-array, either
% from array2cell output or from numel(cell_labels), see array2cell.
%
% Input is given by array2cell().
%
% Quincy van Houtum. v04.2026
% quincyvanhoutum@gmail.com


% // --- Reorder labels w.r.t. to cellify operation

% Analyse data dimensionality of cell-array and cell-contents
% ndimData allows corrections for lists as cell-array or cell-content.
ndimTot = numel(pvec); ndimData = ndimTot - ncell; 

% Permute labels
pvec_labels = [ (1:ncell) + ndimData  1:ndimData];
labels = labels(pvec_labels); % Back to original label order.

% // --- Reorder cell data array and permute

% Checksum for list-cell-content.
% The #dims in the cell are added via permute to properly use cell2mat. 
% Correction factor for lists as cell-content.
if size(data{1}, ncell) == 1 % Size of last dim in cell-content equals 1.  
    pvec_cell = [ 1 + ndimData  1:ndimData];

elseif ndimData == 0 || ndimData == 1 
    % Cell-array is a list (1) or all dims are set as cell-content (0)
    pvec_cell = 1:ndims(data); % i.e. no real permute executed     
else
    pvec_cell = 1:ndimData; % i.e. no real permute executed
end
data = permute(data, pvec_cell);

% Convert cell to array wrt dimensions in cell.
data = uncellify(data);

% // --- Permute reorder to orignal
pveci = arrayfun(@(x) find(x == pvec), 1:numel(pvec));
data = ipermute(data, pvec); labels = labels(pveci);

