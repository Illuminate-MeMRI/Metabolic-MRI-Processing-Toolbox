function opts = config2opts()
% Read config_methods file and create an opts structure for all
% available methods using the default parameters set in the
% config-file.

opts = struct; % Output

% Methods configuation struct & method-variable names
mnfo = readMethods(); mvname = fieldnames(mnfo);

for mi = 1:numel(mvname)

    % Details for the mi'th method in mnfo
    mnfo_mi = mnfo.((mvname{mi})); 

    % Check for options i.e. input arguments for this methods
    % function.
    if isfield(mnfo_mi,'opts')                                    
        for pp = 1:numel(mnfo_mi.opts)
            
            % Use mnfo.input and .type to parse input-data         
            % < No need to change according to inputobj type > 
            cnfg_inp = strsplit(mnfo_mi.opts(pp).input, ',');
            cnfg_inp = opts_parse(mnfo_mi.opts(pp), cnfg_inp);

            % Value for parameter in correct data-format
            val = cnfg_inp(1); % Default input option set here.
            if iscell(val), val = val{:}; end

            % Store opts parameters: 
            % name of parameter (varname) and its value (val).
            opts.((mvname{mi}))(pp).varname = mnfo_mi.opts(pp).varname;
            opts.((mvname{mi}))(pp).val = val;

        end
    else
        % No options for this method - set empty.
        opts.((mvname{mi})) = [];
    end
end

end