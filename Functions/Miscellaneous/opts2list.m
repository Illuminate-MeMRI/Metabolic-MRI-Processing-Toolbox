function opts = opts2list(opts)
% Will return the given struct as a cell list in format: 
% opts = {fieldname, value, fieldname, value, ...}
%
% Cell can be used as input-arguments i.e. varargin: func(opts{:});

% Get options
flds = fieldnames(opts); opts = struct2cell(opts); 

% Merge opts-fieldnames and values
opts = cat(2, flds, opts)'; opts = opts(:);