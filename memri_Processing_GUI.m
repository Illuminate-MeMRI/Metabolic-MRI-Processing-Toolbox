% rawdata2memri

% readMRS_philips --> memri_readMRS
%   readMRS_philips_protocol_txt                    
% readMRS_siemens --> memri_readMRS
% readMRI         --> memri_readMRI



% Test for 1D/2D/3D data - CSI/FIDs/Dynamic
% How to approach dynamics? Multi-TR/TE or something? 
% Siemens: multi-file added as dynamic dimension
% Philips: probably in a single data-file

% Temporary load mat-file
% fp = 'D:\OneDrive\_UKE\Data\20251007_31P_QA\MRS\';
% fn = 'meas_MID00155_FID06626_CSI4PPA_20mm.dat';
% fn = 'meas_MID00165_FID06636_CSI4Pi_20mm.dat';

% fp = 'D:\OneDrive\_UKE\Data\20250602_QAupdate\MRS\';
% % fn = 'meas_MID00053_FID21485_CSI_TR100ms_wAD_Pi.dat'; 
% fn = 'meas_MID00035_FID21467_CSI_TR100ms_wAD_PPA.dat';
% fnmat = 'D:\OneDrive\_UKE\Data\20250602_QAupdate\CSI_PPA_Recon_ForMeMRI_Illuminate.mat';
% % This data set has Pi in the PPA data - but at bw limit, splitting it.
% % CSIgui results in a few showing. Using this - shows more.

fp = 'D:\OneDrive\_UKE\Data\20241010_NewCSI_v1\MRS\';
% fn = 'meas_MID00157_FID00165_csi_fid_ICEunw_TR_AD_v1.dat';
fn = 'meas_MID00161_FID00169_CSI_TR100_NSA4_PPA.dat';
fnmat = 'D:\OneDrive\_UKE\Data\20241010_NewCSI_v1\CSI_PPA_Recon_ForMeMRI_Illuminate.mat';

% No Averages
% fp = 'D:\OneDrive\_UKE\Data\20240416_FIDSeries_V5\';
% fn = 'meas_MID00160_FID13812_CSI_RF2ms_114V_20mm_Pi.dat';
% fn = 'meas_MID00158_FID13810_CSI_RF2ms_143V_20mm_PPA.dat';


[memri.data, memri.nfo] = loadTwix([fp fn]);
memri.labels = memri.nfo.labels;
fprintf('\n\nFILE OF INTEREST:\n%s\n\n', [fp fn]);


fh = figure('Name','MeMRI Processing Pipeline', 'Tag', 'MEMRIPP',...
            'NumberTitle','off', 'MenuBar','none', 'ToolBar','none',...
            'Color','k');

% System information
scrsz = get(0, 'ScreenSize'); scrsz(1:2) = [];
dpath = cd; % Current default path.

% Title text
% Dropdown
% Button
% Tickbox

ch = uicontrol(fh, 'Style',	'checkbox', 'String', 'Title',...
    'FontSize',12, 'BackgroundColor', 'k', 'FontWeight','bold');

pm = uicontrol(fh,'Style','popupmenu', 'String', {'Method 1', 'Method 2'})