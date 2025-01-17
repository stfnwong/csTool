function [moments wparam] = winAccum(T, bpvec, wparam, dims)
% WINACCUM
%
% Windowed moment accumulation for camshift tracker. This method performs the moment
% accumulation only within the area specified by the 'wparam' argument. wparam should
% be supplied as a 5 element row or column vector. If no wparam is supplied, a new set
% of window parameters is calculated from the image moments taken over the whole 
% image

% Stefan Wong 2012

	%INTERNAL DEBUGGING CONSTANT
	DEBUG = 1;

% 	if(~isempty(varargin))
% 		for k = 1:length(varargin)
% 			if(ischar(varargin{k}))
% 				%Check which option this is
% 				if(strncmpi(varargin{k}, 'wparam', 6))
% 					wparam = varargin{k+1};
% 				end
% 			end
% 		end		
% 	else
% 		%Not enough arguments to have any window parameters from a previous frame, 
% 		% so compute new ones from imgAccum();
% 		moments = imgAccum(T, bpvec);
% 		wparam  = wparamComp(moments);
% 		return;
% 	end

	if(isempty(wparam))
		%No window parameters from a previous frame - compute new ones
		moments = imgAccum(T, bpvec);
		wparam  = wparamComp(moments);
	end
	if(isempty(dims))
		fprintf('%s WARNING: No image dimensions supplied \n', T.pStr);
		fprintf('%s WARNING: Possible bpvec errors\n', T.pStr);
	end

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
		fprintf('ERROR: Discrepency in idx length and img size\n');
        fprintf('%s idx length : %d\n', T.pStr, length(idx));
        fprintf('%s img size   : %d\n', T.pStr, img_w * img_h);
        moments = zeros(1,5);
        wparam  = zeros(1,5);
        return ;
    end

	%Quit if wparam is badly-formed
	if(numel(wparam) == 0)
		fprintf('%s no data in wparam\n', T.pStr);
		moments = zeros(1,5);
		wparam  = zeros(1,5);
		return;
	end
	
	%Find edge of constraining rectangle.
	%Depending on options set in csTracker, we either apply a rotation matrix to the
	%parameters, or we solve a set of 4 linear constraints and take pixels that fall
	%within the intersection of the lines
	%
	% NOTE ON VECTORISATION:
	% The easiest way to do this (for a rectangular region) is (I think) to
	% just made a copy of the submatrix of pixels in the tracking region,
	% and then operate on that. If the region is elliptical, we could just
	% find the rectangle that encloses the ellipse, and take that as the
	% subregion, remembering to perform the ellipse test 
	%if(T.ROT_MATRIX)
		%use rotation matrix
		%Create some aliases to make reading the process simpler
		xc                 = wparam(1);
		yc                 = wparam(2);
		theta              = wparam(3) * (pi/180);		%convert back to radians
		axmaj              = wparam(4);
		axmin              = wparam(5);
        %Find pixels in window
        xlim               = [(xc - axmaj) (xc + axmaj)];
        ylim               = [(yc - axmin) (yc + axmin)];
        xlim(xlim > img_w) = img_w;
        ylim(ylim > img_h) = img_h;
		%MATLAB uses 1-indexing (!!!)
        xlim(xlim < 1)     = 1;
        ylim(ylim < 1)     = 1;
		%NOTE: This is a hack for testing purposes
		if(~exist('dims', 'var'))
			dims = [640 480];
		end
		bpImg              = bpvec2img(bpvec, dims);
		winImg             = bpImg(xlim, ylim);
		winvec             = bpimg2vec(winImg);
        %[~, idx] = find(bpvec(1,:) >= xlim(1) & bpvec(1,:) <= xlim(2) ...
        %              & bpvec(2,:) >= ylim(1) & bpvec(2,:) <= ylim(2));
        %winvec    = bpvec(:,idx);

% 		if(length(winvec) < 1)
% 			fprintf('WARNING: No pixels fell within window\n');
% 			moments = zeros(1,5);
% 			wparam  = zeros(1,5);
% 			return;
% 		end
		%Compute moment sums
		M00    = length(winvec);
		M10    = sum(winvec(1,:));
		M01    = sum(winvec(2,:));
		M11    = sum(winvec(1,:) .* winvec(2,:));
		M20    = sum(winvec(1,:) .* winvec(1,:));
		M02    = sum(winvec(2,:) .* winvec(2,:));

	%else
		%Solve 4 linear constraints for bounding box
		%fprintf('WARNING: Linear constraints not yet implemented!\n');
	%end
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
