classdef csFrameBuffer
% CSFRAMEBUFFER
%
% Frame buffer object for camshift tracker. This object contains handles to all the
% frames to be used in the segmentation and tracking test. 

% Stefan Wong 2012

	properties (SetAcess = 'private', GetAccess = 'private')
		frameBuf;
		nFrames;
		path;
		ext;
		fNum;
		verbose;
	end

	% ---- PUBLIC METHODS ---- %
	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function fb = csFrameBuffer(varargin)
		% CSFRAMEBUFFER
		% Create new csFrameBuffer object
		% TODO: Document fully

			switch nargin
				case 0
					%Default initialisation
					frameBuf  = csFrame();
					nFrames   = length(frameBuf);
					path      = ' ';
					ext       = 'tif';
					fNum      = 1;
					verbose   = 0;
				case 1
					%Object copy case
					if(isa(varargin{1}, 'csFrameBuffer'))
						cf = varargin{1};
					elseif(iscell(varargin{1}))
						%send options to parser
						cfOpt = csFrameBuffer.optParser(varargin{1});
						%Read data back from cfOpt structure
						fb.nFrames   = csOpt.nFrames;
						fb.frameBuf(1:fb.nFrames) = csFrame();
						fb.path      = cfOpt.path;
						
					else
						error('Incorrect constructor options');
					end
				otherwise
					error('Incorrect constructor options');
			end
		end 	%csFrameBuffer CONSTRUCTOR

		% -------- GETTER FUNCTIONS -------- %

		% ---- getFrameHandle() : OBTAIN FRAME HANDLE ---- %
		function fh = getFrameHandle(this, N)
		% GETFRAMEHANDLE
		%
		% Returns a handle to the Nth frame in the buffer. 

			fh = this.frameBuf(N);
		end 	%getFrameHandle()
		
		% ---- getNumFrames() : GET TOTAL NUMBER OF FRAMES STORED IN BUFFER
		function n = getNumFrames(this)
		% GETNUMFRAMES
		%
		% Returns total number of frames stored in this buffer object
		
			n = this.nFrames;
		end 	%getNumFrames()

		% -------- SETTER FUNCTIONS -------- %
		% ---- loadFrameData() : READ FRAME DATA FROM DISK
		function status = loadFrameData(this)
		% LOADFRAMEDATA
		%
		% Read image files specified at path into frameBuf for segmentation and 
		% tracking. 

			%Check parameters are sensible
			if(~isempty(this.path) || ~ischar(this.path))
				fprintf('Path not correctly set, exiting...\n');
				status = 0;
				return;
			end

			for k = 1:length(frameBuf)
				fn = sprintf('%s_%03d.%s', this.path, this.fNum, this.ext);
				this.frameBuf(k).filename = fn;
				this.frameBuf(k).img      = imread(fn, ext);
				if(this.verbose)
					fprintf('Read frame %d (%s)\n', this.fNum, fn);
				end
				this.fNum = this.fNum + 1;
			end
			if(verbose)
				fprintf('\n File read complete\n');
				fprintf('Read %d frames\n', this.fNum);
			end

		end 	%loadFrameData()

		% ---- setBufferSize() : MODIFY BUFFER SIZE
		function setBufferSize(this, size, varargin)
		% SETBUFFERSIZE
		%
		% Modify the size of the buffer
		% Note that calling this function will destroy the buffer contents. This may
		% require a further call to loadFrameData() to restore the buffer contents
		% from disk

			if(nargin > 2)
				if(ischar(varargin{1}))
					if(strncmpi(varargin{1}, 'f', 1))
						force = 1;
					end
				end
			end
			if(size > this.nFrames)
				if(~exist('force', 'var'))
					error('New size larger than buffer (use force option to override)');
				end
			end
			this.frameBuf(1:size) = csFrame();

		end 	%setBufferSize

		% ---- setFrameParams() : MODIFY Nth FRAME PARAMTERS BASED ON fParam STRUCT
		function setFrameParams(F, N, fParam)

		end 	%setFrameParams()

		% ---- setFBProp() : MODIFY FRAME BUFFER PROPERTIES ---- %
		% TODO: Decide whether or not to use this

		% -------- DISPLAY --------
		function disp(fb)
			fbDisplay(fb);
		end 	%disp()

	end 		%csFrameBuffer METHODS (Public)
	
	% ---- METHODS IN FILES ---- %
	methods (Static)
		%Input option parser
		cfOpt = optParser(options);
		%Display function
		fDisplay(fb);
	end 		%csFrameBuffer METHODS (Static)

end 			%classdef csFrameBuffer
