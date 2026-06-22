function memri = memri_hamming_correction(memri)  
% Apply the hamming_correction function to the data if data array is 3D and
% the averages dimension is available.

% Required input
ind_spat = findLabels(memri.labels, {'kx', 'ky', 'kz'});
ind_aver = findLabels(memri.labels, {'aver'});

% Only applicable if it is a 3D data array and NSA > 1.
if sum(isnan(ind_spat)) ~= 3 && ~isnan(ind_aver)
    % Apply hamming correction
    memri.data = hamming_correction(memri.data, ind_spat, ind_aver);

    % Write to log
    memri = memri_log(memri, 'memri_script: Corrected for the hamming acquisition window.');
else
    memri = memri_log(memri, 'Hamming correction: Data is not 3D nor does it include averages.');
end