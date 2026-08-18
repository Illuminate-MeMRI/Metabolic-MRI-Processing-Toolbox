% MeMRI PTB - "Installation" script.
% Install the memri-toolbox by adding the all necessary paths to pathdef.m
% 
% Only need to be executed before first use or if pathdef.m changes.
% < NB. Run in root of MeMRI PTB >

% Add Toolbox to current-path Matlab
fcall = dbstack('-completenames'); [fp,fn,ext] = fileparts(fcall.file);
toolbox_directories = dir_withsub(fp);
sdf = {toolbox_directories(:).folder};
sdn = {toolbox_directories(:).name};
toolbox_directories = ...
    cellfun(@(x,y) cat(2,x,'\',y), sdf, sdn,'UniformOutput',false);
if ~isempty(toolbox_directories)
    addpath(toolbox_directories{:}); savepath;
end