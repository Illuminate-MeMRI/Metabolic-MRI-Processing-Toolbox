% MeMRI_PP scripted v0.5
clc; clear; close all;

% function memri_Processing_Scripted(memri, opts)
% 
% % // --- Initiate LOG
% memri = memri_log(memri, memri.filepath);
% % Find memri-ptb root folder
% mroot = memri_findRoot();
% % Parse input
% if nargin == 1
%   opts = config2opts(); 
%   memri = memri_log(memri, ...
%       'memri_scripted: Loaded default parameters for all active modules');
% end


% < -----------------  MemRI Processing Toolbox ------------------------ >
% Dynamic MATLAB framework for converting, processing, quantifying and 
% visualising MR spectroscopy data.
%
% Multidimensional spectroscopy data with dimensions described
% by index labels of interest: [fid, kx, ky, kz, aver, chan]
% Others dimensions will be handled as additional volumes and processed
% equally.
% % -------------------------------------------------------------------- %


% -------------------------- Userinput --------------------------------- %

% These methods are all available in the MeMRI PTB App. Every method is an
% MeMRI PTB module which is described in a simple text configuration file
% (configMethods.txt). It contains the options i.e. input arguments, for
% each module. The first entry in the input-field in this document is the
% default input argument for a method. Calling config2opts() will generate
% the opts-struct for use with MeMRI PTB module functions.

doNoiseAnalysis = 1;
doAverage = 1;
doHammingCorrection = 1; 
doiFFT_kspace = 1; 
doFFT = 1;
doPCADenoising = 0;
doWSVD = 0; 
doRoemer = 1;

doSave = 0;

% Not used but available
doHammingFilter = 0;
doApodization = 0;        

% // --- Settings 

% Read options: can be edited here!
mconfig = readMethods(); opts = config2opts();

% // --- Misc.

% <DEV>
doSiemens = 0; 


% ---------------------------- TBD ------------------------------------- %
% Quantification/Fitting via AMARES (MATLAB)
% Visualization GUI for localization: CSIgui - Lite
%
% Miscellaneous:
% Write help-file and quick-guide
% Github release
% Framework overview
% Example data and tutorial
%
% Hamming filter, Zero-filling, autophase? (memri-toolbox)

mroot = memri_findRoot();

% Data loaded using MeMRI-LoadData-GUI
if ~doSiemens
    % Example data Philips
    load([mroot '_ExampleData\CSI_Philips\raw_019.mat']);
    % load([mroot '_ExampleData\CSI_Philips\raw_020.mat');   
else    
    % Example data Siemens   
    fproot = [mroot '_ExampleData\CSI_Siemens\'];
    load([fproot 'PPA\meas_MID00135_FID06606_CSI4PPA_20mm.mat']);    
    % load([fproot Pi\meas_MID00165_FID06636_CSI4Pi_20mm.mat']);
    % load([fproot PPA_wNoise\CSI_RF2ms_155V.mat']);
end
fprintf('\n\nFILE OF INTEREST:\n%s\n\n', memri.filepath);
memri.labels

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

% // --- Analyse noise-data
% Noise in time domain (1), freq domain (2) or k-space (0).
if doNoiseAnalysis
    copts = memri_opts2list(opts.NoiseAnalysis);
    memri = memri_noise(memri, copts{:}); 
end

% // --- Apodization weighted acquisition correction
if doHammingCorrection, memri = memri_hamming_correction(memri); end

% // --- NSA
if doAverage, memri = memri_average(memri); end

% // --- FFT to spatial time domain
if doiFFT_kspace, memri = memri_ifft_spatial(memri); end

% // --- PCA denoising
if doPCADenoising
    copts = memri_opts2list(opts.PCADenoising);
    memri = memri_pca_denoising(memri, copts{:}); 
end

% // --- Roemer
if doRoemer
    copts = memri_opts2list(opts.Roemer);
    memri = memri_roemer(memri, copts{:}); 
end

% // --- FFT to spatial frequency domain
if doFFT
    copts = memri_opts2list(opts.FFT);
    memri = memri_fft(memri, copts{:}); 
end

% // --- WSVD
if doWSVD
    copts = memri_opts2list(opts.WSVD);
    memri = memri_wsvd(memri, copts{:}); 
end


% // --- Save to file
% Save memri-data
if doSave
    memri_save(memri, 'ScriptExport');
end

% // --- DISPLAY CHECK USING CSIgui % ---------------------------------- %

if doSiemens
    CSIgui(memri.data, 'mrs', memri.labels, 'labels', memri.source.header, 'twix');
else
    CSIgui(memri.data, 'mrs', memri.labels, 'labels');
end
