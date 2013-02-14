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
%
%

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
	end

	% METHOD ENUM
	properties (Constant = true, GetAccess = 'public')
		MOMENT_WINACCUM = 1;
		MOMENT_IMGACCUM = 2;
		KERNEL_DENSITY  = 3;
		methodStr       = {'Windowed moment accumulation', ...
			               'Un-windowed moment accumulation', ...
					       'Kernel Density Estimation' };
		pStr            = 'csTracker :';
	end

	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function T = csTracker(varargin)
		% CSTRACKER CONSTRUCTOR
		% Generate a new csTracker object

			switch nargin
				case 0
					%Default setup
					T.method      = 1;
					T.verbose     = 0;
					T.fParams     = [];
					T.ROT_MATRIX  = 0;
					T.CORDIC_MODE = 0;
					T.BP_THRESH   = 0;
					T.FIXED_ITER  = 1;
					T.MAX_ITER    = 8;
					T.EPSILON     = 0;
				case 1
					if(isa(varargin{1}, 'csTracker'))
						T = varargin{1};
					else
						if(~isa(varargin{1}, 'struct'))
							error('Expecting options structure');
						end
						opts = varargin{1};
						T.method      = opts.method;
						T.verbose     = opts.verbose;
						T.fParams     = opts.fparams;
						T.ROT_MATRIX  = opts.rotMatrix;
						T.CORDIC_MODE = opts.cordicMode;
						T.BP_THRESH   = opts.bpThresh;
						T.FIXED_ITER  = opts.fixedIter;
						T.MAX_ITER    = opts.maxIter;
						T.EPSILON     = opts.epsilon;
					end
				otherwise
					error('Incorrect input arguments');
			end
		
		end 	%csTracker CONSTRUCTOR

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
		%
		% The value is T.FIXED_ITER determines the kind of tracking loop to use. If 
		% T.FIXED_ITER is 1, the tracking will perform T.MAX_ITER loops for every 
		% frame. This can be useful to see that there are no side effects to 
		% overtracking in the FPGA. If T.FIXED_ITER is 0, the tracking will continue
		% until eps is less than T.EPSILON in each dimension of eps (e.g: eps(1) <
		% T>EPSILON && eps(2) < T.EPSILON)

			%Get initial tracking position
			if(nargin > 2)
				wpos = varargin{2};
			else
				%wpos = fh.winInit;
				wpos = T.fParams;
			end	

			if(T.FIXED_ITER)
				%Allocate memory
				tVec     = zeros(2, T.MAX_ITER);
				fwparam  = cell(1, T.MAX_ITER);
				fmoments = cell(1, T.MAX_ITER);
                fprintf('(csTracker) Size bpVec :\n');
                disp(size(get(fh, 'bpVec')));
				for n = 1:T.MAX_ITER
					switch T.method
						case T.MOMENT_WINACCUM
							[moments wparam] = winAccum(T, get(fh, 'bpVec'), 'wparam', wpos);
						case T.MOMENT_IMGACCUM
							wparam           = [];
							moments          = imgAccum(T, get(fh, 'bpVec'));
						case T.KERNEL_DENSITY
							fprintf('Not yet implemented\n');
						otherwise
							error('Invalid tracking type');
					end
					%Write out results
					tVec(:,n)   = [moments(1) ; moments(2)];
					fwparam{n}   = wparam;
					fmoments{n} = moments;
					%Get initial window position for next frame
					wpos        = wparam;		
                    %TODO: Place a test here for early convergence?
                    % BAIL if no pixels in window
                    if(sum(moments) == 0)
						fprintf('No pixels in previous window (iter %d) - ending loop\n', n);
						break;
					end
				end
				%DEBUG
				fprintf('Outside tracking loop...\n');
			else
				%For now, preallocate twice MAX_ITER for tVec
				tVec     = zeros(1, T.MAX_ITER * 2);
				fwparam  = cell(1, T.MAX_ITER * 2);
				fmoments = cell(1, T.MAX_ITER * 2);
				%Converge until tVec(n) - tVec(n-1) < T.EPSILON
				n   = 1;
				eps = [T.EPSILON + 1; T.EPSILON + 1];
				while( eps(1) > T.EPSILON && eps(2) > T.EPSILON)
					switch T.method
						case T.MOMENT_WINACCUM
							[moments wparam] = winAccum(T, get(fh, 'bpVec'), 'wparam', wpos);
						case T.MOMENT_IMGACCUM
							wparam           = [];
							moments          = imgAccum(T, get(fh, 'bpVec'));
						case T.KERNEL_DENSITY
							fprintf('Not yet implemented\n');
						otherwise
							error('Invalid tracking type');
					end
					%Write out results
					tVec(:,n)   = [moments(1) ; moments(2)];
					fwparam{n}  = wparam; 
					fmoments{n} = moments;
					%Compute new eps
					if(n == 1)
						eps = tVec(:,1);
					else
						eps = tVec(:,n) - tVec(:,n-1);
					end
					n = n + 1;
					if(n > T.MAX_ITER)
						fprintf('WARNING: Failed to converge in %d iters\n', T.MAX_ITER);
						break;
					end
				end
			end
				%Write data out to frame handle
                set(fh, 'tVec',      tVec);
                set(fh, 'winParams', fwparam);
                set(fh, 'moments',   fmoments);
				%fh.setTVec(tVec);
				%fh.setWparams(fwparam);
				%fh.setMoments(fmoments);
				%Write internal frame parameters
				T.fParams = fwparam{end};
		end 	%trackFrame()

		function disp(T)
			csTracker.tDisplay(T);
		end

	end 		%csTracker METHODS (Public)

	methods (Access = 'private')	
		% ---- imgAccum()   : WHOLE IMAGE MOMENT ACCUMULATION
		[moments]        = imgAccum(T, bpimg)
		% ---- winAccum()   : WINDOWED MOMENT ACCUMULATION
		[moments wparam] = winAccum(T, bpimg, varargin);
		% ---- wparamComp() : FIND WINDOW PARAMETERS FROM MOMENT SUMS
		wparam           = wparamComp(T, moments);
	end 		%csTracker METHODS (Private)

	methods (Static)
		tDisplay(T);
	end 		%csTracker METHODS (Static)

end 			%classdef csTracker()
