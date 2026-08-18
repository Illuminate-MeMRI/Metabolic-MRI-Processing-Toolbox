% MeMRI PTB - "Installation" script.
% Install the memri-toolbox by adding the all necessary paths to pathdef.m
% 
% Only need to be executed before first use or if pathdef.m changes.
%                   < NB. Run in root of MeMRI PTB >

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