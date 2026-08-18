function memri = memri_noise(memri, varargin)
% Process noise data in the memri-struct and return an (updated) 
% noise-field with the noise covariance matrix.
% 
% If a noise-field is present
%       Check for noise-vectors:    either per voxel or only per channel
%                                   for the full volume.
%
% varargin = {'masksize', 64, 'independent', 0, 'noiseDomain', 1};
% Take diag of cov, remove co-var, keep var.
% request noiseDomain = 0, kspace, 1, time, 2, frequency
%
% If no noise ---> take 1/8 (total 25%) of each tail of the spectrum. Also
% use the masksize for generating noise from data
% Should ALSO be implemented if vectors are present but larger
%
% Requires memri.domain --> time or frequency domain noise            
% Otherwise creates a noise-field with noise generated from the data in
% memri.
%
% Quincy van Houtum, v02.2026
% quincyvanhoutum@gmail.com

% Check the memri data struct for noise-data and calculate a noise cov
% matrix.
% If no noise-data is present, will create noise per voxel from data. 
% If an FID noise measurement is given (no spatial dimensions: kx,ky,kz)

% // --- Handle input arguments and set options
opts = struct; 
opts.masksize = nan; opts.independent = 1; opts.noiseDomain = 1;
if nargin > 1
    for vi = 1:2:numel(varargin), opts.(varargin{vi}) = varargin{vi+1}; end
end

% // --- Calculate noise from data if noise-data is absent
if ~isfield(memri,'noise')  
    memri = memri_noise_fromData(memri, opts.masksize); 
    memri_log(memri,...
            'memri_noise: Generated noise-vectors from data in the frequency domain.');
end

% // --- Check noise domain
memri = memri_noise_domainCheck(memri, opts);

% // --- Process Averages (NSA)
% Concatenate the averages-index with the samples index.

noise = memri.noise.data;
ind_avg = findLabels(memri.noise.labels, 'aver');
if ~isnan(ind_avg)
    if ind_avg ~= 2 
        permv = 1:ndims(noise); permv([2 ind_avg]) = permv([ind_avg 2]);
        noise = permute(noise, permv);
    end
    
    % Reshape i.e. catenated averages to samples-dimension
    sz =  size(noise); nsz = num2cell(sz(3:end));
    noise = reshape(noise, sz(1) * sz(2), 1, nsz{:});
        
    % Permute back, only flip back 2 dims i.e. ipermute/permute equals
    noise = permute(noise, permv);
    memri = memri_log(memri,...
        'memri_noise: Noise sample averages concatenated.');
end


% // --- Check for spatial dimensions
ind_spat = findLabels(memri.labels, {'kx', 'ky', 'kz'});
doVol = 1; if sum(isnan(ind_spat)) == 3, doVol = 0; end


% // --- Calculate noiseCov
% Set dimension order: Samples x Channels x ...
[noise, noiseLabels] = ...
    sortByLabels(noise, memri.noise.labels, {'fid', 'chan'});

% Calculate noise cov.
if doVol % Volume
    if ~iscell(noise)
        noise = array2cell(noise,  noiseLabels, {'fid', 'chan'});
    end
    memri.noise.cov = cellfun(@cov, noise,'UniformOutput',0);
    
    % Remove all co-variances, keep variances: assume all coil channels are
    % independent.
    if opts.independent
        memri.noise.cov = cellfun(@(x) diag(diag(x)), memri.noise.cov, ...
            'UniformOutput',0);    
    end
    memri = memri_log(memri, ...
    'memri_noise: Calculated a separate noise-cov matrix for each voxel.');
else % FID
    memri.noise.cov = cov(noise);
    if opts.independent, memri.noise.cov = diag(diag(memri.noise.cov)); end
    memri = memri_log(memri, ...
        'memri_noise: Calculated a single noise-cov.');
end

end


function memri = memri_noise_domainCheck(memri, opts)
% Ensures the noise data domain is matched to the requested.

if opts.noiseDomain ~= memri.noise.domain    
% Noise domain not equal to requested noise-domain

    % Spatial indexes
    ind_spat = findLabels(memri.noise.labels, {'kx','ky','kz'});
    ind_spat(isnan(ind_spat)) = [];

    % Check domain state w.r.t. k-Space
    if opts.noiseDomain > 0 && memri.noise.domain == 0   
        
        % k-Space 2 time        
        memri.noise.data = ifft_spatial(memri.noise.data, ind_spat);
        memri.noise.domain = 1;
        memri = memri_log(memri,...
            'memri_noise: Applied spatial inverse FFT to noise-data (k-Space to time-domain). '); 

    elseif opts.noiseDomain == 0 && memri.noise.domain > 0
        
        if memri.noise.domain == 2
            % Frequency 2 time        
            memri.noise.data = memri_ifft(memri.noise.data);
            memri = memri_log(memri, ...
                'memri_noise: Applied inverse FFT to noise-data (frequency to time-domain).');  
        end

        if memri.noise.domain == 1
            % Time 2 k-Space
            memri.noise.data = fft_spatial(memri.noise.data, ind_spat);
            memri.noise.domain = 0;
            memri = memri_log(memri,...
                'memri_noise: Applied spatial FFT to noise-data (time-domain to k-Space).'); 
        end     

    end
        
    % Check domain state w.r.t. time and frequency
    if opts.noiseDomain == 2 && memri.noise.domain == 1 
        % Time 2 frequency
        memri.noise.data = memri_fft(memri.noise.data); 
        memri = memri_log(memri,...
            'memri_noise: Applied FFT to noise-data (time to frequency-domain).');
    elseif opts.noiseDomain == 1 && memri.noise.domain == 2
        % Frequency 2 time
        memri.noise.data = memri_ifft(memri.noise.data); 
        memri = memri_log(memri,...
            'memri_noise: Applied inverse FFT to noise-data (frequency to time-domain).');
    end

end

end