function memri = parsePhilips(fp)
% memri = parsePhilips(fp)
%
% Example filepath input fp: 
%      {'C:\data\CSI.data', 'C:\data\ProtInfo.txt',...
%       'C:\data\GE_MS.dcm', 'noise', 'C:\data\'Noise.data'});
%
% Parse Philips MR spectroscopy raw data-export .list/.data-files and 
% convert to a generalized data-structure, matching parseSiemens. 
%
% Requires:
% ...matching .list/.data-file filenames if either not given.
% ...additional data acquisition parameters by 
%    1. text-file, equal filename to .list/.data-file or getfile-prompt. 
%    2. equal filename to .list/.data file pair.
%    3. user input prompt.
%
% Also accepts Philips dicom data as dcm-files. NB. Extension .dcm in the 
% filename is required.
%
% Input
%   fp:     cell-list with filepaths to all files of interest.
%
%           OPTIONAL NOISE-FILE INPUT:
%           Using the tag 'noise' followed by the filepath to an MRS data 
%           file (.data or .list) parses that file as noise-input. 
%               Example:
%               Input fp = {'D:\csi.data', 'noise', 'D:\noise.data'};
%
% Output
%   memri:  struct with MRS data (.data), labels (.labels) matching all
%           data dimensions, field with protocol parameters (nfo) and more.
%
% Corrections:
%          None so far
%
% ... used by memri_loadData();
%
% Quincy van Houtum, v01.2026
% quincyvanhoutum@gmail.com

% // --- Noise Tag to Index
ind_noise = find(strcmp(fp, 'noise'));
if ~isempty(ind_noise), fp(ind_noise) = []; end

% // --- Safety check
if ~iscell(fp), fp = {fp}; end
[~, ~, ext] = cellfun(@fileparts, fp, 'UniformOutput', false);


% // --- Load all files into MATLAB-memory
%   !!!!! Some outputs are necessary for this loop. Do NOT suppress      %
%       output eventhough MATLAB marks output.                    !!!!!! %
for kk = 1:numel(ext)
    fprintf('\nparsePhilips: loading file \n\t%s\n', fp{kk});
    switch ext{kk}
        % List and data loops work together to not load list/data-file
        % pairs twice.
        case '.list'                        
            if  isempty(ind_noise) || kk ~= ind_noise
                if ~exist('mrs_list', 'var')
                    mrs_list = readListFile(fp{kk}); % Data
                end
            else
                if ~exist('nse_list', 'var')
                    nse_list = readListFile(fp{kk}); % Noise
                end
            end
            
        case '.data'
            if isempty(ind_noise) || kk ~= ind_noise
                if exist('mrs_list', 'var')
                    [mrs_data, mrs_list] = readDataFile(mrs_list); 
                else
                    [mrs_data, mrs_list] = readDataFile(fp{kk}); 
                end
            else
                if exist('nse_list', 'var')
                    [nse_data, nse_list] = readDataFile(mrs_list); 
                else
                    [nse_data, nse_list] = readDataFile(fp{kk}); 
                end
            end

        case '.txt'
             mrs_nfo = readTextProtocol(fp{kk});

        case '.dcm'
            [data_img, nfo_img] = dicomreadPhilips(fp(kk));          
    end
end


% // --- Setup MEMRI-STRUCT

% Data
memri.data = mrs_data.raw; memri.labels = mrs_data.labels;


% // ---- Retrieve Data Header NFO
% Philips data requires additional protocol text-file - 
% If not provided
%   1. Search text-file with same filename as .data/.list-files.
%   2. User selects additional protocol information text-file.
%   3. User prompted for input.

% --- No paremeter info I
% Search for txt-file with same name as data/list files.
if ~exist('mrs_nfo', 'var')
    % Remove the noise-data file if present
    fp_tmp = fp; fp_tmp(ind_noise) = [];

    % Find text-file and load.
    mrs_nfo = protocol_nfo_find_textfile(fp_tmp);
    if ~isstruct(mrs_nfo) && isnan(mrs_nfo), clear('mrs_nfo'); end   
end

% --- No parameter info II
% Check if user wants to supply a text-file or input the parameters.
if ~exist('mrs_nfo', 'var')
    mrs_nfo = protocol_nfo_get_userinput();
    if ~isstruct(mrs_nfo) && isnan(mrs_nfo)
        fprintf('Retrieving Philips MRS parameter information failed.\n');
        fprintf('Parsing aborted.\n');
        return; 
    end
end


% // --- Parse the protocol information
mrs_nfo = parseTextProtocol(mrs_nfo); memri.nfo = mrs_nfo;   


% // --- Parse Noise
if exist('nse_data', 'var')
    
    memri.noise.data = nse_data.raw;
    memri.noise.labels = nse_data.labels;
    memri.noise.domain = 1;

    clear('nse_data');
else

    % Set noise from list-file
    memri.noise.data = mrs_data.noise;
    memri.noise.labels = mrs_data.labels(1:ndims(memri.noise.data));
    memri.noise.domain = 1;

end
clear('mrs_data'); 


% // --- Optional DICOM
if exist('data_img', 'var')
    memri.images.data = data_img; memri.images.nfo = nfo_img;
end

% Source filepaths and header
memri.source.files = fp; memri.source.header = mrs_nfo; 




function mrs_nfo = protocol_nfo_find_textfile(fp)
% Checks for the philips protocol text file by matching .data/.list 
% filename and checking txt-file existance;
mrs_nfo = NaN;

% Extension and .data/.list files
[~, ~, ext] = cellfun(@(x) fileparts(x), fp, 'UniformOutput',false);
ind_data = cell2mat(strcmpn(ext, {'.data', 'list'}));

% If data/list-files exist in fp, check for txt-file
if ~isempty(ind_data)
    [fp_dl, fn_dl] = cellfun(@(x) fileparts(x), fp(ind_data), ...
        'UniformOutput', false);
    fpn_txt = cellfun(@(x,y) strcat(x,'\',y, '.txt'), fp_dl, fn_dl, ...
        'UniformOutput', false);
    txt_exists = cellfun(@(x) exist(x, 'file'), fpn_txt);
    
    for kk = 1:numel(txt_exists)
        if txt_exists(kk) == 2
            fprintf('\nparsePhilips: loading file\n\t%s\n', fpn_txt{kk})
            mrs_nfo = readTextProtocol(fpn_txt{kk}); break;
        end
    end        
end


function mrs_nfo = protocol_nfo_get_userinput()
% Check if the user wants to supply a text-file with protocol information
% OR enters parameter information.
%
%   mrs_nfo returns as NaN if the user cancels.
%
% Quincy van Houtum, v01.2026
% quincyvanhoutum@gmail.com

% Ask for parameter input
qry = {'Select a protocol text-file: (parameters below ignored.)',...
       'Field strength (T): ', 'Nucleus', 'Bandwidth (Hz): ', ...
       'Echotime (ms): ', 'Resolution (mm): (or FOV)', ...
       'Field-of-view (mm): (or resolution)', ...
       'Volume offcenter (mm): ', 'Orientation: '};
elm = {'popup','edit', 'popup', 'edit', 'edit',...
       'edit', 'edit', 'edit', 'popup'};
def = {{'No','Yes'}, '7', ... % 1 = load a file, 2 = field strength
        ... 3 = nucleus
       {'31P','2H', '1H','18F', '13C','23NA'}, ... 
       ... % 4 = BW, 5 = TE, 6 = Res, 7 = FOV, 8 = offset  
       '5000', '0.15','20 20 20', '420 280 320', '0 0 0',... 
       ... % 9 = Orientation
       {'TRA', 'SAG', 'COR'}}; % Orientation
uans = getInput(elm, qry, def, 'Data parameters required:');
if isempty(uans), mrs_nfo = nan; return; end

% --- Userinput for protocol text-file    
doAskUser = 1;
if strcmp(uans{1}, 'yes')
    doAskUser = 0; mrs_nfo = readTextProtocol(); 
    % If the user f's up, still get input
    if ~isstruct(mrs_nfo) && isnan(mrs_nfo), doAskUser = 1; end 
end

% --- Userinput for parameters
if doAskUser        
    % Requirements: Nucleus, bandwidth, fieldstrength, FOV or RES, 
    % offcenter and orientation.
    mrs_nfo = struct; 

    % Set nucleus, fieldstrength, bandwidth and echotime.
    mrs_nfo.nucleus = uans{3}; 
    mrs_nfo.tesla = str2double(uans{2}); 
    mrs_nfo.bw = str2double(uans{4});
    mrs_nfo.TE = str2double(uans{5});
    
    % Set resolution
    if ~isempty(uans{6})
        mrs_nfo.res = strsplit(uans{6});
        mrs_nfo.res = cellfun(@(x) str2double(x), mrs_nfo.res);
    end

    % Set FOV
    if ~isempty(uans{7})
        mrs_nfo.fov = strsplit(uans{7});
        mrs_nfo.fov = cellfun(@(x) str2double(x), mrs_nfo.fov);
    end

    % Set offset
    mrs_nfo.offset = strsplit(uans{7});        
    mrs_nfo.offset = cellfun(@(x) str2double(x), mrs_nfo.offset);
      
    % Set orientation
    mrs_nfo.orientation = uans{9};    
end

% Set output if everything failed
if ~exist('mrs_nfo', 'var'), mrs_nfo = NaN; end