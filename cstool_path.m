%% ADDPATH
% Add csTool to the current MATLAB path

cpath = cd;
if(~strncmpi(cpath(end-5:end), 'csTool', 6))
	error('Must be in csTool directory');
end

fprintf('Adding csTool to the search path...\n');
addpath(genpath(cd));
rehash
fprintf('...Done\n');
