% memri_LoadData_Scripted

doSiemens = 1;
doPhilips = 1;

% Example data used and expected in the memri-ptb root directory
fproot = memri_findRoot();

saveTofile = 0;

% Philips
if doPhilips

    % Directory with data
    fpmain = [fproot '\_ExampleData\Philips\CSI\Pi\'];

    % File names of interest
    fp = {'raw_019.data', ...             % The main spectroscopy data file; 
           ....                           % memri_loadData() will automatically find the list-file (which per convention has the same filename).
          'GE_T1w_match_CSI.dcm',...      % The associated dicoms; 
          ...                             % not required nor supported in the alpha-release yet.
          'noise', 'raw_026_noise.data'}; % Seperate noise measurement
    
    % Protocol parameters for Philips raw data
    % The memri_loadData() script will automatically search for the 
    % 'raw_019.txt' file that contains protocol information in the same 
    % directory as the data. If the file-names do not match - the text file 
    % can be added as input or the user will be prompted for required
    % parameters: nucleus, fieldstength, bandwidth, echotime, resolution or
    % field-of-view and volume-offset.

    % Combine to full paths
    fp = cellfun(@(x) strcat(fpmain, x), fp, 'UniformOutput',false);

    % Noise entry
    fp{3} = 'noise'; % This entry needs to stay "noise" as memri_loadData parses the entry after 'noise' as a separate noise-measurement.

    % Load data
    philips_memri = memri_loadData(fp,saveTofile);

end

% Siemens
if doSiemens
    
    % Directory with data
    fpmain = [fproot '_ExampleData\\Siemens\CSI\Pi\'];

    % Files of interest
    fp = {'CSI_Pi_ISO20.dat',...
          'GRE_Transverse\QH_31P_QA.MR.QUINCY_TDC_UPGRADED.0023.0001.2025.10.07.11.05.03.156923.13975308.IMA',...
          'noise', 'FID_Noise.dat'};

    % Combine to full paths
    fp = cellfun(@(x) strcat(fpmain, x), fp, 'UniformOutput',false);
    fp{3} = 'noise';

    % Load data
    siemens_memri = memri_loadData(fp, saveTofile);
end



