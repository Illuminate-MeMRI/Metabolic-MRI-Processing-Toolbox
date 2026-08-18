function [subdir, cont] = dir_withsub(fp)
% [sub-directories, content] = dir_withsub(filepath)
%
% Get all sub-directories in directory filepath fp and return the content.
% ! Recursive.
%
% Quincy van Houtum. v10.2020
% quincyvanhoutum@gmail.com

% Get files & directories
nfo = dir(fp);

% Remove ./.. directory
subname = {nfo(:).name};
dots = cellfun(@(x) strcmp(x, {'.', '..'}), subname, 'UniformOutput', 0);
dots = cell2mat(cellfun(@(x) sum(x), dots, 'UniformOutput', 0));
nfo(dots==1) = [];

% Split directories and files 
isdir = [nfo(:).isdir]; subdir = nfo(isdir); cont = nfo(~isdir); 

% Read all files in every sub-dir
for kk = 1:numel(subdir)
    [tmp_subdir, tmp] = dir_withsub([subdir(kk).folder '\' subdir(kk).name]);     
    cont(numel(cont)+1:numel(cont)+numel(tmp),1) = tmp;
    subdir(numel(subdir)+1:numel(subdir)+numel(tmp_subdir),1) = tmp_subdir;
end

if size(cont,2) > size(cont,1), cont = cont'; subdir = subdir'; end

