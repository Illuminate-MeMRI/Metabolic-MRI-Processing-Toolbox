function index = findLabels(labels, query)
% Search for a string in a cell-string and return its index. Input "labels" 
% can be a cell-string itself. 
%
% Example: index = findLabels({'a','b', 'c', 'd'}, {'c', 'a'});
% index = [3 1];
%
% NB. In case of duplicates in "labels", the lowest index is returned.
%
% Quincy van Houtum, v10.2025
% quincyvanhoutum@gmail.com

% Require cell-format
if ~iscell(query), query = {query}; end

index = NaN(1,size(query,2));
for kk = 1:size(query,2)
    srch = find(strcmp(labels, query(kk)), 1);
    if ~isempty(srch), index(kk) = srch(1); end 
end
