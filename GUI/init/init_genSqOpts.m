function sqOpts = init_genSqOpts(DATA_DIR, NO_LOAD)
% INIT_GENSQ
%
% Generate an options structure for use with the csToolSeqGen GUI
% This method attempts to read an options structure for the csToolSeqGen
% GUI saved in the data directory DATA_DIR. If no such file exists, a new
% structure is created.
%

% Stefan Wong 2013

	path = which(sprintf('%s/sqOpts.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No sqOpts file found, using defaults...\n');
		sqOpts = struct('imsz', [640 480], ...
			            'nframes', 64, ...
			            'maxspd', 32, ...
			            'dist', 'normal', ...
			            'npoints', 128, ...
			            'sfac', 1, ...
			            'wRes', 1, ...
			            'tsize', [64 64], ...
			            'loc', 0.5*[640 480], ... 
			            'theta', 0);
	else
		fprintf('Loading sqOpts from %s\n', path);
		load(path);
	end

end 	%init_genSqOpts()
