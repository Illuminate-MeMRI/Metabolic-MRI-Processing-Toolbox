function ind = strcmpn(s1, s2, IgnoreCases)
% ind = strcmpn(s1, s2, IgnoreCases)
% Equal to strcmp, however, iterates every element in s2 comparing it to s1
% and returning the index number. !! Only works for vectors !!
%
% Input:
%   s1 = cell string list (1 x M,  M x 1)
%   s2 = cell string list (1 x N,  N x 1)
% 
%   ignoreCases (1, default) uses strcmpi, ignoring letter case. 
%   ignoreCases (0) uses strcmp, matching letter case.
%
% Quincy van Houtum. v01.2024
% quincyvanhoutum@gmail.com

if nargin < 3, IgnoreCases = 1; end

% Make cell of search query.
if ~iscell(s2), s2 = {s2}; end

ind = cell(1,numel(s2));
for kk = 1:numel(s2)
    if IgnoreCases
        tmp = find(strcmpi(s1, s2(kk)));
    else
        tmp = find(strcmp(s1, s2(kk)));
    end
    if ~isempty(tmp)
        ind{kk} = tmp;
    end
end
