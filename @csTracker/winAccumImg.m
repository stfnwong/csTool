function [moments] = winAccumImg(T, bpimg, wparam, varargin)
% WINACCUMVEC
% Windowed moment accumulation for camshift tracker. This method performs moment 
% accumulation only within the area specified by the 'wparam' argument. wparam should 
% be supplied as a 5 element row or column vector. If no wparam is supplied, a new set
% of window parameters is calculated from the moments take over the whole image.
%
% ARGUMENTS:
% T      - csTracker object.
% bpimg  - Backprojection image of the frame to be tracked.
% wparam - Window parameters of previous frame. Set this to empty to compute a new
%          set of window parameters from the image moments.
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

	%Sanity check arguments
	if(isempty(wparam))
		%No window parameters supplied - compute new ones
		if(T.verbose)
			fprintf('No window parameters supplied, computing from moments...\n');
		end
		moments = imgAccum(T, bpimg);
	else
		%Check wparam
		if(numel(wparam) == 0)
			fprintf('%s no data in wparam\n', T.pStr);
			moments = zeros(1,5);
			return;
		end
	end

	if(FORCE)
		%TODO: Force check of bpimg 
	end

	if(T.ROT_MATRIX)
		%Make aliases
		dims  = size(bpimg);
		xc    = wparam(1);
		yc    = wparam(2);
		theta = wparam(3);
		axmaj = wparam(4);
		axmin = wparam(5);
		xlim  = fix([(xc - axmaj) (xc + axmaj)]);
		ylim  = fix([(yc - axmin) (yc + axmin)]);
		%Clean up edges of bounding region
		xlim(xlim > dims(2)) = dims(2);
		xlim(xlim < 1)       = 1;
		ylim(ylim > dims(1)) = dims(1);
		ylim(ylim < 1)       = 1;
		%Give up and use two loops
		M00 = 0; M10 = 0; M01 = 0; M11 = 0; M20 = 0; M02 = 0;
		% NOTE : Need to scale the moment sum here by the value in
		% bpimg(y,x)
		for x = xlim(1):xlim(2)
			for y = ylim(1):ylim(2)
				if(bpimg(y,x) > 0)
					M00 = M00 + bpimg(y,x);
					M10 = M10 + x * bpimg(y,x);
					M01 = M01 + y * bpimg(y,x);
					M11 = M11 + x * y * bpimg(y,x);
					M20 = M20 + x * x * bpimg(y,x);
					M02 = M02 + y * y * bpimg(y,x);
				end
			end
		end
		moments  = [M00 M10 M01 M11 M20 M02];
	else
		fprintf('Linear Constraints currently not implemented\n');
		moments = zeros(1,5);
	end


end 	%winAccumImg()


