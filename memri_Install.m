% MeMRI PTB - "Installation" script.
% Install the memri-toolbox by adding the all necessary paths to pathdef.m
% 
% Only need to be executed before first use or if pathdef.m changes.
%                   < NB. Run in root of MeMRI PTB >

function memri_Install()

% Add Toolbox to current-path Matlab
fcall = dbstack('-completenames'); [fp,fn,ext] = fileparts(fcall.file);
tlbx_dirs = dir_withsub(fp); % Only directories returned.

% Parent directory and childs name
sdf = {tlbx_dirs(:).folder}; sdn = {tlbx_dirs(:).name};

% Remove \.git and \ExampleData from folder
hasGit = contains(sdf, '\.git'); sdf(hasGit) = []; sdn(hasGit) = [];
hasExD = contains(sdf, '\_ExampleData'); sdf(hasExD) = []; sdn(hasExD) = [];

% Remove \.git and \ExampleData from name
hasGit = contains(sdn, '.git'); sdf(hasGit) = []; sdn(hasGit) = [];
hasExD = contains(sdn, '_ExampleData'); sdf(hasExD) = []; sdn(hasExD) = [];

% Combine and add paths to MATLAB's pathdef-file.
tlbx_dirs = ...
    cellfun(@(x,y) cat(2,x,'\',y), sdf, sdn,'UniformOutput',false);
if ~isempty(tlbx_dirs), addpath(tlbx_dirs{:}); savepath; end

% User message
msgbox(['Added the MeMRI Processing Toolbox paths to MATLAB. ' ... 
        'Installation complete.'], 'MeMRI-PTB Installation');

end


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

end