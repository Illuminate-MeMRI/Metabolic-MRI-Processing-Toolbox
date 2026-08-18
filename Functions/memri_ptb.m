function memriptb(filepath_or_struct)
% Object-oriented-programming of apps in Matlab is different from the GUIDE
% implentation. With GUIDE, one could call the GUI-function again even if
% the GUI was openened, and it would run the openfnc thus processing new
% input arguments again.
% With OOP however, the GUI being a class not a function, calling it with 
% new input will NOT run startfnc again (as per OOP convention) if the app 
% is already opened/running.
%
% This script makes it easier to keep calling the GUI from command line or
% scripts - without the long name and with the options to use current GUI
% instance.
%
% Plus, I (the dev) dont like the long name to call the app ;)

if nargin == 0, filepath_or_struct = []; end

% Check for running instance of MeMRI PTB GUI
fobj = findall(0, 'type', 'figure', 'tag', 'memriptbgui');
if isempty(fobj)
    MeMRI_Processing_GUI(filepath_or_struct);
else
    memriptbgui = fobj.RunningAppInstance;
    memriptbgui.updateInput(filepath_or_struct);
end