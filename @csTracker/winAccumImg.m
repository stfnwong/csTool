function [moments wparam] = winAccumImg(T, bpimg, wparam, varargin)
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
		wparam  = wparamComp(T, moments, 'norm');
	else
		%Check wparam
		if(numel(wparam) == 0)
			fprintf('%s no data in wparam\n', T.pStr);
			moments = zeros(1,5);
			wparam  = zeros(1,5);
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
		bpRegion             = bpimg(ylim(1):ylim(2), xlim(1):xlim(2));
		%Get backprojected pixels and create moment sums
		if(T.BP_THRESH > 0)
			[idy idx] = find(bpRegion > T.BP_THRESH);
		else
			[idy idx] = find(bpRegion > 0);
		end
		if(isempty(idx) || isempty(idy))
			fprintf('%s ERROR: No segmented pixels in bpRegion\n', T.pStr);
			moments = zeros(1,5);
			wparam  = zeros(1,5);
			return;
		end
		M00     = length(idx);
		M10     = sum(idx);
		M01     = sum(idy);
		M11     = sum(idx .* idy);
		M20     = sum(idx .* idx);
		M02     = sum(idy .* idy);
		moments = [M00 M10 M01 M11 M20 M02];
		wparam  = wparamComp(T, moments);
		%Clip wparam to image region
		if(wparam(4) > dims(2))
			wparam(4) = dims(2);
			if(T.verbose)
				fprintf('%s clipped wparam(4) to %d\n', T.pStr, dims(2));
			end
		end
		if(wparam(4) < 1)
			wparam(4) = 1;
			if(T.verbose)
				fprintf('%s clipped wparam(4) to 1\n', T.pStr);
			end
		end
		if(wparam(5) > dims(1))
			wparam(5) = dims(1);
			if(T.verbose)
				fprintf('%s clipped wparam(5) to %d\n', T.pStr, dims(1));
			end
		end
		if(wparam(5) < 1)
			wparam(5) = 1;
			if(T.verbose)
				fprintf('%s clipped wparam(5) to %d\n', T.pStr);
			end
		end

	else
		fprintf('Linear Constraints currently not implemented\n');
		moments = zeros(1,5);
		wparam  = zeros(1,5);
	end


end 	%winAccumImg()


