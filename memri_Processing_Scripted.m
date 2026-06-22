% MeMRI_PP scripted v0.1
clc;clear;close all force;

% MemRI Toolbox - Dynamic MATLAB framework for loading, processing, 
% quantify and visualize MRS data
%
% Index labels of interest:     kx, ky, kz, fid, aver, chan.

% Possible methods
doApodization = 1;        
doHammingCorrection = 1; 
doHammingFilter = 0;
doAverage = 1;
doFFT_spatial = 1; 
doFFT = 1;
doNoise = 1;
doNoiseDecorrecelation = 1; 
doPCA = 1;
doCombine = 2; % 1 = WSVD, 2 = Roemer

doSiemens = 1; % <DEV>

% // --- Settings (to be text-filed and read later on!)

% opts.masksize = for noise mask size if noise from voxel, default 25%
% Using a noise-measurement will use the full sample range.

% ---------------------------- TBD ------------------------------------- %
% Quantification/Fitting via AMARES (MATLAB)
% Visualization GUI for localization: CSIgui - Lite
%
% Miscellaneous:
% Write help-file and quick-guide
% Github release
% Framework overview
% Example data (need FIDs) and tutorial (last)
% Hamming filter, Zero-filling, autophase? (memri-toolbox)


% Data loaded using MeMRI-LoadData-GUI
if ~doSiemens
    % Example data Philips
    load('D:\OneDrive\Matlab\MeMRI\_ExampleData\CSI_Philips\raw_019.mat');
    % load('D:\OneDrive\Matlab\MeMRI\_ExampleData\CSI_Philips\raw_020.mat');
else
    % Example data Siemens
    load('D:\OneDrive\Matlab\MeMRI\_ExampleData\CSI_Siemens\PPA\meas_MID00135_FID06606_CSI4PPA_20mm.mat');    
    % load('D:\OneDrive\Matlab\MeMRI\_ExampleData\CSI_Siemens\Pi\meas_MID00165_FID06636_CSI4Pi_20mm.mat');
    % load('D:\OneDrive\Matlab\MeMRI\_ExampleData\CSI_Siemens\PPA_wNoise\CSI_RF2ms_155V.mat');
end
fprintf('\n\nFILE OF INTEREST:\n%s\n\n', memri.filepath);
memri.labels


% //--- Load in vendor-independent MeMRI data

% Optional:
% -. MR imaging data array
% -. MR imaging spatial information
% -. Dimension specific information (TR for multi-TR, TE for multi-TE)
% -. T.B.D.

% Data-array is sorted and labels for each index, nucleus, field strength, 
% bandwidth, repetition time, echotime, resolution and more are available.
% Optional: MR imaging data from dicom.
%           load('memri_data.mat') will load memri-struct in workspace.

% ----------------------- Process data

% // --- Preperations

% Set data domain
% Set to k-space domain (0), if the k-space e.g. spatial indexes can be 
% found, otherwise set time domain (1), or frequency domain set by user (2).
ind_spat = findLabels(memri.labels, {'kx', 'ky', 'kz'});
memri.nfo.domain = 0; if sum(isnan(ind_spat)) == 3, memri.nfo.domain = 1; end
    

% // --- Initiate LOG
memri = memri_log(memri, memri.filepath);


% // --- Apodization weighted acquisition correction
if doHammingCorrection
    memri.data = memri_hamming_correction(memri.data, ind_spat, ind_aver);    
end



% // --- NSA
nsa_ind = findLabels(memri.labels, {'aver'});
if ~isnan(nsa_ind)
    memri.data = mean(memri.data, nsa_ind, 'omitnan');
    memri = memri_log(memri, 'memri_script: Averaged over the NSA dimension.');
end


% // --- FFT to spatial time domain
if doFFT_spatial

    % Required input
    spat_ind = findLabels(memri.labels, {'kx', 'ky', 'kz'});

    % Spatial forward fourier transform
    memri.data = memri_fft_spatial(memri.data, spat_ind);
    memri.nfo.domain = 1; % Time domain

    % LOG
    memri = memri_log(memri, 'memri_script: Applied FFT to k-space data.');
end


% // --- Analyse noise-data
if doNoise      
    memri = memri_noise(memri, 'independent', 1, 'masksize', 'all', 'noiseDomain', 2); % Noise in time domain (1)
end

% // --- Noise decorrelation
if doNoiseDecorrecelation % Or do this within coil-combine
    % We need this for pca denoising anyways, so maybe it makes sense to calculate it seperately.    
end


% // --- PCA denoising
if doPCA
    memri = memri_pca_denoising(memri);
    memri.nfo.wsvd.opts.identity_matrix = 1;
    memri.nfo.roemer.opts.identity_matrix = 1;
end


% // --- Combine coil channels
% WSVD and ROEMER
if doCombine == 1                                                 % WSVD %
    % TBD: ID-matrix
    memri = memri_wsvd(memri, 'method', 1, 'reference_channel', 1);
elseif doCombine == 2                                           % ROEMER %
    % TBD: ID-matrix and options
    memri = memri_roemer(memri, 'noisecov', 1);
end


% // --- FFT to spatial frequency domain
if doFFT, memri = memri_fft(memri); end


% // --- DISPLAY CHECK USING CSIgui % ---------------------------------- %

if doSiemens
    CSIgui(memri.data, 'mrs', memri.labels, 'labels', memri.source.header, 'twix');
else
    CSIgui(memri.data, 'mrs', memri.labels, 'labels');
end



% Save memri-data
% memri = memri_save(memri, 'overwrite'); TBD TBD TBD TBD
% memri = memri_save(memri); TBD TBD TBD TBD



% // --- Interpolate
% // --- Phase-corrections for visualization // fitting is seperate
% // --- Optional conversion MR imaging data

