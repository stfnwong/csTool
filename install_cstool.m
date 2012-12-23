%% INSTALLER SCRIPT FOR CSTOOL
%
% Install the csTool environment. This file sets up paths to the csTool classes and
% saves path changes. To install, run this file from the current directory. 
%
% cd into /home/user/path_to_csTool at the MATLAB prompt and type:
% 'install_cstool' (on windows, this will be some long winded path like 
% C:\Documents and Settings\Users\user\path_to_cstool\
%

% Stefan Wong 2012

cpath = cd;
if(~strncmpi(cpath(end-5:end), 'csTool', 6))
	error('Command must be run from csTool directory');
end
fprintf('\n---------------------------------------------------------------\n');
fprintf('* * * * WELCOME TO CSTOOL * * * * \n');
fprintf('Adding csTool paths to MATLAB search path....\n');
addpath(genpath(cd));
rehash
fprintf('...Done\n');
inp = input('Save path changes? (y/n):', 's');
if(strncmpi(inp, 'y', 1))
	savepath;
end
fprintf('\n');
%END OF INSTALL
fprintf('csTool install complete.\n');
fprintf('\n---------------------------------------------------------------\n');

