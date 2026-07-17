function nfo = twix_parseNFO(twix_hdr)
% Extract all required NFO from the twix-header for different Siemens
% platform versions: nucleus, dwelltime, fieldstrength, frequency, OS
% factor, dimensions, and FOV. The resolution is calculated from
% matrix-size i.e. dimensions and FOV.
%
% Uses getFieldValues.m, findFieldnames.m

nfo = struct;

% Nucleus
vals = getFieldValues(twix_hdr, 'nucleus'); 
nfo.nucleus = getCommonValue(vals, 0);

% Fieldstrength
nfo.fieldstrength = NaN;
stroi = {'fieldstrength', 'flNominalB0'};
for kk = 1:numel(stroi)
    vals = getFieldValues(twix_hdr, stroi{kk}); 
    nfo.fieldstrength = getCommonValue(vals);
    if ~isnan(nfo.fieldstrength), break; end
end

% Dwelltime & Bandwidth
vals = getFieldValues(twix_hdr, 'dwelltime'); 
dt = getCommonValue(vals) * 1e-9;
% Add additional parameters using found parameters (bw before dwelltime)
if ~isempty(dt), nfo.bandwidth = 1./dt; end
nfo.dwelltime = dt;

% Echo-time
vals = getFieldValues(twix_hdr, 'TE',0);
nfo.TE = getCommonValue(vals) .* 1e-6; % In Seconds.

% Repetition-time
vals = getFieldValues(twix_hdr, 'TR',0);
nfo.TE = getCommonValue(vals) .* 1e-6; % In Seconds.

% FOV - Readout
[vals, foi] = getFieldValues(twix_hdr, 'ReadoutFOV'); 
ind = strfind(lower(foi), 'voi');
ind = cell2mat(cellfun(@(x) ~isempty(x), ind, 'UniformOutput', false));
vals(~ind) = [];
nfo.fov(1) = getCommonValue(vals);

% FOV - Phase
[vals, foi] = getFieldValues(twix_hdr, 'PhaseFOV'); 
ind = strfind(lower(foi), 'voi');
ind = cell2mat(cellfun(@(x) ~isempty(x), ind, 'UniformOutput', false));
vals(~ind) = [];
nfo.fov(2) = getCommonValue(vals);

% FOV - Slice
[vals, foi] = getFieldValues(twix_hdr, 'VoI_SliceThickness'); 
ind = strfind(lower(foi), 'voi');
ind = cell2mat(cellfun(@(x) ~isempty(x), ind, 'UniformOutput', false));
vals(~ind) = [];
nfo.fov(3) = getCommonValue(vals);

% Order of stroi matters.
% Other fields of interest: VoI_Position_Cor/Sag/Tra
stroi = {'VoiPositionCor', 'VoiPositionSag', 'VoiPositionTra'};
for kk = 1:numel(stroi)
    vals = getFieldValues(twix_hdr, stroi{kk}); 
    nfo.offcenter(kk) = getCommonValue(vals);
    if isnan(nfo.offcenter(kk)), nfo.offcenter(kk) = 0; end
end

% Orientation
stroi  = {'VoI_Normal_Tra', 'VoI_Normal_Sag', 'VoI_Normal_Cor'};
for kk = 1:numel(stroi)
    vals = getFieldValues(twix_hdr, stroi{kk}); 
    nfo.orientation = getCommonValue(vals);
    if ~isnan(nfo.orientation)
        nfo.orientation = stroi{kk}(end-2:end);
        break;
    end
end

% --- Other parameters --- %

% Transmit Frequency
vals = getFieldValues(twix_hdr, 'frequency'); 
nfo.transmit_frequency = getCommonValue(vals);

% Oversample Factors
nfo.OS = NaN;
stroi = {'ReadOSFactor', 'ReadoutOSFactor', 'OS'};
for kk = 1:numel(stroi)
    vals = getFieldValues(twix_hdr, stroi{kk}); 
    nfo.OS = getCommonValue(vals);
    if ~isnan(nfo.OS), break; end
end

% Also located in Config.VoI_Position_Cor/Sag/Tra
% Sagital means slices in LR-direction
stroi = {'SliceResolution', 'MatrixSizeSlice', 'Slice'};
stroi_exact = [1 0 0];
for kk = 1:numel(stroi)
    vals = getFieldValues(twix_hdr, stroi{kk}, 0, stroi_exact(kk)); 
    nfo.dim(3) = getCommonValue(vals);
    if ~isnan(nfo.dim(3)), break; end
end


% --- Spatial parameters --- %

% Matrix sizes
stroi = {'ReadResolution', 'MatrixSizeRead', 'Read'};
for kk = 1:numel(stroi)
    vals = getFieldValues(twix_hdr, stroi{kk}, 0); 
    nfo.dim(1) = getCommonValue(vals);
    if ~isnan(nfo.dim(1)), break; end
end

stroi = {'PhaseEncodingLines', 'MatrixSizePhase', 'Phase'};
for kk = 1:numel(stroi)
    vals = getFieldValues(twix_hdr, stroi{kk}, 0); 
    nfo.dim(2) = getCommonValue(vals);
    if ~isnan(nfo.dim(2)), break; end
end

% Dimensions: [read x phase x slice]
stroi = {'SliceResolution', 'MatrixSizeSlice', 'Slice'};
stroi_exact = [1 0 0];
for kk = 1:numel(stroi)
    vals = getFieldValues(twix_hdr, stroi{kk}, 0, stroi_exact(kk)); 
    nfo.dim(3) = getCommonValue(vals);
    if ~isnan(nfo.dim(3)), break; end
end

% Resolution (mm) using matrix size and fov
if isfield(nfo, 'fov') && isfield(nfo, 'dim')
    nfo.res = nfo.fov./nfo.dim;
end

end % End of main function



function vals = getCommonValue(vals, type)
% Given a cell-array of values/content, find the most frequent value and
% return this. Does NOT work with arrays - only single values or strings.
%
% type describes if query is a number (1, default) or a string (0)

if nargin == 1, type = 1; end

% Safety variable-type checks: empty, character, cell and array-size
ind_empty = cellfun(@isempty, vals); % Removing empty entries
ind_cell = cellfun(@iscell, vals);   % Removing cell-entries
    
if type % If a value-query
    
    ind_char = cellfun(@ischar, vals); 
    ind_big = ~cell2mat(cellfun(@(x) sum(size(x)) == 2, vals, 'uniform', 0));  
    ind_str = cellfun(@isstruct, vals);
    
    % Final index of interest
    ind = ones(size(vals)) - ind_char - ind_empty - ind_cell - ind_big - ind_str;        
    ind(ind < 0) = 0;  ind = logical(ind); 

    % Extract values within set properties (value vs. string)
    vals = cellfun(@(x) double(x), vals(ind));
    
    
    % Get most common value in array.
    if ~isempty(vals), vals = mode(vals); else, vals = NaN; end
    
else % If value is a string-query
    
    % Final index of interest
    ind = ones(size(vals)) - ind_empty - ind_cell;        
    ind(ind < 0) = 0;  ind = logical(ind); 

    % Extract values within set properties (value vs. string)
    vals = vals(ind);

    % Get most common value in array if not a single unique value.        
    if size(unique(vals),2) > 1
        vals = string(mode(categorical( vals)));
    else
        vals = cell2mat(unique(vals));
    end
        
end

end