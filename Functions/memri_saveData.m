function memri = memri_saveData(memri, varargin)
% Save the (processed) MeMRI data struct to file. 
%
% The data will be exported with a new date-time string or the
% instance-number, if it is available. Other options available:
% 
% If "overwrite" is enabled (1) the original mat-file will be overwritten. 
% Input argument "userinput" enabled (1) will uiprompt the user for a 
% file location.
%
% NB: 
%       If an instance number is not present, the current date-time will be
%       used to set an instance number.
%       Options overwrite has priority over option userinput; avoid both
%       inputs.
%       
%
% Example:
% memri_saveData(app, 'overwrite', 1), memri_saveData(app, 'userinput', 1);
%
% Q. van Houtum, PhD. v062025
% quincyvanhoutum@gmail.com

% // --- Parse input
opts.overwrite = 0; opts.userinput = 0;
for vi = 1:2:numel(varargin)
    opts.(varargin{vi}) = varargin{vi+1};
end

% // --- Generate a file path
if opts.overwrite
    % Overwrite original data-file for memri-ptb
    
    % Original file-location
    fpn = memri.filepath;
    
    % Log-message
    logtxt = 'Overwritten original mat-file:';

elseif opts.userinput
    % UI for file location and name

    % Location from user
    [fn,fp,indx] = uiputfile({'*.mat;';'MATLAB file'},...
        'Save MeMRI data to file...');

    % If user canceled uiputfile
    if indx == -1
        memri = memri_log(memri, 'User canceled save data to file.',...
            'NB. < DATA NOT EXPORTED TO FILE. >');
        return; 
    end

    % Combined filepath
    fpn = [fp '\' fn];

    % Log-message
    logtxt = 'File destination given by user: ';

else

    % Check for instance
    if isfield(memri, 'instance')
        time_str = memri.instance; msg_sub = 'memri-instance';
    else
        time_str = string(datetime('now','Format','yyyy.MM.dd.HHmmss'));
        msg_sub = 'current date-time';
        % This forces the log-file have the same instance number as 
        % the memri-file: though log-data is available in the memri-struct
        % too.
        memri.instance = time_str; 
    end

    % Get original filepath
    [fp, fn, ext] = fileparts(memri.filepath);

    % Append with instance/date-time-string
    fpn = strcat(fp, '\', fn, '.', time_str, ext);

    % Log-message
    logtxt = ['Appended original file-location with the ' msg_sub ':'];

end

% Log
memri = memri_log(memri, logtxt, fpn);

% // --- Save to file
try
    % Save data to file.
    save(fpn, 'memri', '-v7'); % Faster but can result in larger filesizes.

catch err
    fprintf('%s\n', err.message);
    fprintf('Saving mat-file using v7.3. Can be time-consuming.');
    
    % Save data to file.
    save(fpn, 'memri', '-v7.3'); % Can be very slow
end

end