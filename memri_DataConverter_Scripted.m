% memri_LoadData_Scripted

doSiemens = 1;
doPhilips = 1;


% Philips
if doPhilips

    % Directory with data
    fpmain = 'D:\OneDrive\Matlab\MeMRI\_ExampleData\CSI_Philips\';
    % Files of interest
    fp = {'raw_019.data','GE_T1w_match_CSI.dcm',...
          'noise', 'raw_026_noise.data'};
    % Combine to full paths
    fp = cellfun(@(x) strcat(fpmain, x), fp, 'UniformOutput',false);
    fp{3} = 'noise';

    % Load data
    philips_memri = memri_loadData(fp);

end

% Siemens
if doSiemens
    
    % Directory with data
    fpmain = 'D:\OneDrive\Matlab\MeMRI\_ExampleData\CSI_Siemens\PPA_wNoise\';
    % Files of interest
    fp = {'CSI_RF2ms_155V.dat',...
          'GE_MS_TRA_SL64_0002\QH_FAMAP_V4.MR.QUINCY_TDC_UPGRADED.0002.0001.2024.08.22.15.02.10.781964.12421294.IMA',...
          'noise', 'FID_Noise.dat'};
    % Combine to full paths
    fp = cellfun(@(x) strcat(fpmain, x), fp, 'UniformOutput',false);
    fp{3} = 'noise';

    % Load data
    siemens_memri = memri_loadData(fp);

end



