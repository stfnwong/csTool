function [moments] = winAccumVec(T, bpvec, wparam, dims, varargin)
% WINACCUMVEC
% Windowed moment accumulation for camshift tracker. This method performs moment 
% accumulation only within the area specified by the 'wparam' argument. wparam should 
% be supplied as a 5 element row or column vector. If no wparam is supplied, a new set
% of window parameters is calculated from the moments take over the whole image.
%
% ARGUMENTS:
% T      - csTracker object.
% bpvec  - Backprojection vector for the frame to be tracked.
% wparam - Window parameters of previous frame. Set this to empty to compute a new
%          set of window parameters from the image moments.
% dims   - Dimensions of image. Set this to empty to use the default resolution 
%          (640 x 480)
% (Optional)
% 'force'- Force winAccumVec to check that bpvec contains segmented pixels. It is 
%          assumed by default that the caller has established the bpvec to be passed
%          in has segmented pixels in order to keep the tracking time short. To force
%          a check here, pass the 'force' flag.
%
% OUTPUTS:
% moments - 6 element row vector of moment sums
%

% Stefan Wong 2013

	%INTERNAL CONSTANTS
	DEBUG = true;
	FORCE = false;

	%if(~isempty(varargin))
	%	if(strncmpi(varargin{1}, 'force', 5))
	%		FORCE = true;
	%	end
	%end

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'force', 5))
					FORCE  = true;
				elseif(strncmpi(varargin{k}, 'sp', 2))
					spstat = varargin{k+1};
				end
			end
		end
	end

	if(isempty(wparam))
		%No window parameters supplied, compute new ones
		moments = imgAccum(T, bpvec);
	else
		%Check wparam
		if(numel(wparam) == 0)
			fprintf('%s no data in wparam\n', T.pStr);
			moments = zeros(1,5);
			return;
		end
	end

	if(isempty(dims))
		fprintf('%s WARNING: No image dimensions supplied, using VGA resolution\n', T.pStr);
		dims = [640 480];
	end
	
	if(FORCE)
		%Check segmented pixels
		if(T.BP_THRESH > 0)
			[~, idx] = find(bpvec(1,:) > T.BP_THRESH & bpvec(2,:) > T.BP_THRESH);
		else
			[~, idx] = find(bpvec(1,:) > 0 & bpvec(2,:) > 0);
		end
		if(isempty(idx))
			fprintf('%s ERROR: no segmented pixels in bpvec\n', T.pStr);
			moments = zeros(1,5);
			wparam  = zeros(1,5);
			return;
		end
	end	
	
	%Accumulate moments for tracker
	if(T.ROT_MATRIX)
		%Make aliases 
		xc    = wparam(1);
		yc    = wparam(2);
		theta = wparam(3);
		axmaj = wparam(4);
		axmin = wparam(5);
		xlim  = [(xc - axmaj) (xc + axmaj)];
		ylim  = [(yc - axmin) (yc + axmin)];
		%Clean up edges of bounding region
		xlim(xlim > dims(1)) = dims(1);
		xlim(xlim < 1)       = 1;
		ylim(ylim > dims(2)) = dims(2);
		ylim(ylim < 1)       = 1;
		%Initialise moment sums
		M00 = 0; M10 = 0; M01 = 0; M11 = 0; M20 = 0; M02 = 0;
		%Find pixels within window region of vector
		for k = 1:length(bpvec)
			if(bpvec(1,k) >= xlim(1) && bpvec(1,k) <= xlim(2) && ...
               bpvec(2,k) >= ylim(1) && bpvec(2,k) <= ylim(2))
				%This pixel is in window
				M00 = M00 + 1;
				M10 = M10 + bpvec(1,k);
				M01 = M01 + bpvec(2,k);
				M11 = M11 + bpvec(1,k) .* bpvec(2,k);
				M20 = M20 + bpvec(1,k) .* bpvec(1,k);
				M02 = M02 + bpvec(2,k) .* bpvec(2,k);
			end
		end
		if(exist('spstat', 'var'))
			M00 = M00 * spstat.fac;
		end
		moments = [M00 M10 M01 M11 M20 M02];
	else
		fprintf('Linear Constraint not yet implemented\n');
		moments = zeros(1,5);
		return;
	end



end 	%winAccumVec()
	
