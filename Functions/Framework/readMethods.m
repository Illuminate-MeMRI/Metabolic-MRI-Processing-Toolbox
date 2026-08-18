function methods = readMethods(fp)
% Read config-methods text file for MeMRI PTB. Returns a struct with a
% field for every method, containing the name, function and opts fields.
% The opts fields will contain customisable input variables - described by
% fields varname, query, input, display, data type and uistyle. 
%
% The config file requires the following layout and can contain none to
% multiple variable inputs per method. 
%
% < --- Example text-file content:                                    --->
%
% name = FFT
% callback = @memri_fft();
% varname = correct_N
%     query = Correct for 1/#samples in MATLAB's discrete FFT:
%     input = 0, 1
%     display = No, Yes
%     datatype = int    
%     uistyle = popup 
%
% < ---                                                               --->
%   Please see \Presets\Methods_Config.txt for a more detailed example.
%
% Text-file Input Explanation:
% callback          The callback i.e. function called when executing the
%                   method. This callback accepts "varname" as input with
%                   format callback(memri-struct, 'varname', value). The
%                   default value is denoted in "input".
% varname           The variable name or parameter-tag for the
%                   input-arguments of "callback". The variable type
%                   (integer, string) is detailed in "datatype".
% input             The "input" of the "callback" with its correct
%                   data-type in "datatype".
%                   NB. The "input" entry is NOT used for "uistyle" edit,
%                   default value is in "display".
% display           For uistyle popup: What is displayed to the user in a 
%                   dropdown menu, matching the order of "input". The first
%                   in the items for the dropdown menu is set as the
%                   default value.
%                   For uistyle edit:  The value which will be displayed
%                   to user in an edit-field. Again, input is not used for
%                   uistyle edit.
% uistyle           Style of the UI-element used with this variable: 
%                   edit or popup.
%
% Quincy van Houtum, v1 - 202602

% Default config file.
if nargin < 1, fp =  'presets\Methods_Config.txt'; end

try 

    % Read config text file
    confmeth = readText(fp);
    if ~iscell(confmeth) && ~isnan(confmeth)
        ME  = MException('readMethods:noConfigFile','Config file not found!');
        throw(ME); 
    end
    
    % Remove empty lines
    ind_empty = cellfun(@(x) isempty(x), confmeth);
    confmeth(ind_empty) = [];
    
    % Separate attributes and values
    confmeth = cellfun(@(x) strsplit(x, '='), confmeth,...
        'UniformOutput', false);
    
    % Get attributes and values seperated
    att = cellfun(@(x) strtrim(x{1}), confmeth, 'UniformOutput', false);
    val  = cellfun(@(x) strtrim(x{2}), confmeth, 'UniformOutput', false);
    
    % Parse all methods and their query-options
    methods = parse_methods(att, val);

catch err
    methods = nan;
    dtstr = char(datetime('now', 'format', 'HHmmss'));
    save(strcat('readMethods_ErrorLOG_', dtstr, '.mat'), 'err');
end

end

function methods = parse_methods(att, val)
% Parse the config file included methods and add name plus function to
% methods.(method-name). Executes parsing of any queries for found
% methods.

    % Find method-names
    indn = cellfun(@(x) strcmp(x, 'name'), att); % name index
    indn = find(indn);
    
    % Get attributes per method
    nm = numel(indn);
    for mi = 1:nm
        % Index of method in att/val
        ind_inatt = indn(mi);
    
        % Max lines in this method
        if mi+1 > nm, indmax = numel(att); else, indmax = indn(mi+1)-1; end
    
        % Method name for display (mname) and UI-processing in MATLAB (fname)
        mname = val{ind_inatt}; fname = genVarName(mname);       
       
        % Create method-struct
        methods.(fname).name = mname;
        methods.(fname).function = val{ind_inatt+1};

        % Check for method nfo
        if strcmp(att{ind_inatt+2}, 'nfo')
            methods.(fname).nfo = val{ind_inatt+2};
        end
        
    
        % Get the options and their queries for this method
        methods = parse_opts(methods, att, val, ind_inatt, indmax);   
    end

end


function methods = parse_opts(methods, att, val, ind_inatt, indmax)
% Parse each method its input variable queries and add to
% method.(method-name).opts(:)

    % Get fieldname for current method
    fname = fieldnames(methods); fname = fname{end};

    % Find #opts-varname for this method i.e. #queries
    att_sub = att(ind_inatt:indmax); val_sub = val(ind_inatt:indmax);
    % Each index in indq directs to method its input variable name(s)
    indq = cellfun(@(x) strcmp(x, 'varname'), att_sub);
    
    if sum(indq)
        indq = find(indq); indq = [indq' numel(att_sub)+1];
        
        % Go through every opts-query for this method
        for qi = 1:numel(indq)-1 % Loop each query & store
            atts = att_sub(indq(qi):(indq(qi+1)-1));
            vals = val_sub(indq(qi):(indq(qi+1)-1));
           
            % Create struct with fields atts and values vals.
            tl = cat(2, atts, vals)'; tl = tl(:);
            tmp = struct(tl{:});
           
            % Add opts-struct to method-struct             
            methods.(fname).opts(qi) = tmp;
        end
    end 
    
end