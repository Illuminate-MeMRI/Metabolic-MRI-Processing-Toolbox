function spec = memri_fft(memri, corr_N, corr_onesided, double_shift)	
% Foward fourier of spectra ordered in space (1-ND). Expects the
% frequency dimension/FID samples on index 1.
%
% Input:    memri - Array with each FID on the first dimension.
%                    (fres x M x N x P x ...) 
%                   or the memri-struct from memri-tb
%
% Used algorithm: fftshift( fft( FID ));
%                 Calculate the fft of the FID and shift the zero-freq to
%                 the center of the spectrum. Each FID will be converted 
%                 to a cell-array with size (M x N x P ...) whereafter 
%                 the fft-method is applied on each cell. No loops, fast.
%
% Optional input arguments (in order):
%
% corr_N:         Correct for the 1/#samples (N) in the FFT. Off (0) by
%                 default.
% corr_onesided:  Correct for onesided FFT in spectroscopy. On (1) by
%                 default. Sample at t = 0 is halfed before fft.
% double_shift:   Shift the FID twice for handling (symmetric) echoes. 
%                 Disables onesided_cor if enabled.
%
%
% 
% Quincy van Houtum, PhD; v2.0 11/2025
% quincyvanhoutum@gmail.com
%
% See also: memri_ifft();


% // --- Handle input
if     nargin == 1,     corr_N = 0; corr_onesided = 1; double_shift = 0; 
elseif nargin == 2,                 corr_onesided = 1; double_shift = 0;
elseif nargin == 3,                                    double_shift = 0;
end

% Data can be the memri-struct or a complex data array. 
doLog = 1; if isstruct(memri), fid = memri.data; else, fid = memri; doLog = 0; end


% // --- Convert FID to cell if array

if ~iscell(fid)
    wasCell = 0;
    
    % Exclude first-e.g. time-dimension.
    % Create vector of ones for each dimension. Cell/FID.
    sz = size(fid); cell_layout = ...
    arrayfun(@ones, ones(1,size(sz(2:end),2)),sz(2:end),'UniformOutput',0);

    % Creat cell array of data: {FID} x other dimensions
    fid = mat2cell(fid, sz(1), cell_layout{:}); 
else
    wasCell = 1;
end

% // --- FFT over all FIDS.
% Check for pre-fft shift, check for onesided FFT correction, FFT, shift 
% and n-factor correction

% Apply pre-shift (applicable to echoes)
if double_shift
    fid = cellfun(@fftshift, fid, 'UniformOutput', 0); 
    corr_onesided = 0;
    if doLog, memri = memri_log(memri, 'memri_fft: Applied a double-shift (for echoes).'); end
end

% Correct for t = 0 because of non-symmetrical e.g. one-sided fft. 
if corr_onesided
    fid = cellfun(@(x) x .* [0.5 ones(1,size(x,1)-1)]', fid, 'Uniform', 0);
    if doLog, memri = memri_log(memri, 'memri_fft: corrected for one-sided FFT.'); end
end

% FFT
spec = cellfun(@fft,      fid,  'UniformOutput', 0);                        % Fast Forward Fourier

% FFT Shift
spec = cellfun(@fftshift, spec, 'UniformOutput', 0);                        % Shift zero-freq to centrum of spectrum

% Correct N-factor 
if corr_N                                                                   % Swap the 1/N factor convention in the inverse Fourier
    spec = cellfun(@times, spec, repmat({1/sz(1)},size(spec)),'UniformOutput',0);              
    if doLog, memri = memri_log(memri, 'memri_fft: Corrected for (1/N) in FTT.'); end
end

% // --- Set Output

% Return cell-output if cell-input
if ~wasCell
    spec = cell2mat(spec); if numel(sz) <= 2, spec = squeeze(spec); end
end

% LOG & Output
if doLog
    memri.data = spec; memri.nfo.domain = 2;
    memri = memri_log(memri, 'memri_fft: Applied FFT to frequency domain.');
    spec = memri; % Return struct as output.
end
 


