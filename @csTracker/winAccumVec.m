function [moments wparam] = winAccumVec(T, bpvec, wparam, dims, varargin)
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
% wparam  - 5 element vector of window parameters
%

% Stefan Wong 2013

	%INTERNAL CONSTANTS
	DEBUG = true;
	FORCE = false;

	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'force', 5))
			FORCE = true;
		end
	end

	if(isempty(wparam))
		%No window parameters supplied, compute new ones
		moments = imgAccum(T, bpvec);
		wparam  = wparamComp(moments);
	else
		%Check wparam
		if(numel(wparam) == 0)
			fprintf('%s no data in wparam\n', T.pStr);
			moments = zeros(1,5);
			wparam  = zeros(1,5);
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
		

		%Find pixels within window region of vector

	else
		fprintf('Linear Constraint not yet implemented\n');
		moments = zeros(1,5);
		wparam  = zeros(1,5);
		return;
	end



end 	%winAccumVec()
	
