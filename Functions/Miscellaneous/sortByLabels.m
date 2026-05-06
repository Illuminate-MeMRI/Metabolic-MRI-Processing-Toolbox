function [data, labels, pvec] = sortByLabels(data, labels, order)
% Returns an ND data array sorted by "order" using the index-matching
% "labels" for the ND "data" array.
%
% [data, labels, pvec] = sortByLabels(data, labels, order)
%
% Example:
%   ... = sortByLabels(data, {'a', 'b', 'c', 'd'}, {'d', 'a', 'b'});
%   with data = rand(1, 2, 3, 4) will return size(data) = [4, 1, 2, 3].
%
% Output pvec can be used to reverse the sorting using ipermute.
%   data = ipermute(data, pvec);
%
% Quincy van Houtum. v09.2025
% quincyvanhoutum@gmail.com
%
% Should this fnc be renamed to permute_by_labels/permute_byLabels?

% Permute vector
pvec = cellfun(@(x) find(strcmp(x, labels)), order);

% If the permute vector does not include all #labels ...
% User requests an "order" without specifying all dimensions which are 
% present in "labels".
if numel(pvec) < numel(labels)
    % Find the missing indices in permute vector and catenate.
    pvec = cat(2,pvec, find(~ismember(1:numel(labels), pvec)));
end

% Permute
data = permute(data, pvec); labels = labels(pvec);


