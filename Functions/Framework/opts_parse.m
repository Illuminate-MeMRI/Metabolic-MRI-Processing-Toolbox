function val = opts_parse(opts, val)
% Parse the input for methods: assumes string and returns according to
% opts.type.
%
%
% Seperated to allow easy future additions of file types if necessary.

switch opts.type
    case 'int'                                
        val = int64(str2double(val));
    case 'float'
        val = str2double(val);                            
end

end