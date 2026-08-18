function memri = memri_average(memri)
% Average MRS data in memri-struct if dimension "aver" is available.

nsa_ind = findLabels(memri.labels, {'aver'});
if ~isnan(nsa_ind)
    % Average and excl nan-values
    memri.data = mean(memri.data, nsa_ind, 'omitnan');
    
    % LOG
    memri = memri_log(memri, ...
        'memri_average: Averaged over the "aver" dimension.');
else
    memri = memri_log(memri, ...
        'memri_average: No "aver" dimension available. Skipped.');
end