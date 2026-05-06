function data = uncellify(data)
% Reverts the cellify() operation, returning the data array with original 
% array size. Corrects for the squeeze operation in cellify.
%
% ... = uncellify(data);
%
% Quincy van Houtum. v11.2025
% quincyvanhoutum@gmail.com

% The #dims in the cell content are added via permute to properly use 
% cell2mat.
inCellSz = size(data{1}); 
if numel(inCellSz) == 2
    if inCellSz(2) == 1, inCell = 1; else, inCell = numel(inCellSz); end
else
    inCell = ndims(data{1});
end
sz = size(data);

% Permute vector
pvec_cell = [ (1:inCell) + numel(sz)  1:numel(sz)];
data = permute(data, pvec_cell);
    
% Apply cell to mat fcn
data = cell2mat(data);