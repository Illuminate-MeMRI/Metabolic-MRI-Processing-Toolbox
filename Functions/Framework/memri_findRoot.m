function memri_root = memri_findRoot()
% <-- This function only works if memri_install() was executed before -- >
%
% Reads the stored default MATLAB paths for the MeMRI-PTB toolbox. 
% MeMRI-PTB its root folder should be: 'Metabolic-MRI-Processing-Toolbox'.

% String of interest contained in path of interst i.e. directory name.
stroi = 'Metabolic-MRI-Processing-Toolbox';

% Get all paths within MATLAB' pathdef: filepaths
fps = pathdef; fps = strsplit(fps, ';');

% Find paths with stroi - select shortest path string
ind = contains(fps, stroi); fps = fps(ind);
if isempty(fps)
    warndlg(['MeMRI Processing Toolbox root path not found. ' ...
             'The root directory '  stroi  ' ' ...
             'is not in your default search path. ' ...
             'Please run memri_install().'],...
             'MeMRI Processing Toolbox');
    memri_root = nan; return;
end

% If memri_install.m was executed, this is the root of the MeMRI-PTB.
[~, fps_shortest] = min(cellfun(@length, fps));
fps = fps{fps_shortest}; 

% Catenate the splitted cells from the path up to the cell that equals
% stroi i.e. directory.
fp_sub = strsplit(fps, '\'); ind = find(contains(fp_sub, stroi));
memri_root = strjoin(fp_sub(1:ind), '\');
if ~strcmp(memri_root(end), '\'), memri_root = [memri_root '\']; end