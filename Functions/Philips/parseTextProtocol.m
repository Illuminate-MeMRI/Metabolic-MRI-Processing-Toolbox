function mrs_nfo = parseTextProtocol(nfo)
% Parse Philips protocol text-file data to match with the required input 
% parameters for the memri toolbox processing pipeline. NFO is the
% structure returned from the readTextProtocol() for Philips MR protocol
% text files.
%
% Struct field order for output:
% nucleus, fieldstrength, bw, dwelltime, transmit frequency, TE, OS?
% dimensions, res, fov, orientation, offcenter.
%
% Minimalistic input to the memri toolbox proccessing pipeline is by
% design, decreasing dependencies with additions or changes to file 
% structures. File header data is stored in the memri load data mat-file. 
%
% Quincy van Houtum, v11.2025
% quincyvanhoutum@gmail.com


% Nucleus
% Flip Philips convention: element symbol before mass number
nuc = regexp(nfo.Nucleus,'[A-Z]','Match'); num = regexp(nfo.Nucleus,'\d*','Match');
mrs_nfo.nucleus = strcat(num{:},nuc{:});


% Fieldstrength
mrs_nfo.fieldstrength = 7; % This is nowhere present in exported data.

% Bandwidth
if isfield(nfo, 'SpectralBW_Hz')
    mrs_nfo.bandwidth = nfo.SpectralBW_Hz;
end

% Echotime & TR
if isfield(nfo,  'Act_TR_TE_ms')
    TRTE = strsplit(nfo.Act_TR_TE_ms,' / ');
    mrs_nfo.TR = str2double(TRTE{1}) .* 1e-3;
    mrs_nfo.TE = str2double(TRTE{2}) .* 1e-3;
end

% FOV: RL AP FH
if isfield(nfo, 'FOVRL_mm')
    mrs_nfo.fov = [nfo.FOVRL_mm nfo.AP_mm nfo.FH_mm];    
end

% Resolution: RL AP FH
if isfield(nfo, 'ACQVoxelSizeRL_mm')
    mrs_nfo.res = [nfo.ACQVoxelSizeRL_mm nfo.ACQAP_mm nfo.ACQFH_mm];
end

% Orientation
mrs_nfo.orientation = nfo.SliceOrientation(1:3);

% Offcenter
if isfield(nfo, 'Offc_AP_P__mm')
   mrs_nfo.offcenter = [nfo.Offc_AP_P__mm nfo.OffRL_L__mm nfo.OffFH_H__mm];
end