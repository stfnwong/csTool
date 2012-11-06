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
% contains a 5 element row vector in the format [xc yc theta axmaj axmin].
% [nIters] - Number of tracking iterations performed on this frame
% [tVec]      - Tracking vector for this frame. The vector is supplied as a 2x2 matrix% where each column represents a (x,y) coordinate in the image [(x1;y1) , (x2;y2)]
% [filename]  - Path to file where img was read
% 
% TODO: Finish documentation

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAcess = 'public')
		img;		%original image data
		bpImg;		%backprojection image
		bpSum;		%number of non-background pixels in bpImg
		rhist;		%ratio histogram for this frame
		winParams;	%window parameters for tracking
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
						img       = [];
						bpImg     = [];
						bpSum     = [];
						rhist     = zeros(1,16);
						winParams = cell(1,1);
						nIters    = 0;
						tVec      = [];
						filename  = [];
				case 1
					%Copy to new object if argument is a csFrame
					if(isa(varargin{1}, 'csFrame'))
						cf = varargin{1};
					else
						%Not enough info to set params, so init to empty
						img       = [];
						bpImg     = [];
						bpSum     = [];
						rhist     = zeros(1,16);
						winParams = cell(1,1);
						nIters    = 0;
						tvec      = [];
						filename  = [];
					end
				otherwise
					fprintf('TODO: See what we got\n');
			end
		end 	%csFrame() CONSTRUCTOR

		% ---- GETTER METHODS ---- %
		function wparams = getWparams(T)
			wparams = T.winParams;
		end 	%getWparams()
		
		% ---- SETTER METHODS ---- %
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

		function setTVec(T, vec)
			T.tVec = vec;
		end 	%setTVec()

		% ---- DISPLAY : disp(csFrame)
		function disp(cf)
		% disp
		%
		% Format frame contents for console display
			
			if(~isempty(cf.filename))
				fprintf('Image: %s\n', filename);
			else
				fprintf('Image data not read yet\n');
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
			if(~isempty(cf.winParams))
				fprintf('TRACKING WINDOW PARAMETERS:\n');
				fprintf('Window centered at %d,%d (x,y)\n', cf.winParams(1), cf.winParams(2));
				fprintf('Orientation: %f radians\n', cf.winParams(3));
				fprintf('Bounding region:\n');
				fprintf('X axis : %d\n', cf.winParams(4) * 2);
				fprintf('Y axis : %d\n', cf.winParams(5) * 2);
			else
				fprintf('Window parameters not set\n');
			end

			
		end 	%disp()
	
	end 		%csFrame METHODS

end 			%classdef csFrame
		
		
