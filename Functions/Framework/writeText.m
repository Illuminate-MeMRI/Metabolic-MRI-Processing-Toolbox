function status = writeText(file, text)
% Write to a text-file line by line using fprintf. Expects text to be a
% cell array with an element per line.
%
% Input
%   files   Filepath to text-file as string.
%   text    Text data as cell-string array.
%
% Output
%   status  Returns 1 if succesful, NaN if not.
%
% Quincy van Houtum, 05.2026 - v1
% quincyvanhoutum@gmail.com


% File ID
fid = fopen(file, "w+"); 
if fid == -1, status = nan; return; end

% Write lines
for kk = 1:numel(text), fprintf(fid, '%s\n', text{kk}); end            

% Close 
fclose(fid); status = 1;
