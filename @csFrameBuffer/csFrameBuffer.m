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
		fNum;			%Which frame to start reading from 
		verbose;		%Be verbose
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
					fb.frameBuf  = csFrame();
					fb.nFrames   = 0;
					fb.path      = ' ';
					fb.ext       = 'tif';
					fb.fNum      = 1;
					fb.verbose   = 0;
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
						fb.frameBuf = csFrame(); 
						fb.nFrames  = opts.nFrames;
						fb.path     = opts.path;
						fb.fNum     = opts.fNum;
						fb.verbose  = fb.verbose;
						if(fb.verbose)
							fprintf('Verbose mode on\n');
						end
						%init buffer
						tpath = sprintf('%s_%03d', opts.path, opts.fNum);
						if(csFrameBuffer.bufMemCheck(opts.nFrames, tpath))
							fprintf('WARNING: Buffer may exhaust memory\n');
						end
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
				otherwise
					error('Incorrect constructor options');
			end
		end 	%csFrameBuffer CONSTRUCTOR

		% -------- GETTER FUNCTIONS -------- %

		% ---- getFrameHandle() : OBTAIN FRAME HANDLE ---- %
		function fh = getFrameHandle(this, N)
			fh = this.frameBuf(N);
		end 	%getFrameHandle()
		
		% ---- getNumFrames() : GET TOTAL NUMBER OF FRAMES STORED IN BUFFER
		function n = getNumFrames(this)
			n = this.nFrames;
		end 	%getNumFrames()

		% -------- SETTER FUNCTIONS -------- %

        function FB = setPath(FB, path)
        
            if(~ischar(path))
                error('Path must be string');
            end
            FB.path = path;
		end
		
		function FB = setNFrames(FB, nFrames)
			
			%Estimate memory usage
			if(isempty(FB.path) || ~ischar(FB.path))
				fprintf('WARNING: Path not set, cannot estimate memory usage\n');
			else
				tpath = sprintf('%s_%03d', FB.path, FB.fNum);
				if(csFrameBuffer.bufMemCheck(nFrames, tpath))
					fprintf('WARNING: %d frames likely in GB range\n', nFrames);
					fprintf('Estimated size : %d bytes\n', mem/8);
				end
			end
			FB.nFrames = nFrames;
			%Re-allocate buffer
			for n = nFrames:-1:1
				t_buf(n) = csFrame();
			end
			FB.frameBuf = t_buf;
			
		end
		
		function [FB status] = loadFrameData(FB, varargin)
		% LOADFRAMEDATA
		%
		% Read image files specified at path into frameBuf for segmentation and 
		% tracking. 
		
			%If varargin is a string, take this as being a path to data and 
			%use in place of FB.path
			if(nargin > 1)
				if(ischar(varargin{1}))
					fpath = varargin{1};
					if(FB.verbose)
						fprintf('Using %s as path\n', fpath);
					end
				end
			else
				fpath = FB.path;
			end
			%Check parameters are sensible
			if(isempty(fpath) || ~ischar(fpath))
				fprintf('Path not correctly set, exiting...\n');
				status = 0;
				return;
			end
			if(isempty(FB.ext) || ~ischar(FB.ext))
				fprintf('Extension not correctly set, exiting...\n');
				status = 0;
				return;
			end
			%Load data into buffer
			fnum = FB.fNum;
			for k = 1:FB.nFrames
				fn  = sprintf('%s_%03d.%s', fpath, fnum, FB.ext);
				img = imread(fn, FB.ext);
				FB.frameBuf(k).setFilename(fn);		
				FB.frameBuf(k).setImg(img);
				%setFilename(FB.frameBuf(k), fn);
				%setImg(FB.frameBuf(k), img);
				%if(FB.verbose)
					fprintf('Read frame %3d (%s)\n', k, fn);
				%end
				fnum = fnum + 1;
			end
			if(FB.verbose)
				fprintf('\n File read complete\n');
				fprintf('Read %d frames\n', k);
			end
			%write back data
			FB.fNum = fnum;
            status = 1;
			return;

		end 	%loadFrameData()

		function path = showPath(fb, varargin)
			
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

		% -------- DISPLAY --------
		function disp(fb)
            %seems to be an issue here with parameter....
            if(~isa(fb, 'csFrameBuffer'))
                error('Argument must be csFrameBuffer object');
            end
            fbufDisplay(fb);
		end 	

	end 		%csFrameBuffer METHODS (Public)
	
	% ---- METHODS IN FILES ---- %
	methods (Static)
		% ---- Check memory usage of frame buffer ---- %
		status = bufMemCheck(nFrames, path, varargin);
		% ---- Display object properties ---- %
		fbufDisplay(fb);

	end 		%csFrameBuffer METHODS (Static)

end 			%classdef csFrameBuffer
