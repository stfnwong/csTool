function trackOpts = init_genTrackerOpts(DATA_DIR, NO_LOAD)
% INIT_GENTRACKEROTPS
%
% Generate an options structure for a csTracker object. For use with the csToolGUI.
% This method attempts to read a save structure in the directory DATA_DIR, and failing
% that, creates a new structure with a set of default options

% Stefan Wong 2013

	path = which(sprintf('%s/trackOpts.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No saved buffer options - using defaults...\n');
		trackOpts = struct('method',      1 , ...
                           'verbose',     1 , ...
                           'rotMatrix',   1 , ...
                           'fParams',     [], ...
                           'cordicMode',  0 , ...
                           'bpThresh',    0 , ...
                           'fixedIter',   1 , ...
                           'maxIter',     16, ...
                           'epsilon',     [], ...
                           'sparseFac',   4,  ...
                           'sparseAnch',  1,  ...
                           'wsizeMethod', 1,  ...
                           'wsizeCont',   0,  ...
                           'forceTrack',  0,  ...
                           'predWindow',  0);
	else
		fprintf('Loading tracker options from %s... \n', path);
		load(path);
		return;
	end 

end 	%init_genTrackerOpts()
