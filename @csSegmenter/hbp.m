function bpimg = hbp(S, img, rhist, varargin)
% HBP
% bpimg = hbp(S, img, rhist, KDENS, [..OPTIONS..])
%
% Perform histogram backprojection on the image img using the ratio 
% histogram rhist.
%
% ARGUMENTS:
% S      - csSegmenter object
% img    - Image to backproject.
% rhist  - Ratio histogram to use for backprojection
% KDENS  - If true, use the kernel density lookup table in S.
%
% (OPTIONAL ARGUMENTS)
% bins   - Provide an alternate bins structure. If this option isn't 
%          supplied, the bin values are automatically computed from 
%          S.N_BINS.
% offset - If this routine is being called to process the image in blocks,
%          the offset parameter can be used to shift pixels to thier 
%          correct locations in the original image for the purposes of 
%          calculating the kernel weighting function.
%
% OUTPUTS 
% bpimg - Backprojected image

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'bins', 4))
					bins = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'offset', 6))
					offset = varargin{k+1};
				end
			end
		end
	end

	%if(isempty(KDENS))
	%	KDENS = false;
	%end
	if(~exist('bins', 'var'))
		bins = S.N_BINS .* (1:S.N_BINS);
	end
	if(~exist('offset', 'var'))
		offset = [0 0];
	end

	% If the d output is note requested, img_w becomes img_w * d
	[img_h img_w d] = size(img); %#ok
	bpimg = zeros(img_h, img_w);

	for x = 1:img_w
		for y = 1:img_h
			if(img(y,x) ~= 0)
				if(S.kWeight)
					pixel = [x y] + offset;
					kw = kernelLookup(S, pixel);
					if(kw > 0)
						idx = find(bins > img(y,x), 1, 'first');
						bpimg(y,x) = kw * rhist(idx);
					end
				%elseif(S.HIST_BP_BLOCK)
				%	
				else
					idx = find(bins > img(y,x), 1, 'first');
					if(rhist(idx) > S.BP_THRESH)
						bpimg(y,x) = rhist(idx);
					end
				end
			end
		end
	end


end 	%hbp()
