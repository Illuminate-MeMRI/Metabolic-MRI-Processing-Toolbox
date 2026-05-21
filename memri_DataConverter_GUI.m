% Initialize a GUI for loading metabolic MRI data into memory and exporting 
% it to a generalized format compatible with the MeMRI-toolbox processing
% pipeline.
%
% Q. van Houtum, v02.2025. 
% Contact: quincy.houtum@uk-essen.de / quincyvanhoutum@gmail.com

clc;clear;

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

% Initiate the GUI
[memri, gui] = GUI_initiate();


function memri_open_file(obj, ~)
% Select files to be pre-processed. Selected files are shown in the
% listbox and stored in the main MeMRI data structure. Vendor selection is
% performed and saved.

% UI for file selection of MeMRI data: raw data + txt-header nfo
[fn, fp, idx] = uigetfile(...
    {'*.dat;*.list;*.data;*.txt;*.dcm;*.ima','Compatible MRS and DCM files'; ...
    '*.dat', 'Raw Siemenes data'; ...
    '*.list;*.data','Raw Philips data'; ...
    '*.sdat;*.spar','Raw Philips data'; ...
    '*.ima;*.dcm','Siemens or Philips dicom data'; ...
    '*.txt','Protocol Info (Philips)'}, 'Select MeMRI-data...',...
    'MultiSelect','on');
if ~iscell(fn), fn = {fn}; end; if idx == 0, return; end
if ~strcmp(fp(end), '\'), fp = [fp '\']; end

% Add to listbox
memri_add_files(guidata(obj), strcat(fp, fn));

end

function memri_open_folder(obj, ~)
% Open UI to select directory and process its content, filtering for all
% compatible file formats.
%
% Extensions of interest
% {'.dat', '.list', '.data', '.txt', '.ima', '.dcm'}

% UI for directory selection
fp = uigetdir(cd, 'Select directory...'); if ~ischar(fp), return; end

% Analyse directory content, including sub-directories
[~, cont] = dir_withsub(fp); 

% Filter for IMA-series and replace by single file-path
cont = memri_ima_check_series(cont);

% Full file paths
cont_fpn = cellfun(@(x, y) strcat(x, '\', y), ...
    {cont(:).folder}, {cont(:).name}, 'UniformOutput',false);

% Add files to GUI-listbox
memri_add_files(guidata(obj), cont_fpn);

end

function memri_vendor_text(obj)
% Set the vendor text-box string

% Vendor by data-format: 1 = Siemens; 2 = Philips
% Siemens: .dat-file. Philips: .list, .data, .sdat, .spar, .txt
gui = guidata(obj);

% Appdata
if isappdata(gui.obj, 'memri'), memri = getappdata(gui.obj, 'memri'); end 

% Get extensions
edit_str_fn = extractField(gui.edits.fn, 'String');
ind_empty = cellfun(@(x) ~isempty(x),edit_str_fn);
[~, ~, ext] = cellfun(@(x) fileparts(x), edit_str_fn(ind_empty), ...
    'UniformOutput', false); 
ext = unique(ext);

% DAT-file boolean
dat_bool = sum(strcmp(ext, '.dat'));
if dat_bool, vendor = 1; else, vendor = 2; end

memri.vendor = vendor; 
gui.texts.vendor.String = memri.vendor_string{memri.vendor}; 
gui.texts.vendor.ForegroundColor = [0, 60, 225]./255;

% Store updated appdata
setappdata(gui.obj, 'memri', memri);

end

function memri_add_files(gui, fpn)
% Parse filenames and add to file-lines in GUI


% // ---- Parse the filepaths input
[fp, fn, ext] = memri_add_files_parse_input(fpn);


% % // --- Check type/file
pval = memri_add_files_parse_type(fn, ext); % Popup value for data-type


% // --- Get starting line to write files too
nlines = numel(gui.edits.fn); % #lines in total to write files to in GUI 
% Filename data in lines in GUI
edit_str_fn = extractField(gui.edits.fn, 'String');
% Find first empty-line
ind = cellfun(@(x) isempty(x), edit_str_fn);
line_start_index = find(ind, 1, 'first'); 


% // --- Write to Lines

% Safety - #lines
if line_start_index > nlines, line_start_index = 1; end
if line_start_index+numel(fn)-1 > nlines, line_start_index = 1; end

ni = 0;
for fi = line_start_index:line_start_index+numel(fn)-1    
    ni = ni + 1; % Increase linear counter/iter.

    % Filepath
    gui.edits.fp{fi}.String = fp{ni};
    % Filepath tooltip string
    gui.edits.fp{fi}.TooltipString = fp{ni};
    % Filename
    gui.edits.fn{fi}.String = strcat(fn{ni}, ext{ni});    
    % Popups file-type
    gui.popups.type{fi}.Value = pval(ni);
end

% // --- Clean Up

% Update gui-data
guidata(gui.obj, gui);

% Update gui-vendor
memri_vendor_text(gui.obj);

end

function popup_type_val = memri_add_files_parse_type(fn, ext)

% // --- Check type/file
ind_data = cell2mat(strcmpn(ext, {'.dat','.data'}));    % type = 2 / MRS
ind_noise = cellfun(@(x) contains(x,'noise',...         % type = 3 / Noise
    'IgnoreCase',true), fn);     
ind_prot = cell2mat(strcmpn(ext, {'.txt'}));            % type = 4 / Prot
ind_img = cell2mat(strcmpn(ext, {'.ima', '.dcm'}));     % type = 5 / MRI
% Type 1 = None (-) in popup.

% Output variable
popup_type_val = ones(1,numel(fn)); 

% Add right popup value in order of fn/ext
popup_type_val(ind_data) = 2; popup_type_val(ind_noise) = 3; 
popup_type_val(ind_prot) = 4; popup_type_val(ind_img) = 5;

end

function [fp, fn, ext] = memri_add_files_parse_input(fpn)
% Parse the filepaths selected by the user:
% 1. Check for .list/.data file-pairs and remove .list-file as these files
% come in file-pairs.
% 2. Check if a .data file exisist with the same name as any non-paired 
% .list-files.
% 3. Check for full ima-series and remove all but one of the ima-files.
%
%

% Get filepath parts 
[fp, fn, ext] = cellfun(@fileparts, fpn, 'UniformOutput', false);

% // --- Seperate files by extension of interest:
extoi = {'.dat','.list','.data','.txt','.spar','.sdat','.ima','.dcm'}; 

extoi_ind = strcmpn(ext, extoi); 
% Indexes to delete
ind = 1:numel(ext); ind_exclude = ~ismember(ind, cell2mat(extoi_ind));
% Remove file of non-interest
fn(ind_exclude) = []; ext(ind_exclude) = []; fp(ind_exclude) = [];

% //---- Check for list/data pair
% Remove list-file, keep data-file, as they are expected with the same
% filename.

ind_data = strcmp(ext, {'.data'}); 
ind_list = find(strcmp(ext, {'.list'})); tbdel = NaN(1,numel(ind_list));
if ~isempty(ind_list) % List-file(s) is/are given
    % Match .list-filename to .data-filename
    for kk = 1:numel(ind_list)
        ind_match = find(strcmp(fn(ind_list(kk)), fn(ind_data)), 1);
        if ~isempty(ind_match), tbdel(kk) = ind_list(kk); end        
    end
    
    % Remove matching list-files, leaving data-files only
    fn(tbdel) = []; fp(tbdel) = []; ext(tbdel) = [];
end

% Check for remaining .list-files for matching .data files and set
% .data-file instead of .list-file
ind_list = find(strcmp(ext, {'.list'})); 
for kk = 1:numel(ind_list)
    fp_tmp = strcat(fp{ind_list(kk)}, '\', fn{ind_list(kk)});
    if exist(fp_tmp, 'file') == 2, ext(ind_list(kk)) = '.data'; end
end


end

function memri_remove_input(hobj, evt)
% Remove a single line or all of the given input files from the edit-boxes. 

% Retrieve gui-data
gui = guidata(hobj);

% Event source check
nlines = numel(gui.buttons.clear_line);
ind = cellfun(@(x) isequal(x, evt.Source), gui.buttons.clear_line);
if ~sum(ind), loop_iter = 1:nlines; else, loop_iter = find(ind == 1); end

% Loop lines to clear
for li = loop_iter    
    gui.edits.fp{li}.String = ''; gui.edits.fn{li}.String = '';
    gui.popups.type{li}.Value = 1;
end

% Update gui-data
guidata(hobj, gui);

end

function memri_export_data(obj, ~)
% Read files selected by the user via the filepaths stored in the listbox.

% Get GUI-data
gui = guidata(obj);

% Get filepaths, filenames and file-type from input.
fp = cellfun(@(x) x.String, gui.edits.fp, 'UniformOutput', 0);
fn = cellfun(@(x) x.String, gui.edits.fn, 'UniformOutput', 0);
tp = cell2mat(cellfun(@(x) x.Value, gui.popups.type, 'UniformOutput', 0));

% Combine strings
files = cellfun(@(x,y) strcat(x, '\', y), fp, fn, 'UniformOutput', false);
files(cellfun(@isempty,fn)) = []; tp(cellfun(@isempty,fn)) = [];

% Check for noise-file input
% tp = {'-', 'MRS Data','Noise Data == 3','Protocol info','MR Images'}
if sum(tp == 3)
    file_noise = files(tp == 3);files(tp == 3) = '';
    files = cat(2, files, {'noise'}, file_noise);
end

% Show export ongoing to user
tmp = obj.Parent.Name; 
obj.Parent.Name = [obj.Parent.Name '| Exporting...']; drawnow;

try
    % Load data
    gui.texts.vendor.ForegroundColor = [156, 0, 20]./255; drawnow;

    memri_loadData(files, 1);

    % Revert to original figure name
    obj.Parent.Name = tmp; drawnow;

    % Success - show green logo.
    gui.texts.vendor.ForegroundColor = [15, 180, 6]./255; drawnow;

catch err
    % Handle errors in loading data - write file-strings and error-log to
    % file.
    obj.Parent.Name = tmp; drawnow;
    fprintf('Loading data failed. Report error -message and -file.\n');
    str = string(datetime('now', 'Format','yyMMddHHmmss'));
    save(['error_log' str '.mat'], 'err', 'files');
    throw(err);
end


% Automatic processing
memri_launch_autoprocessing(obj);


end

function cont = memri_ima_check_series(cont)
% Content is a structure as returned from dir()/dir_withsub().
%
% Returns the same structure but with IMA series replaced by a single file
% instead of all files in the series.

% Full file paths
cont_fpn = cellfun(@(x, y) strcat(x, '\', y), ...
    {cont(:).folder}, {cont(:).name}, 'UniformOutput',false);

% Extensions
[~, ~, ext] = cellfun(@(x) fileparts(x), {cont(:).name},...
    'UniformOutput',false);
dcm_bool = strcmpi(ext , '.ima'); dcm_ind = find(dcm_bool == 1);


% Check for dicom-series
series_lib = cell(1,numel(cont));
for kk = dcm_ind
    % If not already in a found series...
    if ~sum(kk == [series_lib{:}])
    
        % Check for series of this ima-dicom file
        serie_dcm = dicomreadSiemens_getSeries(cont_fpn{kk}); % filenames
        
        % Create series full file path
        serie_dcm_fpn = cellfun(@(x) strcat(cont(kk).folder,'\', x),...
            serie_dcm, 'UniformOutput',false);
    
        % Check for series matching to all ima-files
        series_lib{kk} = cell2mat(strcmpn(cont_fpn, serie_dcm_fpn));            
    end    
end

% Replace series by single file.
series_main_in_content_bool = cellfun(@(x) ~isempty(x), series_lib);
series_main_in_content_index = find(series_main_in_content_bool);
series_full_in_content_index = cell2mat(series_lib);

% Some quick array hussling
ind2delete_in_full_in_content_index = ...
    arrayfun(@(x) find(series_full_in_content_index == x),...
    series_main_in_content_index, 'UniformOutput',false);
ind2delete_in_full_in_content_index = ...
    cell2mat(ind2delete_in_full_in_content_index);
series_full_in_content_index(ind2delete_in_full_in_content_index) = [];

% Remove series, except for one file per series.
cont(series_full_in_content_index) = [];

end

function memri_launch_autoprocessing(obj)
% Launch automated processing - either by script or GUI - if enabled by
% user in the MRS data converter.
gui = guidata(obj);

if gui.ticks.autogui.Value
    fprintf('Automatic processing by GUI is not fully implented yet.\n')
elseif gui.ticks.autoscript.Value
    fprintf('Automatic processing by script is not fully implented yet.\n')
end

end

% // ---------------------------------------------------------------- \\ %
% \\ ---------------------------------------------------------------- // %

function [memri, gui] = GUI_initiate()
% Create figure object and add all UI-elements. Returns appdata memri for
% settings and data plus gui-handle with all UI-objects and window-grid
% parameters.

% < ------- Add UI-element such as buttons or edits here ---------- >

% Colors
clr.bg = [0 0 0]; clr.txt = [0.84 0.84 0.84];
clr.hl = [0.84 0.2 0.2]; font.sz = 11; font.weight = 'bold'; 

% Create figure object
obj = figure('NumberTitle','off', 'MenuBar', 'none', 'ToolBar','none',...
             'Tag','memritoolbox');
obj.Color = clr.bg; 

% Set figure position: based on monitor resolution
scrsz = get(0, 'screensize'); % Below: safety for DPI/Win MATLAB issues.
if sum(scrsz(3:4) < 320), scrsz(3:4) = [1920 1080]; end % 16 x 9 ratio
pos = obj.Position;
pos([3 4]) = [640 640 .* scrsz(4)/scrsz(3)]; % Width and height
pos([1 2]) = 0.5 .* scrsz(3:4); obj.Position = pos;

% // --- Prepare UI elements grid
% Generates struct window with figure and UI-element parameters stored in
% the gui-handle (gui = guidata(obj);).

% Number of row and column elements possible in GUI.
ncol = 4; nrow = 7; % X and Y 

% Normalized approach.
obj.Units = 'normalized'; obj.Name = 'Illuminate - Raw MRS Data Converter';

% #Elements in figure plus block size
window.init_sz = pos([3 4]);

% Offset of borders ui-elements [%]
drdc = [0.005 0.01]; window.drdc = drdc;

% Grid element size without offset (drdc)
grid_sz_no_offset = 1 ./ [ncol nrow]; 

% Grid size UI: grid size for ui elements such as buttons
window.grid_sz = grid_sz_no_offset - (2 * drdc);

% Grid vectors
vx = drdc(1):grid_sz_no_offset(1):(1-drdc(1));
vy = flip( drdc(2):grid_sz_no_offset(2):(1-drdc(2)) );
window.grid_ui_vec = {vx, vy};

% Grid{col, row} element position.
[gr, gc] = ndgrid(window.grid_ui_vec{:}); 
window.grid = cellfun(@(x,y) [x(:), y(:)], num2cell(gr), num2cell(gc), ...
    'UniformOutput',false);

% // --- Add button objects
% Elements positioning using grid of size ncol(x) by nrow(y).

% BUTTON: File
buttons.open_file = uicontrol(obj, 'Style', 'pushbutton', 'String', 'File...', ...
    'Units', 'normalized',...
    'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
    'Fontsize', font.sz, 'FontWeight','bold'); 
buttons.open_file.Position = [window.grid{1,1} window.grid_sz];
buttons.open_file.Callback = @memri_open_file;

% BUTTON: Folder
buttons.open_folder = uicontrol(obj, 'Style', 'pushbutton', 'String', 'Folder...', ...
    'Units', 'normalized',...
    'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
    'Fontsize', font.sz, 'FontWeight','bold'); 
buttons.open_folder.Position = [window.grid{2,1} window.grid_sz];
buttons.open_folder.Callback = @memri_open_folder;

% BUTTON: Export
buttons.export = uicontrol(obj, 'Style', 'pushbutton', ...
    'String', 'Export', 'Units', 'normalized',...
    'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
    'Fontsize', font.sz, 'FontWeight','bold'); 
buttons.export.Position = [window.grid{4,3} window.grid_sz];
buttons.export.Callback = @memri_export_data;

% BUTTON: Clear
buttons.clear = uicontrol(obj, 'Style', 'pushbutton', ...
    'String', 'Clear',  'Units', 'normalized',...
    'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
    'Fontsize', font.sz, 'FontWeight','bold'); 
buttons.clear.Position = [window.grid{3,3} window.grid_sz];
buttons.clear.Callback = @memri_remove_input;

% // --- Add text-objects

% Text - Vendor
texts.vendor = uicontrol(obj, 'Style', 'text', 'String', 'Vendor', ...
    'Units', 'normalized',...
    'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
    'Fontsize', font.sz, 'FontWeight','bold');  

% Position and correction for edit-boxes
txt_pos_corr = [1 0.5]; pos = [window.grid{1,3} window.grid_sz]; 
% Apply corrections
pos(2) = pos(2) + ( (window.grid_sz(2).* txt_pos_corr(2)) / 2); 
pos(3:4) = pos(3:4) .* txt_pos_corr; 
pos(3) = pos(3) + round(txt_pos_corr(1)).*drdc(1);
texts.vendor.Position = pos;


% // --- Add tickbox-objects

% TICKBOX: automatic processing - Script
ticks.autoscript = uicontrol(obj, 'Style','checkbox',...
    'String', 'Process via script',  'Units', 'normalized',...
    'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
    'Fontsize', font.sz, 'FontWeight','bold'); 
ticks.autoscript.Position = [window.grid{3,2} window.grid_sz];
ticks.autoscript.Callback = @GUI_ticks_autoprocessing;

% TICKBOX: automatic processing - GUI
ticks.autogui = uicontrol(obj, 'Style','checkbox',...
    'String', 'Process via GUI',  'Units', 'normalized',...
    'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
    'Fontsize', font.sz, 'FontWeight','bold'); 
ticks.autogui.Position = [window.grid{4,2} window.grid_sz];
ticks.autogui.Callback = @GUI_ticks_autoprocessing;

% // --- Selected files display
% Creates elementgroup: edit, edit, button popup related to filepath,
% filename, clear line and data-input-type.

n = 0;
for kk = 4:7 % Rows to show this elements-group

row = kk; n = n+1;

    % - EDIT FP: -----------------
    % Position correction
    edit_pos_corr = [1 0.5]; pos = [window.grid{1,row} window.grid_sz]; 
    % Apply corrections
    pos(2) = pos(2) + ( (window.grid_sz(2).*edit_pos_corr(2)) / 2); 
    pos(3:4) = pos(3:4) .* edit_pos_corr; % pos(3) = pos(3) + 2.*drdc(1);
    
    % Create edit
    edits.fp{n} = uicontrol(obj, 'Style', 'edit', ...
        'String', '',  'Units', 'normalized',...
        'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
        'Fontsize', font.sz-2, 'FontWeight','normal', ...
        'HorizontalAlignment','right');
    edits.fp{n}.Position = pos;


    % - EDIT FN: -----------------

    % Position correction
    edit_pos_corr = [1.75 0.5]; 
    pos_fn = [window.grid{2,row} window.grid_sz]; 
    
    % Apply corrections
    pos_fn(2) = pos_fn(2) + ( (window.grid_sz(2).*edit_pos_corr(2)) / 2); 
    pos_fn(3:4) = pos_fn(3:4) .* edit_pos_corr; 
    
    % Create edit
    edits.fn{n} = uicontrol(obj, 'Style', 'edit', ...
        'String', '',  'Units', 'normalized',...
        'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
        'Fontsize', font.sz, 'FontWeight','normal');
    edits.fn{n}.Position = pos_fn;


    % - BUTTON RM: ---------------

    % Position correction: using previous element
    pos_bu = pos_fn; pos_bu(1) = pos_bu(1) + pos_bu(3) + 2.*drdc(1);
    % Square button; 
    pos_bu(3) = pos_bu(4) .* window.init_sz(2)./window.init_sz(1); 
    
    % Create button
    buttons.clear_line{n} = uicontrol(obj, 'Style', 'pushbutton', ...
        'String', 'x',  'Units', 'normalized',...
        'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
        'Fontsize', font.sz-1, 'FontWeight','Bold',...
        'Callback', @memri_remove_input,...
        'HorizontalAlignment','center');
    buttons.clear_line{n}.Position = pos_bu;


    % - POPUP: -----------------

    % Position correction
    pos_pu = pos_bu; pos_pu(1) = pos_pu(1) + pos_pu(3) + 2.*drdc(1); 
    pos_pu(3) = 1 - pos_pu(1) - drdc(1); 
    pos_pu(2) = pos_pu(2);
    
    % Create edit
    popups.type{n} = uicontrol(obj, 'Style', 'popup', ...
        'String', {'-', 'MRS Data','Noise Data','Protocol info','MR Images'},  ...
        'Units', 'normalized',...
        'BackgroundColor',clr.bg, 'ForegroundColor', clr.txt,...
        'Fontsize', font.sz, 'FontWeight', 'normal');
    popups.type{n}.Position = pos_pu;


end

% // --- Finishing touches

% Set everything to pixels.
obj.Units = 'pixels';

% Update figure object if screensize changes.
obj.SizeChangedFcn = @GUI_window_resized;

% Store GUI elements and settings
gui = guidata(obj); gui.obj = obj;  
gui.buttons = buttons; gui.texts = texts; gui.ticks = ticks;
gui.popups = popups; gui.font = font; gui.edits = edits; 
gui.window = window; gui.clr = clr;

% Create appdata memri
memri = struct; memri.vendor_string = {'Siemens', 'Philips'};
setappdata(obj,'memri', memri);

% Store gui-data
guidata(obj, gui);

% Add menubar
GUI_menubar(obj);

% Add Illuminate image
GUI_image_illuminate(obj);


end


function GUI_window_resized(obj, ~)
% Initiates during screensize changes, allowing updates of certain GUI
% elements.

% Gui-data
gui = guidata(obj);

% Init fontsize
fsz_init = gui.font.sz;

% Screen change factors
rat = obj.Position(3:4)./gui.window.init_sz;

% New FontSize
if rat(2) == 1 || abs(rat(2)-1) < 0.05
    fsz = fsz_init;
else
    fsz = floor( rat(2) .* fsz_init);
end

% Loop all GUI elements
uielm = {'buttons', 'texts', 'edits', 'popups'};
for kk = 1:numel(uielm)
    uielm_names = fieldnames(gui.(uielm{kk}));
    for yy = 1:numel(uielm_names)
        if iscell(gui.(uielm{kk}).(uielm_names{yy}))
            for ci = 1:numel(gui.(uielm{kk}).(uielm_names{yy}))
                gui.(uielm{kk}).(uielm_names{yy}){ci}.FontSize = fsz;
            end
        else
            gui.(uielm{kk}).(uielm_names{yy}).FontSize = fsz;
        end
            
    end
end

end

function GUI_close(~, ~)
closereq;
end

function GUI_ticks_autoprocessing(obj, evt)
% Ensures only one of the tickboxes can be active - process via GUI or via
% script.

gui = guidata(obj);

% Source tickbox
src = 'gui'; if contains(evt.Source.String, 'script'), src = 'script'; end

% Disable the other ticbox if enabled.
switch src
    case 'gui'
        if gui.ticks.autoscript.Value, gui.ticks.autoscript.Value = 0; end        
    case 'script'
        if gui.ticks.autogui.Value, gui.ticks.autogui.Value = 0; end
end

end

function GUI_image_illuminate(obj)
% Try to plot the illuminate logo

img = imread('Resources\Illuminate_logo.png');

gui = guidata(obj); 
ax_width = 0.5 - 2.*gui.window.drdc(1);
pos = [gui.window.grid{3,1} ax_width gui.window.grid_sz(2)];
gui.logo_axis = axes(obj, "Position", pos,...
    'XTick',[], 'YTick',[], 'Box', 'on', 'Color','k');

imshow(img, 'Parent', gui.logo_axis);
end

function GUI_menubar(obj)
    
% Retrieve GUI-data
gui = guidata(obj);

% 1.File % ------------------------------------------------------------- %
gui.menubar.file.main = uimenu(obj,'Label','File');

% 1.File > Open..
gui.menubar.file.open_file = ...
    uimenu(gui.menubar.file.main,'Label', 'Open file...',...
    'Enable', 'on', 'Callback', @memri_open_file);

% 1.File > Open folder..
gui.menubar.file.open_folder = ...
    uimenu(gui.menubar.file.main,'Label', 'Open folder...', ...
    'Enable', 'on', 'Callback', @memri_open_file);

% 1.File > Close.
gui.menubar.file.close = ...
    uimenu(gui.menubar.file.main,'Label', 'Exit', ...
    'Enable', 'on','Callback', @GUI_close, 'Separator','on');            

% 2.Help % ------------------------------------------------------------- %
gui.menubar.help.main = uimenu(obj,'Label','Help');

% 2.Help > Help
gui.menubar.help.help = ...
    uimenu(gui.menubar.help.main ,'Label', 'Help',...
    'Enable', 'on',  'Callback', @memri_openHelp);

% 2.Help > Updates/Github
gui.menubar.help.updates = ...
    uimenu(gui.menubar.help.main ,'Label', 'Updates',...
    'Enable', 'on', 'Callback', @GUI_open_github);

% 2.Help > About
gui.menubar.help.about = ...
    uimenu(gui.menubar.help.main ,'Label', 'About',...
    'Enable', 'on', 'Callback', @GUI_open_illuminate, 'Separator','on');

% Update GUI-data
guidata(obj, gui);

end

function GUI_open_illuminate(~, ~)
    web('https://www.ihi-illuminate.org/');
end

function GUI_open_github(~, ~)
    web('https://github.com/Illuminate-MeMRI/Metabolic-MRI-Processing-Toolbox');
end