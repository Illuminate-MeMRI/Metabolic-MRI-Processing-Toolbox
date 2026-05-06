function data = cellify(data, nCell)
% Returns data as a cell-array with the first nCell dimensions as
% cell-content.
%
% Example:
% ... = cellify(data, 2) with size(data) = [2 4 5 3];
%       returns: data = cell-array 5 x 3 with cell size {[2 x 4]}; 
%
% Input
%   data:           multi-dimensional array.
%   nCell:          the #dimensions from one to ncell to set as cell 
%                   content. 
%
% Quincy van Houtum. v11.2025
% quincyvanhoutum@gmail.com

% Data size
% szo = arrayfun(@(x) size(data,x), 1:nCell);
szo = size(data);

% Add a dimension if only one dimension...
if numel(szo) < nCell, szo(end:end+nCell) = ones(1, nCell-numel(szo)); end 

% Prepare mat2cell cell-layout vectors
cell_layout = arrayfun(@ones, ones(1, size(szo(nCell+1:end),2)), ...
    szo(nCell+1:end), 'UniformOutput',0);
cell_layout = cat(2, num2cell(szo(1:nCell)), cell_layout);

% Convert to a cell matrix with {cell_labels} x [other indexes];
% Includes a soft squeeze, only removing the first ncell indexes with 
% length 1.
pvec = [nCell+1:numel(szo) 1:nCell]; 
data = permute(mat2cell(data, cell_layout{:}), pvec); 
