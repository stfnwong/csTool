function pvOpts = init_genPvOpts(DATA_DIR, NO_LOAD)
% INIT_GENPVOPTS
%
% Generate an options structure for use with the csToolBufPreview GUI.
% This method attempts to read an options structure for the csToolBufPreview
% GUI saved in the data directory DATA_DIR. If no such file exists, a new
% structure is created.
%

% Stefan Wong 2013

	path = which(sprintf('%s/pvOpts.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No pvOpts file found, using defaults...\n');
		pvOpts = struct('loadFilename', 'data/settings/bufdata/frame-001.mat', ...
			            'saveFilename', 'data/settings/bufdata/frame-001.mat', ...
			            'loadRange', [1 1], ...
			            'saveRange', [1 1] );
		return;
	else
		fprintf('Loading pvOpts from %s', path);
		load(path);
		return;
	end


end 	%init_genPvOpts()
