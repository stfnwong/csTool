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
% TODO : Modify this function in a similar manner to fname_parse() (ie: split the FRAME_IDX and VEC_IDX functions and provide a 'framebuf' option

% Stefan Wong 2013

	DSTR        = 'checkFiles() :';
	NUM_FRAMES  = 1;
	NUM_VEC     = 1;
	START_FRAME = 1;
	START_VEC   = 1;
	CHECK_VEC   = false;
	FRAME_BUF   = false;
	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'nframe', 5))
					NUM_FRAMES = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'sframe', 6))
					START_FRAME = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'nvec', 3))
					NUM_VEC    = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'svec', 4))
					START_VEC  = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'vcheck', 6))
					CHECK_VEC = true;
				elseif(strncmpi(varargin{k}, 'framebuf', 8))
					FRAME_BUF = true;
				end
			end
		end
	end

	% Entered some bogus parameters
	if(NUM_FRAMES == 0 && NUM_VEC == 0)
		fprintf('WARNING: No lookahead specified for frame [%s], exiting\n', filename);
		chkStruct = struct('exitflag', -1, ...
		                   'errFrame', -1, ... 
			               'errVec', -1, ...
			               'errFile', filename );
		return;
	end

	exitflag = 0;

	if(FRAME_BUF)
		% NUM_VEC option not required
		errFrame = [];
		errVec   = [];
		errFile  = [];
		ps = fname_parse(filename, 'framebuf');
		if(ps.exitflag == -1)
			fprintf('%s ERROR : Couldn''t parse filename [%s]\n', DSTR, filename);
			exitflag = -1;
			errFrame = -1;
			errFile  = filename;
		end
		if(isempty(ps.frameNum))
			fprintf('ERROR: No number in filename [%s]\n', filename);
			exitflag = -1;
			errFrame = -1;
			errFile  = filename;
		end

		if(exitflag ~= -1)
			frameNum = START_FRAME;
			while(frameNum < NUM_FRAMES)
				fn = sprintf('%s%s%03d.%s', ps.path, ps.filename, frameNum, ps.ext);
				if(exist(fn, 'file') ~= 2)
					exitflag = -1;
					errFrame = frameNum;
					errFile  = fn;
					break;
				end
				frameNum = frameNum + 1;
			end
		end

		chkStruct = struct('exitflag', exitflag, ...
						   'errFrame', errFrame, ...
						   'errVec',   errVec, ...
						   'errFile',  errFile);
		return;
	end
	
	% Non-frambuf parse
	ps = fname_parse(filename);
	if(ps.exitflag == -1)
		fprintf('%s ERROR : Couldn''t parse filename [%s]\n', DSTR, filename);
		exitflag = -1;
	end

	% Check that options match parser output
	if((NUM_FRAMES > 1) && (NUM_VEC > 1))
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

	% With two while loops
	if(exitflag ~= -1)
		exitflag  = 0;
		errFrame  = [];
		errVec    = [];
		errFile   = [];
		frameFile = START_FRAME;
		noErr     = true;

		while(frameFile <= NUM_FRAMES && noErr)
            vecFile = START_VEC;
			% TODO : This loop is clunky - rewrite!
			if(CHECK_VEC)
				while(vecFile <= NUM_VEC && noErr)
					fn = sprintf('%s%s-frame%03d-vec%03d.%s', ps.path, ps.filename, frameFile, vecFile, ps.ext);
					if(exist(fn, 'file') ~= 2)
						exitflag = -1;
						errFrame = frameFile;
						errVec   = vecFile;
						errFile  = fn;
						noErr    = false;
					end
					vecFile = vecFile + 1;

				end
			else
				fn = sprintf('%s%s-frame%03d.%s', ps.path, ps.filename, frameFile, ps.ext);
				if(exist(fn, 'file') ~= 2)
					exitflag = -1;
					errFrame = frameFile;
					errVec   = [];
					errFile  = fn;
					noErr    = false;
				end
				frameFile = frameFile + 1;
			end
		end
	end

	% Generate output structure
	chkStruct = struct('exitflag', exitflag, ...
					   'errFrame', errFrame, ...
					   'errVec',   errVec, ...
					   'errFile',  errFile );
	return;
	

end 	%checkFiles()
