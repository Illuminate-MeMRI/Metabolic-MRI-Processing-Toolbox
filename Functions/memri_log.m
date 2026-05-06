function inp_struct = memri_log(inp_struct, varargin)
% struct or log-data = memri_log(struct.filepath, varargin)
%
% Writes log-data to file. Input structure requires field "filepath" and 
% will return the same struct with an (updated) log-field plus an instance
% number field. The latter is used to track the log-file by log filename:
%   log-file = filepath + instance# .log
%
% The returned structure can be used to keep logging to the same log-file.
%
% NB. Date and time are appended to the start of each log-line.
%
% input
%   fpout:      - Struct with field(s) .filepath and optionally
%                 .log field and an instance-field. If filepath is absent
%                 the log-file is saved as instance.log in the current
%                 MATLAB working directory,
%               - filepath for log-file. The instance number will be
%                 ignored and only a cell-list with log-data is returned.
%
%   varargin:   log-data input as string or integers. Data will be 
%               converted to string and every variable input argument will 
%               be treated as a single line. 
%
% Example: 
% memri = memri_log(memri, 'WSVD applied. Noise-mask:', size(data,1)/6);
% memri = memri_log('\mylogile.log', 'Method applied.');
%
%
% Quincy van Houtum, v12.2025
% quincyvanhoutum@gmail.com

% // --- Process input
ninp = numel(varargin);

% Check for struct or string input fpout.
inpispath = ~isstruct(inp_struct);          % < Input is Path > %
if inpispath, fpin = inp_struct; inp_struct.filepath = fpin; end

% Add log-memri instance: month-day-hour-minutes-seconds.
if ~inpispath && ~isfield(inp_struct, 'instance')
    inp_struct.instance = string(datetime('now','Format','yyyy.MM.dd.HHmmss'));
end

% // --- Log filename

% Log-file path
if ~inpispath && isfield(inp_struct, 'filepath')
    [fp, fn, ~] = fileparts(inp_struct.filepath); 
    fplog = strcat(fp, '\', fn, '_', inp_struct.instance, '.log');
elseif inpispath
    fplog = inp_struct.filepath;
else
    fplog = strcat(inp_struct.instance,'.log');
end


% // --- Log input processing & write to file

fid = fopen(fplog, 'a+');
linesnew = cell(ninp,1);
for kk = 1:ninp
   val = varargin{kk}; 
   
   % Convert non-char input
   if ~ischar(val) % Convert to a string if not char.
       val = arrayfun(@num2str, val, 'UniformOutput',0);
       if numel(val) > 1, val = strjoin(val{:}, ' '); else, val = val{:}; end
   end 

   % Write to file
   linesnew{kk} = sprintf('%s - %s %s/n', ...
       datetime('now','Format','HH:mm:ss'), val);
   fprintf(fid, '%s\n', linesnew{kk});
end
fclose(fid);


% // --- Create function output

% Read log-file or memri-log
lines = {};
if ~inpispath && isfield(inp_struct,'log'), lines = inp_struct.log; end

% Set output
if inpispath, inp_struct = linesnew; 
else,         inp_struct.log = cat(1, lines, linesnew); 
end


