% memri_save
function memri_save(memri, method)
% Save memri struct with options to overwrite original data structure or
% write new file: either with the 'method' appended to the file name or
% if method is not given or empty i.e. '', a date-time string in format 
% "yyyy.MM.dd.HHmmss" is used - if available equal to the log-file string.

if nargin < 2, method = ''; end

% STREAM-LINE WITH LoadData()
switch method
    case 'overwrite' 
        % It overwrites the file in memri-struct, if it is not a matlab 
        % file, it will make it one: should not be/happen...
        fpout = memri.filepath;
        [fp, fn, ext] = fileparts(fpout);
        if ~strcmp(ext, '.mat')
            fpout = strcat(fp,'\',fn, ext);
        end
    case ''
        [fp, fn , ext] = fileparts(memri.filepath);
        str =  string(datetime('now','Format','yyyy.MM.dd.HHmmss'));
        fpout = strcat(fp,'\', fn, '.', str, ext);
    otherwise        
        % Try to get the date-time-string out of the log-data
        [fp, fn , ext] = fileparts(memri.filepath);
        fpout = strcat(fp,'\',fn, method, ext);
end

memri.filepath = fpout;

try
    % Save data to file.
    save(memri.filepath, 'memri', '-v7'); % Faster
catch err
    fprintf('%s\n', err.message);
    fprintf('Saving mat-file using v7.3. Can be time-consuming.');
    % Save data to file.
    save(memri.filepath, 'memri', '-v7.3'); % Can be slow
end