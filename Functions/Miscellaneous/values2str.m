function vals = values2str(vals)
% Returns a (combined) string of the given value or list of values and uses
% the longE format (2e-02) in string format for values with decimals only.
%
% Value examples: 0.00002441 --> '2.44e-05'; 5.0002314 --> 5.00
% 
% Format: %3.2fe0N with N = #decimals, %3.0f for int and %3.2f for float.
% 
% NB. If the input is a cell-string, a single string is returned.
%
% Q. v Houtum, v1.0 12.2019

% Get cell content
if iscell(vals), vals = num2cell(vals); end
% If vals is a list of values
vals = cellfun(@(x) val2str(x), num2cell(vals), 'UniformOutput',false);

% Convert to single string-output (in case of multiple values)
if numel(vals) > 1, vals = strjoin(vals, ' '); else, vals = vals{:}; end

end

% Convert to proper value
function val = val2str(val)
% Convert a number to a string 

[Nzeros, acc] = numzeros(abs(val),32); 
prefix = '0'; if Nzeros >= 10, prefix = ''; end
% Check for any integer part
if Nzeros <= 0 || Nzeros == acc
    if mod(val, 1) ~= 0, val = sprintf('%3.2f', val);
    else,                val = sprintf('%0.0f', val);
    end
else
    val = sprintf('%3.2fe-%s%i', val*10.^(Nzeros+1), prefix, Nzeros+1);
end

end
