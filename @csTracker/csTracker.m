classdef csTracker < handle
% CSTRACKER
% tracker = csTracker(option_struct);
% 
% Object tracker class for camshift tracker. This object performs target tracking 
% on the image data contained in the frame handle frHandle.
%
% PROPERTIES:
% method      - Tracking method to use. The methods are enumerated as per the below
%               scheme:
%          
%               1 : MOMENT_WINACCUM - Windowed moment accumulation
%               2 : MOMENT_IMGACCUM - Moment accumulation over entire image space
%               3 : KERNEL_DENSITY  - Compute full kernel density estimation. This 
%                                     method is windowed as per MOMENT_WINACCUM 
% ROT_MATRIX  - Use Rotation matrix to compute window orientation. If this options is
%               not set, the window boundaries are computed using a set of linear 
%               constraints. 
% CORDIC_MODE - Use Cordic to compute window orientation. This option can be combined
%               with the ROT_MATRIX option, which will cause the rotation matrix to be
%               computed with a cordic function. TODO: Add option to generated vector
%               from cordic iteration.
% BP_THRESH   - Threshold the backprojection stage by some integer. By default this 
%               value is set to 0 (no threshold applied)
%
% METHODS:
% -----------------
% Getter methods
%------------------
% getOpts         - Return an options structure containing the current values of all
%                   properties in the csTracker object.
%------------------
% Setter methods
%------------------
% setTrackMethod  - Set the method to use for tracking
% setParams       - Set window parameters to use for the current frame. This method is
%                   automatically called from within the tracking loop to set the 
%                   parameters for the following frame using the current parameters.
%                   This method should be called when the target is first segmented
%                   to set the initial window parameters.
% setVerbose      - Set the verbose property
%------------------
% Processing methods
% -----------------
% trackFrame      - Perform selected tracking method on current frame
% initWindow      - Set the initial window position. 

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAccess = 'public')
		method;
		verbose;
		fParams;			%old frame parameters
		ROT_MATRIX;
		CORDIC_MODE;
		BP_THRESH;
		%Convergence criteria for mean shift
		FIXED_ITER;
		EPSILON;
		MAX_ITER;
		%Sparse vector options
		SPARSE_FAC;
		%Window sizing methods
		WSIZE_METHOD;
		WSIZE_CONT;		%Continously resize window (on each iteration) if true.
						%Default is false (resize at final iteration)
	end

	% METHOD ENUM
	properties (Constant = true, GetAccess = 'public')
		%Tracking method constants
		MOMENT_WINACCUM = 1;
		MOMENT_IMGACCUM = 2;
		KERNEL_DENSITY  = 3;
		SPARSE_WINDOW   = 4;
		SPARSE_IMG      = 5;
		MOMENT_WINVEC   = 6;
		%Window size method constants
		ZERO_MOMENT     = 1;
		EIGENVEC        = 2;
		HALF_EIGENVEC   = 3;
		%Continously size window = 1, Size at end of frame = 2
		%This is done to avoid 0 index problems in the GUI
		methodStr       = {'Windowed moment accumulation', ...
			               'Un-windowed moment accumulation', ...
					       'Kernel Density Estimation', ...
                           'Sparse moment window', ...
                           'Sparse moment (no window)', ...
                           'Windowed moment accum (vectored)'};
		wMethodStr      = {'Zero Moment', ...
                           'Eigenvector length', ...
                           'Half of eigenvector length'};
        contStr         = {'Continous', 'Once per frame'};
		pStr            = 'csTracker :'; %debugging string prefix
	end

	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function T = csTracker(varargin)
		% CSTRACKER CONSTRUCTOR
		% Generate a new csTracker object

			switch nargin
				case 0
					%Default setup
					T.method       = 1;
					T.verbose      = 0;
					T.fParams      = [];
					T.ROT_MATRIX   = 0;
					T.CORDIC_MODE  = 0;
					T.BP_THRESH    = 0;
					T.FIXED_ITER   = 1;
					T.MAX_ITER     = 8;
					T.EPSILON      = 0;
					T.SPARSE_FAC   = 4;
					T.WSIZE_METHOD = 1;
					T.WSIZE_CONT   = 1;		%continously re-size the tracking window
				case 1
					if(isa(varargin{1}, 'csTracker'))
						T = varargin{1};
					else
						if(~isa(varargin{1}, 'struct'))
							error('Expecting options structure');
						end
						opts = varargin{1};
						T.method       = opts.method;
						T.verbose      = opts.verbose;
						T.fParams      = opts.fParams;
						T.ROT_MATRIX   = opts.rotMatrix;
						T.CORDIC_MODE  = opts.cordicMode;
						T.BP_THRESH    = opts.bpThresh;
						T.FIXED_ITER   = opts.fixedIter;
						T.MAX_ITER     = opts.maxIter;
						T.EPSILON      = opts.epsilon;
						T.SPARSE_FAC   = opts.sparseFac;
						T.WSIZE_METHOD = opts.wsizeMethod;
						T.WSIZE_CONT   = opts.wsizeCont;
					end
				otherwise
					error('Incorrect input arguments');
			end
		
		end 	%csTracker CONSTRUCTOR

		% ------------------------ %
		% ---- GETTER METHODS ---- %
		% ------------------------ %

		% ---- getOpts() : GET AN OPTIONS STRUCTURE (for csToolGUI)
		function opts = getOpts(T)	

			opts = struct('method'    ,  T.method,     ...
                          'verbose'   ,  T.verbose,    ...
                          'rotMatrix' ,  T.ROT_MATRIX,  ...
                          'fParams'   ,  T.fParams,    ...
                          'cordicMode',  T.CORDIC_MODE, ...
                          'bpThresh'  ,  T.BP_THRESH,   ...
                          'fixedIter' ,  T.FIXED_ITER,  ...
                          'maxIter'   ,  T.MAX_ITER,    ...
                          'epsilon'   ,  T.EPSILON,     ...
                          'sparseFac' ,  T.SPARSE_FAC,  ...
                          'wsizeMethod', T.WSIZE_METHOD, ...
                          'wsizeCont',   T.WSIZE_CONT);
		end 	%getOpts()

		% ------------------------ %
        % ---- SETTER METHODS ---- %
		% ------------------------ %
		
        function setTrackMethod(T, method)
            %sanity check
            if(method < 1 || method > length(T.methodStr))
                error('Method value out of range (must be 1 to %d)', T.methodStr)
            end
            T.method = method;
        end     %setTrackMethod()
		
		% ---- setPrevParams() : STORE PARAMETERS FOR SUBSEQUENT FRAME
		function setParams(T, params)
			%SETPREVPARAMS
			% Tout = setPrevParams(T, params) sets the initial window
			% parameters for the next frame. Typically, the final window
			% position from the current frame is used
			
			%Do basic arg check
			if(length(params) ~= 5)
				error('Incorrect number of parameters');
			end
			T.fParams = params;
		end

		function setVerbose(T, verbose)
			T.verbose = verbose;
		end

		% ---- trackFrame() : PERFORM TRACKING ON FRAME
		function trackFrame(T, fh, varargin)
		% TRACKFRAME
		% Peform tracking computation on the frame handle contained in fh.
		%
		% trackFrame(T, fh)
		% trackFrame(T, fh, wpos)
		%
		% csTracker.trackFrame() performs the tracking method specified in T.method 
		% on the frame contained in the frame handle fh. The window position is read
		% out of T.fparams. To override this behaviour, pass an extra parameter to
		% csTracker.trackFrame() containing the preferred window position. Note that
		% it is the callers responsibility to ensure this argument is correct.

		% Stefan Wong 2013

			%Get initial tracking position
			if(~isempty(varargin))
				wpos = varargin{1};
			else
				%wpos = fh.winInit;
				wpos = T.fParams;
			end	
			%Warn about empty wpos and quit loop
			if(isempty(wpos))
				fprintf('ERROR: Empty window position vector\n');
				return;
			end

			status = msProcLoop(T, fh, wpos);
			if(status == -1)
				fprintf('WARNING: problem tracking frame %s\n', get(fh, 'filename'));
			end
			
		end 	%trackFrame()

		function [status varargout] = initWindow(T, varargin)
		% INITWINDOW
		% Use a specified initialisation scheme to set the initial window position
		% for tracking.
		
			%Forward the variable arguments to initParam, this function just checks
			%that the param it returns is sensible
			wparam = initParam(T, varargin);
			
			%Check that wparam isn't borked
			if(numel(wparam) == 0)
				fprintf('ERROR: wparam contains no elements\n');
				status = -1;
				if(nargout > 1)
					varargout{1} = [];
				end
				return;
			end
			if(sum(wparam) == 0)
				fprintf('ERROR: Winparams all zeros\n');
				status = -1;
				if(nargout > 1)
					varargout{1} = [];
				end
				return;
			end
			T.fParams = wparam;
			status = 0;
			if(nargout > 1)
				varargout{1} = wparam;
			end

		end 	%initWindow()

		function disp(T)
			csTracker.tDisplay(T);
		end

	end 		%csTracker METHODS (Public)

	methods (Access = 'private')	
		% ---- imgAccum()   : WHOLE IMAGE MOMENT ACCUMULATION
		[moments]         = imgAccum(T, bpimg);
		[moments]         = imgAccumVec(T, bpvec, varargin);
		% ---- winAccum()   : WINDOWED MOMENT ACCUMULATION
		[moments]         = winAccum(T, bpvec, wparam, dims);
		[moments]         = winAccumImg(T, bpimg, wparam, varargin);
		[moments]         = winAccumVec(T, bpvec, wparam, dims, varargin);
		% ---- wparamComp() : FIND WINDOW PARAMETERS FROM MOMENT SUMS
		wparam            = wparamComp(T, moments, varargin);
		wparam            = initParam(T, varargin);
		% ---- SPARSE VECTOR ENCODE AND DECODE 
		%[spvec varargout] = buf_spEncode(bpimg, varargin);
		%[bpvec varargout] = buf_spDecode(spvec, varargin);
		% --- PROCESSING LOOP ----
		%status            = msProcLoop(T, fh, trackWindow);
	end 		%csTracker METHODS (Private)

	methods (Static)
		tDisplay(T);
	end 		%csTracker METHODS (Static)

end 			%classdef csTracker()
