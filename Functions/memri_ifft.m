function fid = memri_ifft(memri, corr_onesided)
% Inverse or backward fourier of spectra ordered in space (1-ND). 
% Expects the frequence to be on index-dimension one!
%
% Input:     memri - Array with each spectrum on the first dimension.
%                    (fres x M x N x P x ...)
%                    OR
%                    memri-struct from memri-ptb
%
% Used algorithm: ifft( ifftshift( spectra ));
%                 Shift zero-freq to center before calculating the ifft.
%                 Each spectrum will be converted to a cell-array with
%                 size (M x N x P ...) whereafter the ifft-method is 
%                 applied on each cell. No loops, fast.
%
% corr_onesided:  Correct for onesided FFT in spectroscopy. On (1) by
%                 default. Sample at t = 0 is doubled after ifft.
% 
% Quincy van Houtum, PhD; v2.0 11/2025
% quincyvanhoutum@gmail.com   
%
% See also: memri_fft(fid);               

if nargin == 1, corr_onesided = 1; end

% Data can be the memri-struct or a complex data array. 
doLog = 1; if isstruct(memri), spec = memri.data; else, spec = memri; doLog = 0; end

% // --- Convert SPEC to cell
% If required

if ~iscell(spec)
    wasCell = 0;
    % Exclude first-e.g. time-dimension.
    % Create vector of ones for each dimension. Cell/FID.
    sz = size(spec); cell_layout = ...
    arrayfun(@ones, ones(1,size(sz(2:end),2)),sz(2:end),'UniformOutput',0);

    % Creat cell array of data: {FID} x other dimensions
    spec = mat2cell(spec, sz(1), cell_layout{:}); 
else
    wasCell = 1;
end

% // --- FFT over all FIDS.

% First inverse the data shift around 0 in memri_fft() prior to ifft.
fid = cellfun(@ifftshift, spec,  'UniformOutput', 0);  % Inverse shift.   
fid = cellfun(@ifft,      fid,   'UniformOutput', 0);  % Inverse FFT                     

% Correct for t = 0 because of non-symmetrical e.g. one-sided fft. 
if corr_onesided
    fid = cellfun(@(x) x .* [2 ones(1,size(x,1)-1)]', fid, 'Uniform', 0);
    memri_log(memri, 'memri_ifft: corrected for one-sided iFFT.');
end

% // --- Convert FID to array
% If required

if ~wasCell    
    fid = cell2mat(fid); 
    if numel(sz) <= 2, fid = squeeze(fid); end % Undo if 1D data.    
end


% LOG & Output
if doLog
    memri.data = fid; memri.nfo.domain = 2;
    memri = memri_log(memri, 'memri_fft: Applied iFFT to time domain.');
    fid = memri; % Return struct as output.
end
 
