function vfOpts = init_genVfOpts(DATA_DIR, NO_LOAD)
% INIT_GENVFOPTS
%
% Generate an options structure for use with the csToolVerify GUI.
% This method attempts to read an options structure for the csToolVerify
% GUI saved in the data directory DATA_DIR. If no such file exists, a new
% structure is created.
%

% Stefan Wong 2013

	path = which(sprintf('%s.vfOpts.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No vfOpts file found, using defaults...\n');
		vfOpts = struct('filename', 'data/testing/psygen/psygen-frame001-vec001.dat', ...
			            'orientation', 'scalar', ...
			            'vsize', 1, ...
			            'vtype', 'backprojection', ...
			            'dims', [640 480] );
		return
	else
		fprintf('Loading vfOpts from %s\n', path);
		load(path);
		return;
	end

end 	%init_genVfOpts()
