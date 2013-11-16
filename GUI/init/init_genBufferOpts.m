function bufOpts = init_genBufferOpts(DATA_DIR, ASSET_DIR, NO_LOAD)
% INIT_GENBUFFEROPTS
%
% Generate an options structure for a csFrameBuffer object. For use with the csToolGUI
% This medthod attempts to read a saved structure in the directory DATA_DIR, and 
% failing that, creates a new structure with a set of default options.

% Stefan Wong 2013

	path = which(sprintf('%s/bufOpts.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No buffer options found - using defaults... \n');
		bufOpts = struct('nFrames',    32       , ...
                         'path',       ASSET_DIR, ...
                         'ext',        'TIF'    , ...
                         'fNum',       1        , ...
						 'fName',      ' '      , ...
			             'renderMode', 0        , ...
                         'verbose',    0 );
	else
		fprintf('Loading tracker options from %s...\n', path);
		load(path);
		return;
	end

end 	%init_genBufferOpts()
