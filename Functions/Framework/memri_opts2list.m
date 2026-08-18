function opts = memri_opts2list(opts)
% Will return the options for MeMRI PTB as a cell-list for fnc() input
% arguments i.e. options, in the MeMRI PTB modules.

% Options name and value
copts_varname = {opts(:).varname}; copts_value = {opts(:).val};

% Convert to cell-list
opts = cat(2, copts_varname', copts_value')';
opts = [opts(:)];