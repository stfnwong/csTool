function opts = init_parseOptionStructs(noLoad)
% INIT_PARSEOPTIONSTRUCT
% Attempt to load options structures from disk. If no mat files are
% present, create a new set of options using default values
%
% ARGUMENTS:
%
% OUTPUTS:
% opts - Structure whose fields contain the option strucutures for each object

% Stefan Wong 2013

	global DATA_DIR;
	global ASSET_DIR;

	path = which(sprintf('%s/bufOpts.mat', DATA_DIR));
	if(isempty(path) || noLoad)
		fprintf('No saved buffer options - using defaults....\n');
		opts.bufOpts      = struct('nFrames',     32, ...
								   'path',        ASSET_DIR, ...
								   'ext',         'TIF', ...
								   'fNum',        1, ...
								   'verbose',     1);
	else
		fprintf('Loading buffer options from %s...\n', path);
		opts.bufOpts     = load(path);
	end
	
	path = which(sprintf('%s/segOpts.mat', DATA_DIR));
	if(isempty(path) || noLoad)
		fprintf('No saved segmenter options - using default...\n');
	    opts.segOpts      = struct('dataSz',      256, ...
                                   'blkSz',       16, ...
                                   'nBins',       16, ...
                                   'fpgaMode',    0, ...
                                   'method',      1, ...
                                   'mhist',       zeros(1,16), ...
                                   'imRegion',    [], ...
                                   'verbose',     1);
	else
		fprintf('Loading segmenter options from %s...\n', path);
		opts.segOpts      = load(path);
	end
	
	path = which(sprintf('%s/trackOpts.mat', DATA_DIR));
	if(isempty(path) || noLoad)
		fprintf('No saved tracker options - using default...\n');
		opts.trackOpts    = struct('method',      1, ...
								   'verbose',     1, ...
								   'rotMatrix',   0, ...
								   'fParams',     [], ...
								   'cordicMode',  0, ...
								   'bpThresh',    0, ...
								   'fixedIter',   1, ...
								   'maxIter',     16, ...
								   'epsilon',     []);
	else
		fprintf('Loading tracker options from %s...\n', path);
		opts.trackOpts    = load(path);
	end
	
	path = which(sprintf('%s/regionStruct.mat', DATA_DIR));
	if(isempty(path) || noLoad)
		fprintf('No saved region structure - using default...\n');
		opts.regionStruct = struct('start_point', [], ...
                               'end_point',   [], ...
                               'imRegion',    [] );
	else
		fprintf('Loading region struct from %s...\n', path);
		opts.regionStruct = load(path);
	end
	
	% DEBUG
	disp(opts)
	disp(opts.trackOpts)

end		%init_parseOptionStructs()

