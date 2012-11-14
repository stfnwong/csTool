classdef csFrame < handle
% csFrame 
% 
% Handle class for frame objects in camshift tracker. 
%
% PROPERTIES:
%
% [img]       - Image data read from file
% [bpImg]     - Backprojection image computed according to segmentation method
% [bpSum]     - Number of non-background pixels in bpImg
% [rhist]     - Ratio histogram for this frame
% [winParams] - Cell array containing window parameters in each operation. Each cell 
%               contains a 5 element row vector in the format 
%                        [xc yc theta axmaj axmin].
% [moments]   - Cell array containing moment sums for each iteration. Each cell 
%               contains a 5 element row vector in the format
%                        [zm xm ym xym xxm yym].
% [nIters]    - Number of tracking iterations performed on this frame
% [tVec]      - Tracking vector for this frame. The vector is supplied as a 2x2 matrix%               where each column represents a (x,y) coordinate in the image 
%                        [(x1;y1) , (x2;y2)]
% [filename]  - Path to file where img was read
%
% METHODS:
%
% ---- SETTER METHODS ----
% setBpSum(T, bpsum)       - Set Backprojection image sum to 'bpsum'
% setBpImg(T, bpimg)       - Set Backprojection image to 'bpimg'
% setImg(T, img)           - Set Image to 'img'
% setFilename(T, fname)    - Set filename to 'fname'
% setRHist(T, rhist)       - Set ratio histogram to 'rhist'
% setWparams(T, wparams)   - Set window parameters to 'wparams'
% setMoments(T, moments)   - Set moment sums to 'moments'
% setTVec(T, vec)          - Set tracking vector to 'vec' 
% 
% 

% Stefan Wong 2012

	properties (SetAccess = private, GetAccess = public)
		img;		%original image data
		bpImg;		%backprojection image
		bpSum;		%number of non-background pixels in bpImg
		rhist;		%ratio histogram for this frame
		winParams;	%window parameters for tracking
		winInit;    %Initial window parameters (final parameters from previous frame)
		moments;    %Moment sums accumulated for this image
		nIters;		%number of iterations taken to converge
		tVec;		%tracking vector
		filename;	%name of original image file
	end
	
	methods
		% ---- CONSTRUCTOR ---- %
		function cf = csFrame(varargin)
		% CSFRAME CONSTRUCTOR
		% cf = csFrame() creates a new frame handle
	
			switch nargin
				case 0
					%Set default
						cf.img       = [];
						cf.bpImg     = [];
						cf.bpSum     = [];
						cf.rhist     = zeros(1,16, 'uint8');
						cf.winParams = cell(1,1);
						cf.winInit   = zeros(1,5);
						cf.moments   = cell(1,1);
						cf.nIters    = 0;
						cf.tVec      = [];
						cf.filename  = ' ';
				case 1
					%Copy to new object if argument is a csFrame
					if(isa(varargin{1}, 'csFrame'))
						cf = varargin{1};
					elseif(isa(varargin{1}, 'struct'))
						opts = varargin{1};
						cf.img       = opts.img;
						cf.bpImg     = opts.bpImg;
						cf.bpSum     = opts.bpSum;
						cf.rhist     = opts.rhist;
						cf.winInit   = opts.winInit;
						cf.nIters    = opts.nIters;
						cf.tVec      = opts.tVec;
						if(ischar(opts.filename))
							cf.filename  = opts.filename;
						else
							error('Filename must be string');
						end
						if(iscell(opts.winParams))
							cf.winParams = opts.winParams;
						else
							error('Window parameters must be in cell array');
						end
						if(iscell(opts.moments))
							cf.moments   = opts.moments;
						else
							error('Moments must be in cell array');
						end
						
					else
						%Not enough info to set params, so init to empty
						cf.img       = [];
						cf.bpImg     = [];
						cf.bpSum     = [];
						cf.rhist     = zeros(1,16);
						cf.winParams = cell(1,1);
						cf.winInit   = zeros(1,5);
						cf.moments   = cell(1,1);
						cf.nIters    = 0;
						cf.tVec      = [];
						cf.filename  = ' ';
					end
				otherwise
					error('Incorrect arguments to constructor');
			end
		end 	%csFrame() CONSTRUCTOR
		
		% ---- SETTER METHODS ---- %
		function setBpSum(T, bpsum)
			T.bpSum = bpsum;
		end

		function setBpImg(T, bpimg)
			T.bpImg = bpimg;
		end 	%setBpImg();
	
		function setImg(T, img)
			T.img = img;
		end 	%setImg()

		function setFilename(T, fname)
			%Sanity check arguments
			if(~ischar(fname))
				error('Filename must be string');
			end
			T.filename = fname;
		end 	%setFilename()

		function setRHist(T, rhist)
			T.rhist = rhist;
		end 	%setRHist()

		function setWparams(T, wparams)
			%Sanity check inputs
			if(~iscell(wparams))
				error('Window parameters must be in cell array');
			end
			T.winParams = wparams;
			T.nIters    = length(wparams);
		end 	%setWParams()

		function setInitParams(T, initParams)
			T.winInit = initParams;
		end

		function setMoments(T, moments)
			if(~iscell(moments))
				error('Moment sums must be in cell array');
			end
			T.moments = moments;
		end

		function setTVec(T, vec)
			T.tVec = vec;
		end 	%setTVec()

		% ---- DISPLAY : disp(csFrame)
		function disp(cf)
		% disp
		%
		% Format frame contents for console display
			
			if(strncmpi(cf.filename, ' ', 1))
				fprintf('Image data not read yet\n');
			else
				fprintf('Image: %s\n', cf.filename);
			end
			if(~isempty(cf.img))
				sz = size(cf.img);
				fprintf('Image dimensions: %d x %d (h x w)\n', sz(1), sz(2));
			else
				fprintf('No image data assigned\n');
			end
			if(~isempty(cf.bpImg))
				fprintf('%d pixels in backprojection image\n', cf.bpSum);
			else
				fprintf('Backprojection image not set\n');
			end
			params = cf.winParams{end}; 
            wsz    = size(params);
			if(wsz(2) > 1)
				fprintf('TRACKING WINDOW PARAMETERS:\n');
				fprintf('xc    : %d\n', params(1));
				fprintf('yc    : %d\n', params(2));
				fprintf('theta : %d\n', params(3));
				fprintf('axmaj : %d\n', params(4));
				fprintf('axmin : %d\n', params(5));
				%fprintf('Window centered at %d,%d (x,y)\n', params(1), params(2));
				%fprintf('Orientation: %f radians\n', params(3));
				%fprintf('Bounding region:\n');
				%fprintf('X axis : %d\n', params(4) * 2);
				%fprintf('Y axis : %d\n', params(5) * 2);
			else
				fprintf('Window parameters not set\n');
			end
            fprintf('\n');
			
		end 	%disp()
	
	end 		%csFrame METHODS

end 			%classdef csFrame
		
		
