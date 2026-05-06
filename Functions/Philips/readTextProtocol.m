function nfo = readTextProtocol(varargin)
% nfo = readTextProtocol(varargin)
%
% Read the MR protocol text file exported from a Philips MR (>v5) console. 
%
% Input         None, Full filepath or file path and name.
% Output:       nfo = structure with header data as double or string.
%               Returns NaN if the file is not found.
%
% Quincy van Houtum, v08.2019
% quincyvanhoutum@gmail.com

% //--- Handle input
if nargin == 0 
    [fn, fp, fi] = uigetfile({'*.txt','text file'}, 'Select a text-file');
    if fi == 0, nfo = nan; return; end
elseif nargin == 1
    [fp, fn, ext] = fileparts(varargin{1}); fn = [fn ext];
else
    fp = varargin{1}; fn = varargin{1};
end
 
% // --- Read file
lines = readText([fp '\' fn]); 
if ~iscell(lines) && isnan(lines), nfo = NaN; return; end


% // --- Analyze file

% Loop each line and convert data
sz = numel(lines); nfo = struct;
for li = 1:sz
    % Split tag and data
    tagdata = strsplit(lines{li},' =');
    
    % Create variable name from tag
    tag = strip(matlab.lang.makeValidName((tagdata{1})),'_');
    
    % If TAG exists already - use previous as added label
    curr_fn = fieldnames(nfo); tag_ind_in_curr_fn = strcmp(curr_fn, tag);
    if sum(tag_ind_in_curr_fn) % Field exists!
        ind = find(tag_ind_in_curr_fn == 1);
        prev_field = curr_fn{end}; prev_field(4:end) = [];
        tag = [prev_field tag];
    end
    
    if size(tagdata,2) > 1
        
        
    % Convert data
    if isempty(strfind(tagdata{2},'"'))                         % Double
        % Get numbers only and convert  to double
        data = regexprep(tagdata{2},';',''); 
        data = str2double(data);                 
        
    else                                                        % String
        % Remove trailing spaces, quotes and semicolon.
        data = strtrim(tagdata{2}); data(strfind(data,'"')) = []; 
        data = strip(data,';'); 
    end
   
    % Store data in field tag
    nfo.(tag) = data;
    
    else
        msg = ['Line %i in text-file has no' ...
               ' data or data-tag in line: \n %s \n'];
        fprintf(msg,li, lines{li});
    end
end