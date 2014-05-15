function patternTestOpts = init_genPatternTestOpts(DATA_DIR, ASSET_DIR, NO_LOAD)
% INIT_GENTESTBUFFEROPTS
%
% Generate an options structure for a csFrameBuffer object. For use with the csToolGUI
% This medthod attempts to read a saved structure in the directory DATA_DIR, and 
% failing that, creates a new structure with a set of default options.

% Stefan Wong 2013

	path = which(sprintf('%s/patternTestOpts.mat', DATA_DIR));

	if(isempty(path) || NO_LOAD)
		fprintf('No buffer options found - using defaults... \n');
		patternTestOpts = struct('numBins', 16, ...
			                     'binWidth', 16, ...
			                     'dims', [640 480], ...
			                     'previewMode', 'test', ...
			                     'verbose', false, ...
			                     'genFilename', 'genfile.dat', ...
			                     'readFilename', 'readfile.dat');
	else
		fprintf('Loading tracker options from %s...\n', path);
		load(path);
		return;
	end

end 	%init_genPatternTestOpts()
