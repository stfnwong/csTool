function segOpts = init_genSegmenterOpts(DATA_DIR, NO_LOAD)
% INIT_GENSEGMENTEROPTS
%
% Generate an options structure for a csSegmenter object. For use with the csToolGUI. 
% This method attempts to a read a saved structure in the directory DATA_DIR, and
% failing that, creates a new structure with a set of default options.

% Stefan Wong 2013

	path = which(sprintf('%s/segOpts.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No segmenter options found - using defaults...\n');
		segOpts = struct('dataSz',   256        , ...
                         'blkSz',    16         , ...
                         'nBins',    16         , ...
                         'fpgaMode', 0          , ...
                         'bpThresh', 0          , ...
                         'method',   1          , ...
                         'mhist',    zeros(1,16), ...
                         'imRegion', []         , ...
                         'verbose',  0  );
	else
		fprintf('Loading segmenter options from %s...\n');
		load(path);
		return;
	end
		

end 	%init_genSegmenterOpts()
