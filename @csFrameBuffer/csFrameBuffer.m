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
% verbose  - 
%
% METHODS
%
% fb = csFrameBuffer(...) [Constructor] 
% Create a new csFrameBuffer object. Calling the constructor with no arguments will
% create a new csFrameBuffer with the default initialisation. Pass in an options 
% structure to override default setup
%
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


	% TODO : Add frame size parameter...?
	% TODO : This would mean adding a routine in vecManager that can 
	% determine the size of the frame from the length and number of 
	% vector files
	properties (SetAccess = 'private', GetAccess = 'private')
		frameBuf;		%array of csFrame handles
		nFrames;		%number of elements in frameBuf
		msVec;			%Meanshift vectors for each frame 
		renderMode;		% (ENUM) Read file from disk or genBP Img
		% NOTE (renderMode) This effectively acts as an enum that 
		% determines which kind of data getCurImg() will return
	end

	properties (SetAccess = 'private', GetAccess = 'public')
		verbose;		%Be verbose (show debug messages)
	end

	properties (Constant = true, GetAccess = 'public')
		% Enumerations for renderMode
		IMG_FILE  = 0;
		GEN_BPIMG = 1;
		IMG_DATA  = 2;
		BP_IMG    = 3;
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
		% 	renderMode = 0;
		% 	verbose    = 0;
		%
		% To initialise the csFrameBuffer object with different options, 
		% pass in a structure with members whose names match the 
		% properties of the csFrameBuffer
		%
		% USAGE:
		% F = csFrameBuffer();
		% F = csFrameBuffer(opts_struct);
		%
		% See classdef documentation for further information about 
		% methods and properties for this class.

			switch nargin
				case 0
					%Default initialisation
					fb.frameBuf   = csFrame();
					fb.nFrames    = 0;
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
						fb.renderMode = opts.renderMode;
						fb.verbose    = fb.verbose;
						if(fb.verbose)
							fprintf('Verbose mode on\n');
						end
						for n = opts.nFrames:-1:1
							t_buf(n) = csFrame();
						end
						fb.frameBuf = t_buf;
						%Use default extension
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
		
		function n = getNumFrames(F)
			n = F.nFrames;
		end 	%getNumFrames()

		function rMode = getRenderMode(F)
			rMode = F.renderMode;
		end 	%getRenderMode()

		function opts = getOpts(F)
		% GETOPTS
		% Return an options structure. For csToolGUI.
			opts = struct('frameBuf',   F.frameBuf, ...
                          'nFrames',    F.nFrames,  ...
				          'renderMode', F.renderMode, ...
                          'verbose',    F.verbose );
		end 	%getOpts();

		function fh = getFrameHandle(F, N)
		% GETFRAMEHANDLE
		% USAGE : fh = getFrameHandle(N)
		% 
		% Obtain the handle to frame N. If N is a scalar, getFrameHandle 
		% returns a single handle to the Nth frame in the buffer. If N 
		% is a vector of intergers, getFrameHandle returns an array 
		% containing handles for the corresponding frames
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

		function niters = getNiters(FB, idx)
			niters = get(FB.frameBuf(idx), 'nIters');
		end 	%getNiters()

		function dataSz = getDataSz(FB, idx)
			dataSz = get(FB.frameBuf(idx), 'dataSz');
		end

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
			if(get(FB.frameBuf(idx), 'bpSum') > 0)
				status = true;
			else
				status = false;
			end
		end 	%isBpData()

		function isSparseVec = isSparseVec(FB, idx)
			if(get(FB.frameBuf(idx), 'isSparse'))
				isSparseVec = true;
			else
				isSparseVec = false;
			end
		end 	%isSparseVec()
		
		function zmtrue = getZeroMoment(FB, idx)
			zmtrue = length(get(FB.frameBuf(idx), 'bpVec'));
		end 	%getZeroMoment()

		function [img varargout] = getCurImg(F, idx, varargin)
		% GETCURIMG
		% img = getCurImg(F, idx, [..OPTIONS..])
		% Return the image data for the frame at position idx consistent
		% with the mode specified by renderMode.
		%
		% ARGUMENTS:
		%
		% F       - csFrameBuffer object
		% idx     - Index in buffer to retreive
		%
		% [OPTIONAL ARGUMENTS]
		% 'vec'   - Return the image as a vector, if applicable
		% '3chan' - Force the ouput to have 3 channels
		% 'bpimg' - Return the backprojection image irrespective of 
		%           renderMode
		% 'img'   - Return the RGB image irrespective of renderMode
		
		% TODO : Strategy for this method
		% If no options are specified we return the default image type.
		% We can override the default by supplying an argument to the 
		% function to request a specific data member from the frame 
		% handle
		

			GET_BP_IMG   = false;
			GET_HUE_IMG  = false;
			GET_HSV_IMG  = false;
			GET_RGB_IMG  = false;
			FORCE_3_CHAN = false;
			VERBOSE      = false;
			
			if(~isempty(varargin))
				for k = 1 : length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'mode', 4))
							imgMode = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'verbose', 7))
							VERBOSE = true;
						elseif(strncmpi(varargin{k}, '3chan', 5))
							FORCE_3_CHAN = true;
						end
					end
				end
			end

			if(nargout > 1)
				varargout{1} = 0;
			end

			% Bounds check idx
			if(idx < 1 || idx > length(F.frameBuf))
				img = [];
				if(nargout > 1)
					varargout{1} = -1;
				end
				if(F.verbose)
					fprintf('%s idx %d out of bounds\n', DSTR, idx);
				end
				return;
			end

			% Set format options
			if(exist('imgMode', 'var'))
				if(strncmpi(imgMode, 'bp', 2))
					GET_BP_IMG = true;
				elseif(strncmpi(imgMode, 'rgb', 3))
					GET_RGB_IMG = true;
				elseif(strncmpi(imgMode, 'hsv', 3))
					GET_HSV_IMG = true;
				elseif(strncmpi(imgMode, 'hue', 3))
					GET_HUE_IMG = true;
				end
			end

			opts = struct('GET_BP_IMG', GET_BP_IMG, ...
				          'GET_HUE_IMG', GET_HUE_IMG, ...
				          'GET_HSV_IMG', GET_HSV_IMG, ...
				          'GET_RGB_IMG', GET_RGB_IMG, ... 
				          'FORCE_3_CHAN', FORCE_3_CHAN, ...
			              'verbose', VERBOSE );


			% TODO : Adjust renderMode and calling mechanism 
			% TODO : Test csToolVerify read and write calls
			[img status] = getImgData(F, idx, opts);
			if(status == -1)
				fprintf('%s ERROR returning image data for index %d\n', DSTR, idx);
				if(nargout > 1)
					varargout{1} = -1;
				end
			end
			
		end 	%getCurImg()

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

		function avgIter = getAvgIter(FB, varargin)
		% GETAVGITER
		% avgIter = getAvgIter(F, [..OPTIONS..])
		%
		% Get the average number of iterations required to converge for
		% the currently stored sequence.

			if(~isempty(varargin))
				if(strncmpi(varargin{1}, 'range', 5))
					bRange = varargin{2};
				end
			end
			if(~exist('range', 'var'))
				bRange = [1 length(FB.frameBuf)];
			end

			% Check that the nIters params is set in the first frame
			% (for the time being, we assume that if one frame is set,
			% all the frames in range are set)
			
			% TODO : something odd here, according to mlint...	
			if(isempty(get(FB.frameBuf(bRange(1)), 'nIters')))
				fprintf('%s nIters not set in frame %d, exiting\n', DSTR, bRange(1));
				avgIter = [];
				return;
			end

			avgIter = 0;
			for n = bRange(1) : bRange(2)
				avgIter = avgIter + get(FB.frameBuf(n), 'nIters');
			end
			avgIter = avgIter / (bRange(2) - bRange(1)) + 1;	%need +1 due to MATLAB

		end 	%getAvgIter()
		
		% ---------------------------------- %
		% -------- SETTER FUNCTIONS -------- %
		% ---------------------------------- %
	

		function FB = setFrameParams(FB, idx, opts)
		% SETFRAMEPARAMS
		% Set frame parameters for the frame at position idx. 

			if(isfield(opts, 'img'))
				set(FB.frameBuf(idx), 'img', opts.img);
			end
			if(isfield(opts, 'bpimg'))
				set(FB.frameBuf(idx), 'bpImg', opts.bpimg);	
			end
			if(isfield(opts, 'bpvec'))
				set(FB.frameBuf(idx), 'bpVec', opts.bpvec);
			end
			if(isfield(opts, 'bpsum'))
				set(FB.frameBuf(idx), 'bpSum', opts.bpsum);
			end
			if(isfield(opts, 'rhist'))
				set(FB.frameBuf(idx), 'rhist', opts.rhist);
			end
			if(isfield(opts, 'ihist'))
				set(FB.frameBuf(idx), 'ihist', opts.ihist);
			end
			if(isfield(opts, 'winparams'))
				set(FB.frameBuf(idx), 'winParams', opts.winparams);
			end
			if(isfield(opts, 'wininit'))
				set(FB.frameBuf(idx), 'winInit', opts.wininit);
			end
			if(isfield(opts, 'moments'))
				set(FB.frameBuf(idx), 'moments', opts.moments);
			end
			if(isfield(opts, 'niters'))
				set(FB.frameBuf(idx), 'nIters', opts.niters);
			end
			if(isfield(opts, 'tvec'))
				set(FB.frameBuf(idx), 'tVec', opts.tvec);
			end
			if(isfield(opts, 'dims'))	
				set(FB.frameBuf(idx), 'dims', opts.dims);
			end
			if(isfield(opts, 'issparsevec'))
				set(FB.frameBuf(idx), 'isSparse', opts.issparsevec);
			end
			if(isfield(opts, 'sparsefac'))
				set(FB.frameBuf(idx), 'sparseFac', opts.sparsefac);
			end
			if(isfield(opts, 'filename'))
				set(FB.frameBuf(idx), 'filename', opts.filename);
			end
			if(isfield(opts, 'method'))
				set(FB.frameBuf(idx), 'method', opts.method);
			end
			if(isfield(opts, 'dataSz'))
				set(FB.frameBuf(idx), 'dataSz', opts.dataSz);
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
			FB.nFrames  = length(fr);

		end 	%initFrameBuf()
		
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
		
		function [FB status varargout] = loadFrameData(FB, filename, numFiles,  varargin)
		% LOADFRAMEDATA
		%
		% [FB status] = loadFrameData(FB, ...[options]... )
		%
		% Load filenames specified by FB.path and FB.fNum into frame 
		% buffer. To override the path, pass the string 'path' followed 
		% by the path name. To override fNum, pass 'num' followed by 
		% number of frames to read.
		%
		% OPTIONS:
		% 'force' - If not all files a present, load as many as possible
		% 'img'   - Load image data into csFrameBuffer. By default only 
		%           the path is written to the csFrame handle.
		
			DSTR       = '(csFrameBuffer.loadFrameData) :';
			FORCE      = true; 	%even if not all files are present, load what we have
			LOAD_IMAGE = true;
			if(~isempty(varargin))
				for k = 1 : length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'img', 3))
							LOAD_IMAGE = true;
						elseif(strncmpi(varargin{k}, 'force', 5))
							FORCE = true;
						end
					end
				end
			end
			
			%Check what we have
			if(~exist('numFiles', 'var'))
				 numFiles = FB.nFrames;
			 else
				 if(numFiles > FB.nFrames)
					 for n = numFiles:-1:1
						 FB.frameBuf(n) = csFrame();
					 end
				 end
			 end

			chk = checkFiles(filename, 'nframes', numFiles, 'framebuf');
			if(chk.exitflag == -1)
				if(FORCE && chk.errFrame > 1)
					if(FB.verbose)
						fprintf('%s %d of %d files found, reading first %d files\n', DSTR, chk.errFrame, numFiles, chk.errFrame);
					end
					numFiles = chk.errFrame;
				else
					fprintf('%s ERROR cant find file [%s]\n', DSTR, chk.errFile);
					status = -1;
					if(nargout > 2)
						varargout{1} = numFiles;
					end
					return;
				end
			end

			ps = fname_parse(filename, 'framebuf');
			startFile = ps.frameNum;

			idx   = 1;
			total = length(startFile : (startFile+numFiles))-1;
			wb = waitbar(0, 'Reading image files...', 'Name', 'Reading image files');
			for k = startFile : (startFile + numFiles)-1
				fn = sprintf('%s%s%03d.%s', ps.path, ps.filename, k, ps.ext);
				set(FB.frameBuf(idx), 'filename', fn);
				set(FB.frameBuf(idx), 'hasImgData', true);
				if(LOAD_IMAGE)
					img = imread(fn, ps.ext);
					set(FB.frameBuf(idx), 'img', img);
				end
				idx = idx + 1;
				waitbar(idx/total, wb, sprintf('Reading file %d/%d', idx, total));
			end
			delete(wb);

			if(FB.verbose)
				fprintf('\n File read complete\n');
				fprintf('Read %d frames\n', k);
			end
			% Assume that all images are the same size, read an image 
			% out and set all frame dimensions to match;
			%timg = imread(get(FB.frameBuf(1), 'filename'), ps.ext);
			timg = imread(fn, ps.ext);
			dims = size(timg);
			dataSz = range(range(timg));
			if(dims(3) > 3)
				dims(3) = 3;
			end
			for k = 1 : length(FB.frameBuf)
				set(FB.frameBuf(k), 'dims', [dims(2) dims(1)]);
				set(FB.frameBuf(k), 'dataSz', dataSz);
			end

			%write back data
			FB.renderMode = FB.IMG_FILE;
            status        = 0;
			if(nargout > 2)
				varargout{1} = numFiles;
			end
			return;

		end 	%loadFrameData()

		function FB = loadVectorData(F, vecdata, idx, vclass, varargin)
		% LOADVECTORDATA
		% FB = loadVectorData(F, vecdata, idx, vtype, [..OPTIONS..]
		%
		% Load vector data directly into frame buffer at position idx. 
		% For reading image files into frame buffer from disk, see 
		% loadFrameData().
		%
		% ARGUMENTS
		% F - csFrameBuffer object
		% vecdata - Data to load into buffer
		% idx     - Index in buffer to write data
		% vtype   - String specifying type of data to write. Can be 
		%           one of:
		%
		%           'RGB' - Write an RGB image [set(fh, 'img', vecdata)]
		%           'HSV' - Write HSV image [set(fh, 'img', vecdata)]
		%           'Hue' - Write 1-channel hue image [set(fh, 'img', vecdata)]
		%           'bp'  - Write bpvec [set(fh, 'bpvec', vecdata)]
		%           
		% OPTIONAL ARGUMENTS
		% 'dims', dims - Pass this to specify the dimensions of the image data
		% 'filename', filename - Add filename to this frame handle
		% 'bpSum', bpsum - Add bpsum to this frame handle
		%
	
			DSTR = 'ERROR [csFrameBuffer.loadVectorData()] :';
			if(~isempty(varargin))
				for k = 1 : length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'dims', 4))
							dims = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'filename', 8))
							filename = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'bpsum', 5))
							bpsum = varargin{k+1};
						end
					end
				end
			end

			% Check index range
			if(idx < 1 || idx > length(F.frameBuf))
				fprintf('%s idx (%d) out of range\n', DSTR, idx);
				FB = F;
				return;
			end

			% Check what we have
			if(~exist('dims', 'var'))
				dims = [640 480];
			end
			if(~exist('filename', 'var'))
				filename = ' ';
			end
			if(~exist('bpsum', 'var'))
				bpsum = [];
			end

			% ARGH! MATLAB CANT FALL THROUGH CASES!!!!!
			switch(vclass)
				case 'RGB'
					set(F.frameBuf(idx), 'img', vecdata);
					F.renderMode = F.IMG_DATA;
				case 'HSV'
					set(F.frameBuf(idx), 'img', vecdata);
					F.renderMode = F.IMG_DATA;
				case 'Hue'
					set(F.frameBuf(idx), 'img', vecdata);
					F.renderMode = F.IMG_DATA;
				case 'Backprojection'
					set(F.frameBuf(idx), 'bpVec', vecdata);
					F.renderMode = F.GEN_BPIMG;	%or maybe F.BP_IMG?
				case 'bp'
					set(F.frameBuf(idx), 'bpVec', vecdata);
					F.renderMode = F.GEN_BPIMG;	%or maybe F.BP_IMG?
				otherwise
					fprintf('%s not a valid vtype [%s]\n', DSTR, vclass);
					FB = F;
					return;
			end
			
			% Set other parmeters
			set(F.frameBuf(idx), 'dims', dims);
			set(F.frameBuf(idx), 'filename', filename);
			set(F.frameBuf(idx), 'bpSum', bpsum);

			FB = F;

		end 	%loadVectorData()

		function saveBufData(F, filename, range)
		% SAVEBUFDATA
		% FB = saveBufData(F, range)
		%
		% Save buffer contents to disk as a series of *.mat files
			DATA_DIR = 'data/settings';
			DSTR     = '[csFrameBuffer.saveBufData()] : ';

			if(isempty(range))
				range = [1 length(F.frameBuf)];
			end
			if(length(range) ~= 2)
				fprintf('%s range must be 2xN or Nx2 vector\n', DSTR);
				return;
			end
			if(range(2) > length(F.frameBuf))
				range(2) = length(F.frameBuf);
			end
			
			n  = 1;
			t  = range(2) - range(1);
			wb = waitbar(0, sprintf('Saving frame data (%d/%d)', n, t));
			ps = fname_parse(filename);
			if(ps.exitflag == -1)
				fprintf('%s unable to parse file [%s]\n', DSTR, filename);
				return;
			end

			for k = range(1) : range(2)
				filename = sprintf('%s/%s-frame%03d.%s', ps.path, ps.filename, k, ps.ext);
				%bufDiskWrite(F, F.frameBuf(k), filename);
				fhData = F.frameBuf(k); %#ok
				save(filename, 'fhData');
				waitbar(n/t, wb, sprintf('Saving frame data (%d/%d)', n, t));
				n = n + 1;
			end
			delete(wb);

		end 	%saveBufData()

		function FB = loadBufData(F, filename, numFiles)
		% LOADBUFDATA
		% FB = loadBufData(F, numFiles, startFile);
		%
		% Load buffer data from disk 
			DSTR     = '[csFrameBuffer.loadBufData] : ';	

			% TODO : May need to initialise the csFrameBuffer object here
			ps = fname_parse(filename);
			if(ps.exitflag == -1)
				fprintf('%s unable to parse file [%s]\n', DSTR, filename);
				return;
			end
			startFile = ps.frameNum;
			chk = checkFiles(filename, 'nframe', numFiles);
			if(chk.exitflag == -1)
				if(chk.errFrame > 0)
					numFiles = chk.errFrame;
				end
			end
			n = 1;
			total = startFile + numFiles;
			wb = waitbar(0, sprintf('Reading frame data (%d/%d)', n, total));
			for k = startFile : numFiles
				fn = sprintf('%s/%s-frame%03d.%s', ps.path, ps.filename, k, ps.ext);
				fhData        = load(fn);
				F.frameBuf(k) = fhData.fhData;
				waitbar(n/total, wb, sprintf('Reading frame data (%d/%d)', n, total));
				n = n + 1;
			end	
			delete(wb);
			% TODO : Need to figure out which renderMode to use after load
			FB = F;

		end 	%loadBufData()

		function clearImData(F, varargin)
		% CLEARIMDATA
		% Set any image data in the buffer equal to the empty matrix. 
		% Pass a integer N as an optional argument to clear only the 
		% data for the Nth frame, or a vector of integers to clear image 
		% data for frames N(1) to N(end). 
		
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

		function Fout = genRandSeq(F, varargin)
		% GENRANDSEQ
		% Generate a sequence of random backprojection data for testing.
		% 

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
						elseif(strncmpi(varargin{k}, 'wRes', 6))
							wRes = varargin{k+1};
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
					maxspd = 64; %max distance in pixels to next frame
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
				if(~exist('wRes', 'var'))
					wRes = 1;
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
					          'wRes', wRes, ...
							  'kernel', [] );
			else
				nframes = opts.nframes;
			end

			F  = initFrameBuf(F, nframes);
			wb = waitbar(0, sprintf('Generating frame (%d/%d)', 0, nframes), 'title', 'Generating Backprojection Sequence...');
			for N = 1:nframes
				% DEBUG:
				if(isempty(opts.imsz))
					fprintf('WARNING: empty dimensions in generated frame %d\n', N);
				end
				frame  = genRandFrame(F, opts);
				% Scale frame
				%frame  = frame ./ max(max(frame));
				%frame  = sfac .* frame;
				bpvec  = bpimg2vec(frame, 'bpval');
				dataSz = max(bpvec(3,:));
				% set parameter data for frame handle
				fname  = sprintf('bpgen-%03d.ext', N);
				set(F.frameBuf(N), 'filename', fname);
				set(F.frameBuf(N), 'bpVec', bpvec);
				set(F.frameBuf(N), 'bpSum', opts.npoints);
				set(F.frameBuf(N), 'dims', opts.imsz);
				set(F.frameBuf(N), 'dataSz', dataSz);
				%set(F.frameBuf(N), 'bpImg', frame);
				% generate position for new frame
				opts.loc = genRandPos(F, opts.loc, opts.maxspd, opts.imsz);
				waitbar(N/nframes, wb, sprintf('Generating frame (%d/%d)', N, nframes));
			end
			delete(wb);
			F.renderMode = 1;
			Fout         = F;

		end 	%genRandSeq()

		% -------- DISPLAY --------
		%function disp(fb)
        %    %seems to be an issue here with parameter....
        %    if(~isa(fb, 'csFrameBuffer'))
        %        error('Argument must be csFrameBuffer object');
        %    end
        %    fbufDisplay(fb);
		%end     %disp()

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
		         bufDiskWrite(F, fh, filename);
				 bufDiskRead(F, fh, filename);
		[img varargout] = getImgData(F, idx, opts);
	end

	methods (Static)
		% ---- Check memory usage of frame buffer ---- %
		status = bufMemCheck(nFrames, path, varargin);
		tVec   = bufGetTraj(FB, varargin);

		% ---- Display object properties ---- %
		%fbufDisplay(fb);

	end 		%csFrameBuffer METHODS (Static)

end 			%classdef csFrameBuffer
