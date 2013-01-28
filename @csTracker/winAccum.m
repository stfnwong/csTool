function [moments wparam] = winAccum(T, bpvec, varargin)
% WINACCUM
%
% Windowed moment accumulation for camshift tracker. This method performs the moment
% accumulation only within the area specified by the 'wparam' argument. wparam should
% be supplied as a name/value pair, with the string 'wparam' followed by a 5-element
% row or column vector. If no wparam is supplied, a new set of window parameters is
% calculated from the image moments taken over the whole image

% Stefan Wong 2012

	%INTERNAL DEBUGGING CONSTANT
	DEBUG = 1;

	if(nargin > 1)
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				%Check which option this is
				if(strncmpi(varargin{k}, 'wparam', 6))
					wparam = varargin{k+1};
				end
			end
		end		
	else
		%Not enough arguments to have any window parameters from a previous frame, 
		% so compute new ones from imgAccum();
		moments = imgAccum(T, bpvec);
		wparam  = wparamComp(moments);
		return;
	end

	%Use threshold?
% 	if(T.BP_THRESH > 0)
% 		[idy idx] = find(bpvec > T.BP_THRESH);
% 	else
% 		[idy idx] = find(bpvec > 0);
% 	end
% 	if(isempty(idx) || isempty(idy))
% 		fprintf('ERROR: Image contains no segmented pixels\n');
% 		moments = zeros(1,5);
% 		wparam  = zeros(1,5);
% 		return;
% 	end

    if(T.BP_THRESH > 0)
        [~, idx] = find(bpvec(1,:) > T.BP_THRESH & bpvec(2,:) > T.BP_THRESH);
    else
        [~, idx] = find(bpvec(1,:) > 0 * bpvec(2,:) > 0);
    end
    if(isempty(idx))
        fprintf('ERROR: Image contains no segmented pixels\n');
        moments = zeros(1,5);
        wparam  = zeros(1,5);
        return;
    end

	%Get image size
	[img_h img_w d] = size(bpvec);
	if(d > 1)
		fprintf('%s more than one channel found!\n', T.pStr);
	end
	%Do sanity check on idx
    if(length(idx) > img_w * img_h)
        fprintf('%s idx length : %d\n', T.pStr, length(idx));
        fprintf('%s img size   : %d\n', T.pStr, img_w * img_h);
        moments = zeros(1,5);
        wparam  = zeros(1,5);
        return ;
    end
% 	if(length(idx) > img_w * img_h || length(idy) > img_w * img_h)
% 		fprintf('%s idx length : %d\n', T.pStr, length(idx));
% 		fprintf('%s idy length : %d\n', T.pStr, length(idy));
% 		fprintf('%s img size   : %d\n', T.pStr, img_w * img_h);
% 		moments = zeros(1,5);
% 		wparam  = zeros(1,5);
% 		return;
% 	end
	
	%Find edge of constraining rectangle.
	%Depending on options set in csTracker, we either apply a rotation matrix to the
	%parameters, or we solve a set of 4 linear constraints and take pixels that fall
	%within the intersection of the lines
	if(T.ROT_MATRIX)
		%use rotation matrix
		xc     = wparam(1);
		yc     = wparam(2);
		theta  = wparam(3) * (pi/180);
		axmaj  = wparam(4);
		axmin  = wparam(5);
        %Find pixels in window
        xlim               = [(xc - axmaj) (xc + axmaj)];
        ylim               = [(yc - axmin) (yc + axmin)];
        xlim(xlim > img_w) = img_w;
        ylim(ylim > img_h) = img_h;
        xlim(xlim < 0)     = 0;
        ylim(ylim < 0)     = 0;
        [~, idx] = find(bpvec(1,:) >= xlim(1) & bpvec(1,:) <= xlim(2) ...
                      & bpvec(2,:) >= ylim(1) & bpvec(2,:) <= ylim(2));
        winvec    = bpvec(:,idx);

		if(length(winvec) < 1)
			fprintf('WARNING: No pixels fell within window\n');
			moments = zeros(1,5);
			wparam  = zeros(1,5);
			return;
		end
		%Compute moment sums
		M00    = length(winvec);
		M10    = sum(winvec(1,:));
		M01    = sum(winvec(2,:));
		M11    = sum(winvec(1,:) .* winvec(2,:));
		M20    = sum(winvec(1,:) .* winvec(1,:));
		M02    = sum(winvec(2,:) .* winvec(2,:));

	else
		%Solve 4 linear constraints for bounding box
		fprintf('WARNING: Linear constraints not yet implemented!\n');
	end
	%Normalise moment sums
	%xm      = M10 / M00;
	%ym      = M01 / M00;
	%xym     = M11 / M00;
	%xxm     = M20 / M00;
	%yym     = M02 / M00;
	moments = [M00 M10 M01 M11 M20 M02];
	%Compute window parameters from moments
	wparam  = wparamComp(T, moments);
	%do sanity check on wparam
	if(wparam(4) > img_w)
		fprintf('WARNING: wparam(4) > %d (%f)\n', img_w, wparam(4));
	end
	if(wparam(5) > img_h)
		fprintf('WARNIING: wparam(5) > %d (%f(\n', img_h, wparam(5));
	end


end 	%winAccum()
