function [data, labels, pvec, ncell] = array2cell(data, labels, cell_labels)
% Returns data as a cell list with the dimension described in cell_labels
% included in the cells.
%
% Example:
% labels = {'fid', 'x', 'y', 'z', 'chan', 'aver'};
% ... = array2cell(data, labels, {'fid', 'chan'}) with labels describing
% the data array dimensions, returns the list:
%   data = {fid, chan}-array with size index('x' x 'y' x 'z' x 'aver')
%
% Input
%   data:           multi-dimensional array input
%   labels:         cell-string describing each dimension in data.
%   cell_labels:    cell-string for dimensions to set as cell-content.
%
% Output
%   data:           cell array with dimensions in cell-labels as
%                   cell-content.
%   labels:         cell-string matching cell array dimensions corrected 
%                   for any permute operations.
%   pvec:           permute vector used to return to the original array its 
%                   dimensions order, see cell2array().
%
% See also: cell2array()
% Uses: cellify(), uncellify();
%
% Quincy van Houtum. v11.2025
% quincyvanhoutum@gmail.com


% // --- Reorder array
% Cell_labels dimensions permuted to the first indices.

% Set order of data to [cell_labels] x rest with safety for 
% cases where (ndims-data < nlabels) due dimensions size of 1
sz = arrayfun(@(x) size(data,x), 1:numel(labels));
[data, labels, pvec] = sortByLabels(data, labels, cell_labels);    

% Updated size via permute vector due possible dimensions of size 1 that
% size() doesnt include if last dim-index.
szp = sz(pvec); % Size of data array after permute

% // --- Reshape to Cell array
% Convert data to cell array: {cell_labels} x ... x ... etc
ncell = numel(cell_labels);
data = cellify(data, ncell);

% Move cell-content labels to end.
labels = cat(2, labels(numel(cell_labels)+1:end), labels(1:numel(cell_labels)));

