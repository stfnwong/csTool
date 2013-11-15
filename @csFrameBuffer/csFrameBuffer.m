classdef csFrameBuffer
% CSFRAMEBUFFER
%
% Frame buffer object for camshift tracker. This object contains handles to all the
% frames to be used in the segmentation and tracking test. 
%
% PROPERTIES
%
% frameBuf - 
% nFrames  - 
% msVec    - 
% path     -
% ext      - 
% fNum     - 
% verbose  - 
%
% METHODS
%
% fb = csFrameBuffer(...) [Constructor] 
% Create a new csFrameBuffer object. Calling the constructor with no arguments will
% create a new csFrameBuffer with the default initialisation. Pass in an options 
% structure to override default setup
%
% setPath
%
% setNFrames
%
%
% getFrameHandle
%
% loadFrameData
%
% See also csFrame, csSegmenter, csTracker
% 

% Stefan Wong 2012

%TODO: 
% - How to store meanshift vectors? It seems like we just need a routine that can 
%   go through all the frame parameters and produce v(f) - v(f-1) for each one...

	properties (SetAccess = 'private', GetAccess = 'private')
		frameBuf;		%array of csFrame handles
		nFrames;		%number of elements in frameBuf
		msVec;			%Meanshift vectors for each frame (ie: how much target moved)
		path;			%Path to frame data
		ext;			%File extension for frame data
		fName;			%filename 
		fNum;			%Which frame to start reading from 
		renderMode;		% (ENUM) Read file from disk or genBP Img
		% NOTE (renderMode) This effectively acts as an enum that 
		% determines which kind of data getCurImg() will return
		%verbose;		%Be verbose
	end

	properties (SetAccess = 'private', GetAccess = 'public')
		verbose;		%Be verbose (show debug messages)
	end

	% ---- PUBLIC METHODS ---- %
	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function fb = csFrameBuffer(varargin)
		% CSFRAMEBUFFER
		% Create new csFrameBuffer object. If no options struct is supplied, the 
		% resulting csFrameBuffer object will be initialised to have the following 
		% values:
		%
		% 	frameBuf   = csFrame()
		% 	nFrames    = 0
		% 	path       = ' '
		% 	ext        = 'tif'
		% 	fNum       = 1;
		% 	fName      = ' '
		% 	renderMode = 0;
		% 	verbose    = 0;
		%
		% To initialise the csFrameBuffer object with different options, pass in a 
		% structure with members whose names match the properties of the csFrameBuffer
		%
		% USAGE:
		% F = csFrameBuffer();
		% F = csFrameBuffer(opts_struct);
		%
		% See classdef documentation for further information about methods and 
		% properties for this class.

			switch nargin
				case 0
					%Default initialisation
					fb.frameBuf   = csFrame();
					fb.nFrames    = 0;
					fb.path       = ' ';
					fb.ext        = 'tif';
					fb.fNum       = 1;
					fb.fName      = '';
					fb.renderMode = 0;
					fb.verbose    = 0;
				case 1
					%Object copy case
					if(isa(varargin{1}, 'csFrameBuffer'))
						fb = varargin{1};
					%elseif(iscell(varargin{1}))
					else
						%assume this is an option structure and copy args
						opts = varargin{1};
						if(~isa(opts, 'struct'))
							error('Expecting options structure');
						end
						fb.frameBuf   = csFrame(); 
						fb.nFrames    = opts.nFrames;
						fb.path       = opts.path;
						fb.fNum       = opts.fNum;
						fb.fName      = opts.fName;
						fb.renderMode = opts.renderMode;
						fb.verbose    = fb.verbose;
						if(fb.verbose)
							fprintf('Verbose mode on\n');
						end
						%init buffer
						tpath = sprintf('%s_%03d', opts.path, opts.fNum);
						%if(csFrameBuffer.bufMemCheck(opts.nFrames, tpath))
						%	fprintf('WARNING: Buffer may exhaust memory\n');
						%end
						for n = opts.nFrames:-1:1
							t_buf(n) = csFrame();
						end
						fb.frameBuf = t_buf;
						%Use default extension
						fb.ext      = 'tif';
					end
				case 2
					%Assume second arg is struct?
					opts = varargin{1};
					if(~isa(opts, 'struct'))
						error('Expecting options structure');
					else
						fprintf('Got an options structure\n');
					end
					% TODO :  Drop this, it'll never happen
				otherwise
					error('Incorrect constructor options');
			end
		end 	%csFrameBuffer CONSTRUCTOR

		% -----------------------------------%
		% -------- GETTER FUNCTIONS -------- %
		% -----------------------------------%
		
		function ext = getExt(F)
		% GETEXT
		% Returns the current file extension type
			ext = F.ext;
		end 	%getExt()
		
		function n = getNumFrames(F)
		% GETNUMFRAMES
		% Returns the number of frame handles currently stored in the
		% buffer
			n = F.nFrames;
		end 	%getNumFrames()
		
		function path = getPath(F)
		% GETPATH
		% Return a string containing the current internal path
		
			path = F.path;
		end		%getPath()

		function rMode = getRenderMode(F)
			rMode = F.renderMode;
		end 	%getRenderMode()

		function opts = getOpts(F)
		% GETOPTS
		% Return an options structure. For csToolGUI.
			opts = struct('frameBuf',   F.frameBuf, ...
                          'nFrames',    F.nFrames,  ...
                          'path',       F.path,     ...
                          'ext',        F.ext,      ...
                          'fNum',       F.fNum,     ...
                          'fName',      F.fName,    ...
				          'renderMode', F.renderMode, ...
                          'verbose',    F.verbose );
		end 	%getOpts();

		function fh = getFrameHandle(F, N)
		% GETFRAMEHANDLE
		% USAGE : fh = getFrameHandle(N)
		% 
		% Obtain the handle to frame N. If N is a scalar, getFrameHandle returns a 
		% single handle to the Nth frame in the buffer. If N is a vector of intergers,
		% getFrameHandle returns an array containing handles for the corresponding 
		% frames
		%
			if(length(N) > 1)
				if(N(end) > F.nFrames)
					error('N out of bounds (N=%d, bufsize=%d)', N(end), F.nFrames);
				end
				for k = length(N):-1:1
					fh(k) = F.frameBuf(N(k));
				end
			else
				if(N > F.nFrames)
					error('N out of bounds (N=%d, bufsize=%d)', N, F.nFrames);
				end
				fh = F.frameBuf(N);
			end
		end 	%getFrameHandle()

		% ======== FRAME HANDLE WRAPPERS ======== %
		function fname = getFilename(FB, idx)
			fname = get(FB.frameBuf(idx), 'filename');
		end 	%getFilename()

		function params = getWinParams(FB, idx)
			params = get(FB.frameBuf(idx), 'winParams');
		end 	%getWinParams()

		function dims = getDims(FB, idx)
			dims = get(FB.frameBuf(idx), 'dims');
		end 	%getDims()

		function rhist = getRhist(FB, idx)
			rhist = get(FB.frameBuf(idx), 'rhist');
		end 	%getRhist()

		function ihist = getIhist(FB, idx)
			ihist = get(FB.frameBuf(idx), 'ihist');
		end 	%getIhist()

		function moments = getMoments(FB, idx)
			moments = get(FB.frameBuf(idx), 'moments');
		end 	%getMoments()

		function sp = getSparse(FB, idx)
			sp = get(FB.frameBuf(idx), 'isSparse');
		end 	%getSparse()

		function spfac = getSparseFac(FB, idx)
			spfac = get(FB.frameBuf(idx), 'sparseFac');
		end 	%getSparseFac()

		function bpsum = getBpSum(FB, idx)
			bpsum = get(FB.frameBuf(idx), 'bpSum');
		end 	%getBpSum()

		function status = hasBpData(FB, idx)
			if(get(FB.frameBuf(idx), 'bpsum') > 0)
				status = true;
			else
				status = false;
			end
		end 	%isBpData()

		function img = getCurImg(F, idx, varargin)
		% GETCURIMG
		% Return the image data for the frame at position idx consistent
		% with the mode specified by renderMode.
		%
			RETURN_IMG       = true;
			RETURN_3_CHANNEL = false;
			GET_BPIMG_ONLY   = false;
			GET_IMG_ONLY     = false;

			if(~isempty(varargin))
				for k = 1 : length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{1}, 'vec', 3))
							RETURN_IMG = false;
						elseif(strncmpi(varargin{k}, '3chan', 5))
							RETURN_3_CHANNEL = true;
						elseif(strncmpi(varargin{k}, 'bpimg', 5))
							GET_BP_IMG_ONLY = true;
						elseif(strncmpi(varargin{k}, 'img', 3))
							GET_IMG_ONLY = true;
						end
					end
				end
			end

			% Bounds check idx
			if(idx < 1 || idx > length(F.frameBuf))
				img = [];
				if(F.verbose)
					fprintf('ERROR: idx %d out of bounds\n', idx);
				end
				return;
			end

			fh = F.frameBuf(idx);

			if(GET_IMG_ONLY)
				img  = imread(get(fh, 'filename'), F.ext);
				dims = size(img);
				if(dims(3) > 3)
					img = img(:,:,1:3);
				end
				return;
			end

			if(GET_BPIMG_ONLY && RETURN_3_CHANNEL)
				img = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'), '3chan');
				return;
			end

			if(GET_BPIMG_ONLY)
				img = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'));
				return;
			end

			% Get image based on renderMode
			switch(F.renderMode)
				case 0
					% Read image from disk and return img file
					img = imread(get(fh, 'filename'), F.ext);
					dims = size(img);
					if(dims(3) > 3)
						img = img(:,:,1:3);
					end
					return;
				case 1
					% Read image from bpVec and return image file
					img = get(fh, 'bpVec');
					if(RETURN_IMG)
						if(RETURN_3_CHANNEL)
							img = vec2bpimg(img, 'dims', get(fh, 'dims'), '3chan');
						else
							img = vec2bpimg(img, 'dims', get(fh, 'dims'));
						end
					end
					return;
				otherwise
					if(F.verbose)
						fprintf('ERROR: Invalid renderMode %d\n', F.renderMode);
					end
					img = [];
					return;
			end
						
			
		end 	%getCurImg()

        function printFrameContents(F, varargin)
		% PRINTFRAMECONTENTS
		%
		% Shows in console the values assigned to fields of the frame
		% handles currently in the buffer. Call with no arguments to show
		% values for all frames in the buffer. Call with a scalar or vector
		% to show the values for a single frame or range of frames
		
			if(isempty(varargin))
				N = varargin{1};
			else
				N = F.Frames;
			end
            %Loop over all frame handles in buffer and show contents
			if(length(N) > 1)
				for k = N(1):N(end)
					disp(F.frameBuf(k));
				end
			else
				disp(F.frameBuf(N));
			end
			
        end     %printFrameContents
		
		function path = showPath(fb, varargin)
		% SHOWPATH
		%
		% Show the value of the internal path variable. NOTE: This function
		% is deprecated, use getPath(), getNumFrames(), and getExt() instead
			
			error(nargchk(1,3,nargin));
			if(nargin == 1)
				path = sprintf('%s_%03d.%s', fb.path, fb.fNum, fb.ext);
			else
				if(ischar(varargin{1}))
					%Check which path to return
					if(strncmpi(varargin{1}, 'start', 5))
						path = sprintf('%s', fb.frameBuf(1).filename);
					elseif(strncmpi(varargin{1}, 'end', 3))
						path = sprintf('%s', fb.frameBuf(end).filename);
					else
						error('Unrecognised option');
					end
				else
					error('Optional argument must be string');
				end
			end
		end

		function filename = showFilename(FB, varargin)
		% SHOWFILENAME
		% Assemble the filename from the string components in the 
		% csFrameBuffer object
		% 
		% The filename is reconstructed according to the pattern below:
		%
		% path -> fName -> '_' -> fNum -> ext
		%
		% which is concatenated into the string filename.

			%Parse path at the end. That way if the files are in the 
			%current directory we just don't bother concatenating the path 
			%on at the start
			filename = strcat(FB.fName, '_', FB.fNum, FB.ext);
			if(~isempty(FB.path))
				filename = strcat(FB.path, filename);
			end

		end 	%showFilename

		% -------- GETTRAJ -------- %
		function traj = getTraj(F, varargin)
		% GETTRAJ
		% Get the trajectory for the frames in the specified range. 
		% If the no range is specified, get the trajectory for all 
		% frames in the buffer

			if(~isempty(varargin))
				range = varargin{1};
			end

			%Bounds check range, or create if it doesn't exist
			if(~exist('range', 'var'))
				range = [1 F.nFrames];
			else
				if(length(range) == 1)
					if(range > F.nFrames)
						fprintf('range exceeds bounds, truncating...\n');
						range = [1 F.nFrames];
					elseif(range < 1)
						fprintf('ERROR: Must be positive integer\n');
						traj = [];
						return;
					end
				else
					if(range(2) > F.nFrames)
						fprintf('range exceeds bounds, truncating...\n');
						range = [1 F.nFrames];
					elseif(range(2) < 1)
						fprintf('ERROR: Must be positive integer\n');
						traj = [];
						return;
					end
				end
			end

			traj = zeros(2, length(range(1):range(2)));
			n    = 1;
			for k = range(1):range(2)
				fh = F.frameBuf(k);
				wp = get(fh, 'winParams');
				%traj(1,n) = wp(1);
				%traj(2,n) = wp(2);
				traj(:,n) = [wp(1) ; wp(2)];
                n = n + 1;
			end

		end 	%getTraj()
		
		% ---------------------------------- %
		% -------- SETTER FUNCTIONS -------- %
		% ---------------------------------- %
	
		function FB = setFrameParams(FB, idx, varargin)
		% SETFRAMEPARAMS
		% Set parameters for the frame at location idx

			% Bounds check idx
			if(idx < 1 || idx > FB.nFrames)
				fprintf('ERROR: idx outside range 1 - %d\n', FB.nFrames);
				return;
			end

			if(isempty(varargin))
				fprintf('(setFrameParams) : No param data\n');
				return;
			end

			for k = 1 : length(varargin)
				if(ischar(varargin{k}))
					if(strncmpi(varargin{k}, 'img', 3))
						set(FB.frameBuf(idx), 'img', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'bpimg', 5))
						set(FB.frameBuf(idx), 'bpImg', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'bpvec', 5))
						set(FB.frameBuf(idx), 'bpVec', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'bpsum', 5))
						set(FB.frameBuf(idx), 'bpSum', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'rhist', 5))
						set(FB.frameBuf(idx), 'rhist', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'ihist', 5))
						set(FB.frameBuf(idx), 'ihist', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'winparam', 8))
						set(FB.frameBuf(idx), 'winParams', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'wininit', 6))
						set(FB.frameBuf(idx), 'winInit', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'moments', 7))
						set(FB.frameBuf(idx), 'moments', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'niters', 5))
						set(FB.frameBuf(idx), 'nIters', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'tvec', 4))
						set(FB.frameBuf(idx), 'tVec', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'dims', 4))
						set(FB.frameBuf(idx), 'dims', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'sparse', 6))
						set(FB.frameBuf(idx), 'isSparse', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'spfac', 5))
						set(FB.frameBuf(idx), 'sparseFac', varargin{k+1});
					elseif(strncmpi(varargin{k}, 'filename', 8))
						set(FB.frameBuf(idx), 'filename', varargin{k+1});
					end
				end
			end

		end 	%setFrameParams()

		function [FB] = initFrameBuf(FB, bufSize)
		% INITFRAMBUF
		% Initialise framebuffer to the size bufSize. If no
		% size is specified, frameBuffer is initialised to size 1

			if(isempty(bufSize) || bufSize == 0)
				bufSize = 1;
			end
			
			for n = bufSize:-1:1
				fr(n) = csFrame();
			end
			FB.frameBuf = fr;

		end 	%initFrameBuf()

		function [FB] = clearImHist(FB, fIndex)
		% CLEARIMHIST
		% Clear the image histogram property of the frame handle at index fIndex. If
		% fIndex is a vector, all frame handles in the vector are cleared
		
			if(length(fIndex) > 1)
				for k = 1:fIndex(1):fIndex(end)
					set(FB.frameBuf(k), 'ihist', []);	
				end
			else
				set(FB.frameBuf(fIndex), 'ihist', []);
			end

		end 	%clearImHist

		function [FB status] = parseFilename(FB, fname, varargin)
		% PARSEFILENAME
		% This method parses the filename specified by fname and sets the correct
		% values in FB.path, FB.fName, FB.fNum, and FB.ext. The returned status flag
		% indicates whether or not the filename was parsed correctly. The caller can
		% consider the values as set when status returns 0 (no errors).
		% 

			if(~ischar(fname))
				error('Filename must be string');
			end
			if(FB.verbose)
				vb = 'd';
			else
				vb = 'x';
			end
			[exitflag str num fext fpath] = fname_parse(fname, vb);
			%if(FB.verbose)
			%	%[str num ext path exitflag] = fname_parse(fname, 'd')
			%	[exitflag str num ext path] = fname_parse(fname, 'd');
			%else
			%	%[str num ext path exitflag] = fname_parse(fname)
			%	[exitflag str num ext path] = fname_parse(fname);
			%end
			if(exitflag == -1)
				%Check what fields we do have
				if(isempty(fext))
					status = -1;
					%FB     = FB;
					return;
				end
			else
				FB.ext   = fext;
			end	
			FB.fName = str;
			FB.fNum  = num;
			FB.path  = fpath;
			status   = 0;
			return;

		end 	%parseFilename()
		
        function FB = setPath(FB, path)
		% SETPATH
		% 
		% Alter the path to files stored locally in the csFrameBuffer
		% object. 
        
            if(~ischar(path))
                error('Path must be string');
            end
            FB.path = path;
		end
		
		function FB = setNFrames(FB, nFrames)
		% SETNFRAMES
		%
		% Set the number of frames N stored locally in the csFrameBuffer
		% object. If this method is called, the internal buffer will be
		% re-allocated, overwriting any prevously held frame handles.
			
			%Estimate memory usage
% 			if(isempty(FB.path) || ~ischar(FB.path))
% 				fprintf('WARNING: Path not set, cannot estimate memory usage\n');
% 			else
% 				tpath = sprintf('%s_%03d', FB.path, FB.fNum);
% 				if(csFrameBuffer.bufMemCheck(nFrames, tpath))
% 					fprintf('WARNING: %d frames likely in GB range\n', nFrames);
% 					fprintf('Estimated size : %d bytes\n', mem/8);
% 				end
% 			end
			FB.nFrames = nFrames;
			%Re-allocate buffer
			for n = nFrames:-1:1
				t_buf(n) = csFrame();
			end
			if(FB.verbose)
				fprintf('Reallocated buffer to size %d\n', FB.nFrames);
			end
			FB.frameBuf = t_buf;
			
		end

		function FB = setRenderMode(FB, rMode)
			FB.renderMode = rMode;
		end 	%setRenderMode()

		function FB = setVerbose(FB, verbose)
			FB.verbose = verbose;	
		end 	%setVerbose()
		
		% -----------------------------------%
		%         PROCESSING FUNCTIONS       %
		% -----------------------------------%
		
		function [FB status varargout] = loadFrameData(FB, varargin)
		% LOADFRAMEDATA
		%
		% [FB status] = loadFrameData(FB, ...[options]... )
		%
		% Load filenames specified by FB.path and FB.fNum into frame buffer. To
		% override the path, pass the string 'path' followed by the path name. To
		% override fNum, pass 'num' followed by number of frames to read.
		
			ALL = false;
			%If varargin is a string, take this as being a path to data and 
			%use in place of FB.path
			if(nargin > 1)
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'path', 4))
							fpath = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'num', 3))
							fnum  = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'all', 3))
							ALL = true;
						elseif(strncmpi(varargin{k}, 'fname', 5))
							fullName = varargin{k+1};
						end
					end
				end
			end
			%Catch unmodified variables
			if(~exist('fpath', 'var'))
				fpath = FB.path;
			end
			if(~exist('fnum', 'var'))
				%Ensure that fnum is numeric
				if(ischar(FB.fNum))
					fnum = str2double(FB.fNum);
				else
					fnum = FB.fNum;
				end
			end

			%Check parameters are sensible
			if(isempty(fpath) || ~ischar(fpath))
				fprintf('Path not correctly set, exiting...\n');
				status = -1;
				return;
			end
			if(isempty(FB.ext) || ~ischar(FB.ext))
				fprintf('Extension not correctly set, exiting...\n');
				status = -1;
				return;
			end

			if(FB.verbose)
				fprintf('fpath: %s\n', fpath);
				fprintf('fName: %s\n', FB.fName);
				fprintf('fnum : %d\n', fnum);
				fprintf('ext  : %s\n', FB.ext);
			end
			%If we want to load all frames in buffer, check how many there are and 
			%place this figure into FB.nFrames
			if(ALL)
				n  = 1;
				%fn = sprintf('%s%s_%03d.%s', fpath, FB.fName, n, FB.ext); 
				fn = sprintf('%s%s%03d.%s', fpath, FB.fName, n, FB.ext); 
				while(isequal(exist(fn, 'file'), 2))
					set(FB.frameBuf(k), 'filename', fn);
					if(FB.verbose)
						fprintf('Read frame %3d in sequence\n', n);
					end
					n  = n+1;
					fn = sprintf('%s%s%03d.%s', fpath, FB.fName, n, FB.ext);
				end
				if(n == 1)
					fprintf('ERROR: Start file does not exist (%s)\n', fn);
					status = -1;
					return;
				end
				if(FB.verbose)
					fprintf('Read %d frmaes from %s\n', n, fpath);
				end
				%Also report the number of frames read, if required
				if(nargout > 2)
					varargout{1} = n;
				end
				FB.nFrames = n;
			else
				%Load data into buffer
				for k = 1:FB.nFrames
					fn   = sprintf('%s%s%03d.%s', fpath, FB.fName, fnum, FB.ext); 
					set(FB.frameBuf(k), 'filename', fn);
					if(FB.verbose)
						fprintf('Read frame %3d of %3d (%s) \n', k, FB.nFrames, fn);
					end
					fnum = fnum + 1;
			end
			end
			if(FB.verbose)
				fprintf('\n File read complete\n');
				fprintf('Read %d frames\n', k);
			end
			%write back data
			FB.fNum       = fnum;
			FB.renderMode = 0;
            status        = 0;
			return;

		end 	%loadFrameData()

		function clearImData(F, varargin)
		% CLEARIMDATA
		% Set any image data in the buffer equal to the empty matrix. Pass a integer
		% N as an optional argument to clear only the data for the Nth frame, or a 
		% vector of integers to clear image data for frames N(1) to N(end). 
		
			if(nargin > 1)
				N = varargin{1};
				if(length(N) > 1)
					for k = N(1):N(end)
						set(F.frameBuf(k), 'img', []);
					end
				else
					set(F.frameBuf(N), 'img', []);
				end
			else
				for k = 1:F.nFrames
					set(F.frameBuf(k), 'img', []);
				end
			end
		end 	%clearImData()

		function F = genRandSeq(F, varargin)
		% GENRANDSEQ
		% Generate a sequence of random backprojection data for testing

			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'imsz', 4))
							imsz = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'nframes', 7))
							nframes = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'maxspd', 6))
							maxspd = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'dist', 4))
							dist = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'npoints', 7))
							npoints = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'sfac', 4))
							sfac = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'theta', 5))
							theta = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'opts', 4))
							opts = varargin{k+1};
						end
					end
				end
			end

			%Check what we have
			if(~exist('opts', 'var'))
				if(~exist('imsz', 'var'))
					imsz = [640 480];
				end
				if(~exist('nframes', 'var'))
					nframes = 64;
				end
				if(~exist('maxspd', 'var'))
					maxspd = 64;		%max distance in pixels to next frame
				end
				if(~exist('dist', 'var'))
					dist = 'normal';
				end
				if(~exist('npoints', 'var'))
					npoints = 200;
				end
				if(~exist('sfac', 'var'))
					sfac = 1;
				end
				if(~exist('theta', 'var'))
					theta = 0;
				end
				if(~exist('loc', 'var'))
					loc = fix(0.5.*[imsz(1) imsz(2)]);
				end

				if(F.verbose)
					fprintf('WARNING: Initialising frame buffer contents\n');
				end
				% generate options structure
				opts = struct('imsz', imsz, ...
							  'loc', loc, ...
							  'tsize', tsize, ...
							  'theta', theta, ...
					          'nframes', nframes, ...
					          'maxspd', maxspd, ...
							  'npoints', npoints, ...
							  'dist', dist, ...
							  'dscale', sfac, ...
							  'kernel', [] );
			else
				nframes = opts.nframes;
			end

			F  = initFrameBuf(F, nframes);
			wb = waitbar(0, sprintf('Generating frame (%d/%d)', 0, nframes), 'title', 'Generating Backprojection Sequence...');
			for N = 1:nframes
				% TODO : Put a waitbar here
				frame    = genRandFrame(F, opts);
				bpvec    = bpimg2vec(frame, 'bpval');
				% set parameter data for frame handle
				fname    = sprintf('bpgen-%03d.ext', N);
				set(F.frameBuf(N), 'filename', fname);
				set(F.frameBuf(N), 'bpVec', bpvec);
				set(F.frameBuf(N), 'bpSum', opts.npoints);
				set(F.frameBuf(N), 'dims', opts.imsz);
				%set(F.frameBuf(N), 'bpImg', frame);
				% generate position for new frame
				opts.loc = genRandPos(F, opts.loc, opts.maxspd, opts.imsz);
				waitbar(N/nframes, wb, sprintf('Generating frame (%d/%d)', N, nframes));
			end
			delete(wb);
			F.renderMode = 1;

		end 	%genRandSeq()

		% -------- DISPLAY --------
		function disp(fb)
            %seems to be an issue here with parameter....
            if(~isa(fb, 'csFrameBuffer'))
                error('Argument must be csFrameBuffer object');
            end
            fbufDisplay(fb);
		end     %disp()

        function fbufDisplay(fb)
        %FBUFDISPLAY
        %
        % Show csFrameBuffer in console

        % Stefan Wong 2012

            fprintf('csFrameBuffer:\n');
            %Show buffer
            if(fb.nFrames == 0)
                fprintf('WARNING: Frame Buffer not set\n');
            else
                fprintf('csFrameBuffer.nFrames = %d\n', fb.nFrames);
                fsz = size(fb.frameBuf(1).img);
                fprintf('Frame size: %d x %d\n', fsz(2), fsz(1));
            end
            %Show path
            if(fb.path == ' ')
                fprintf('WARNING: csFrameBuffer.path not set\n');
            else
                fprintf('csFrameBuffer.path : %s\n', fb.path);
            end
            %Show extension
            if(fb.ext == ' ')
                fprintf('WARNING: csFrameBuffer.ext not set\n');
            else
                fprintf('csFrameBuffer.ext : %s\n', fb.ext);
            end
            %Show frame number
            fprintf('csFrameBuffer.fNum = %d\n', fb.fNum);
            if(fb.verbose == 1)
                fprintf('csFrameBuffer verbose mode on\n');
            else
                fprintf('csFrameBuffer verbose mode off\n');
            end

        end 	%fbufDisplay()


	end 		%csFrameBuffer METHODS (Public)
	
	% ---- METHODS IN FILES ---- %
	methods (Access = 'private')
		rFrame = genRandFrame(F, opts);
		pos    = genRandPos(F, prevPos, maxDist, imsz);
	end

	methods (Static)
		% ---- Check memory usage of frame buffer ---- %
		status = bufMemCheck(nFrames, path, varargin);
		tVec   = bufGetTraj(FB, varargin);

		% ---- Display object properties ---- %
		%fbufDisplay(fb);

	end 		%csFrameBuffer METHODS (Static)

end 			%classdef csFrameBuffer
