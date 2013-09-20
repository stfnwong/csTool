function wpixel = kernelLookup(S, pixel, varargin)
% KERNELLOOKUP
% wpixel = kernelLookup(T, pixel, [..OPTIONS..])
%
% Lookup the kernel weight value for the two element vector pixel
% By default, kernelLookup() uses the values stored in the csSegmenter 
% object S. Passing a parameter as an option will override the value in S.
%

% Stefan Wong 2013


	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'xyprev', 6))
					xyprev = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'quant', 5))
					quant  = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'bw', 2))
					bw     = varargin{k+1};
				end
			end
		end
	end

	% Check variables - if these dont exist use values in S
	if(~exist('xyprev', 'var'))
		xyprev = S.XY_PREV;
	end
	if(~exist('bw', 'var'))
		bw     = S.kBandwidth; %do pre-lookup check
	end

	Q  = S.getKernelLUT();
	xd = abs(pixel(1) - xyprev(1));
	yd = abs(pixel(2) - xyprev(2));
	% If outside bandwidth, dont bother to lookup
	if(xd > bw && yd > bw)
		wpixel = 0;
		return;
	end

	for k = 1 : length(Q)
		if(xd <= Q(k) && yx <= Q(k))
			wpixel = Q(k);
		end
	end

	% If we get here and the variable wpixel has not be created, weight
	% wpixel as zero (something went wrong and couldnt get entry from LUT)
	if(~exist('wpixel', 'var'))
		wpixel = 0;
	end


end 	%kernelLookup()
