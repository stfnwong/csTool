function chkStruct = checkFiles(filename, varargin)
% CHECKFILES
% chkStruct = checkFiles(filename, numFiles)
%
% Check that files in a numbered series exist.
%
% OUTPUTS
% checkFiles() outputs a check structure which contains the following fields
%
% exitflag - Status of the file check. -1 if check fails, 0 otherwise
%

% Stefan Wong 2013

	DSTR = 'checkFiles() :';
	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'frame', 5))
					NUM_FRAMES = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'sframe', 6))
					START_FRAME = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'vec', 3))
					NUM_VEC    = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'svec', 4))
					START_VEC  = varargin{k+1};
				end
			end
		end
	end

	% Check what we have and automatically set NUM_FRAMES to one
	% if NUM_VEC specified but NUM_FRAMES not
	if(exist('NUM_VEC', 'var') && ~exist('NUM_FRAMES', 'var'))
		NUM_FRAMES = 1;
	end
	if(~exist('NUM_VEC', 'var'))
		fprintf('% WARNING - no vector number specified, setting to 1\n', DSTR);
		NUM_VEC = 1;
	end
	if(~exist('START_FRAME', 'var'))
		START_FRAME = 1;
	end
	if(~exist('START_VEC', 'var'))
		START_VEC = 1;
	end

	exitflag = 0;
	ps       = fname_parse(filename);

	% Entered some bogus parameters
	if(NUM_FRAMES == 0 && NUM_VEC == 0)
		fprintf('WARNING: No lookahead specified for frame [%s], exiting\n', filename);
		chkStruct = struct('exitflag', -1, ...
		                   'errFrame', -1, ... 
			               'errVec', -1, ...
			               'errFile', filename );
		return;
	end

	% Check that options match parser output
	if(NUM_FRAMES > 1 && NUM_VEC > 1)	
		if(isempty(ps.frameNum))
			fprintf('ERROR: No frame field in filename [%s]\n',filename);
			exitflag = -1;
			errFrame = -1;
			errVec   = -1;
			errFile  = filename;
		elseif(isempty(ps.vecNum))
			fprintf('ERROR: No vector field in filename [%s]\n', filename);
			exitflag = -1;
			errFrame = -1;
			errVec   = -1;
			errFile  = filename;
		end
	elseif(NUM_FRAMES == 1 && NUM_VEC > 1)
		if(isempty(ps.vecNum))
			exitflag = -1;
			errFrame = 0;
			errVec   = 1;
			errFile  = filename;
		end
	elseif(NUM_FRAMES > 1 && NUM_VEC == 1)
		if(isempty(ps.frameNum))
			exitflag = -1;
			errFrame = 1;
			errVec   = -1;
			errFile  = filename;
		end
	end

	% Check file existence
	if(exitflag ~= -1)
		% Check files 
		for frameFile = START_FRAME : NUM_FRAMES
			for vecFile = START_VEC : NUM_VEC
				fn = sprintf('%s%s-frame%03d-vec%03d.%s', ps.path, ps.filename, START_FRAME, ps.vecNum, ps.ext);
				if(exist(fn, 'file') ~= 2)
					exitflag = -1;
					errFrame = frameFile;
					errVec   = vecFile;
					errFile  = fn;
					break;
				end
			end
		end
	end

	exitflag = 0;
	errFrame = [];
	errVec   = [];
	errFile  = [];

	chkStruct = struct('exitflag', exitflag, ...
					   'errFrame', errFrame, ...
					   'errVec',   errVec, ...
					   'errFile',  errFile );
	return;
	

end 	%checkFiles()
