function lines = readText(file)
% Read a text-file line by line using proper Matlab convention and return 
% a cell-array containing all lines of the given text-file.
%
% Input
%   files   Filepath to text-file as string.
%
% Output
%   lines:  Cell-array with every line of the text-file as string.
%           Returns NaN if file cannot be opened or user cancelled.
%
% Quincy van Houtum, 08.2025 - v1
% quincyvanhoutum@gmail.com

% Number of lines in file.
try
    fid = fopen(file); if fid == -1, lines = NaN; return; end
    nn = 0; while ~feof(fid), nn = nn + 1; fgetl(fid); end
    
    % Read and store lines
    lines = cell(nn,1);
    frewind(fid); for kk = 1:nn, lines{kk} = fgetl(fid); end
    fclose(fid);
catch err
    lines = NaN;
end