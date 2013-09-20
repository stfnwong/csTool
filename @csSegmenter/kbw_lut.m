function pixWeight = kbw_lut(pixel, xyPrev, varargin)
% KBW_LUT
% Kernel Bandwidth Lookup-Table
%
% pixWeight = kbw_lut(pixel, [..OPTIONS..])
%
% This function simulates the kernel bandwidth lookup table in the FPGA.
% The co-ordinates of the current pixel are compared against the last known
% co-ordinates of the target, and are weighted according to a simple linear
% interpolation along the points. The amount of quantisation can be 
% specified with the 'quant' argument. 
%
% ARGUMENTS
% pixel - Two element vector containing postion of pixel
% xyPrev - Last known location of target (y0)
%
% [OPTIONAL ARGUMENTS]
% 'quant' - Set number of quantisation points for linear interpolation. 
%           Example: set quant to 4 to produce 4 'bins' equally spaced
%           between the center of the kernel and the edge of its bandwidth.
%           If the kernel bandwidth is 64, this produces 'bins' at 1, 17,
%           33, and 64. 
% 'scale' - Set the scaling factor for the output pixel. By default the 
%           output is returned as a float with range [0 1]. This means that
%           once quantisation has been performed, the output will be 
%           rescaled so that the distance from center to bandwidth limit is
%           expressed as a fraction. Adjusting this parameter allows the 
%           fraction to be scaled to fit the precision in the FPGA
%
% OUTPUTS
% pixWeight - The weighted value of the pixel based on input parameters.
%             If no scale is specified, this is returned as a float with 
%             range [0 1], otherwise a scaling factor can be added with the
%             'scale' argument (i.e.: scale to 2^n values by setting scale
%             to n)
%

% Stefan Wong 2013

	% Check optional arguments
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'quant', 5))
					quant = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'scale', 5))
					S_FAC = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'bw', 2))
					bw    = varargin{k+1};
				end
			end
		end
	end

	% Check what we have
	if(~exist('bw', 'var'00
		bw = 64;
	end
	if(~exist('quant', 'var'))
		quant = 4; 	%assume 2-bit resolution
	end

	xd = abs(pixel(1) - xyPrev(1));
	yd = abs(pixel(2) - xyPrev(2));

	if(xd <= bw && yd <= bw)
		% Generate LUT and get pixel entry
		q = 1 : (bw/quant) : bw;
		for k = 1 : length(q)
			if(xd <= q(k) && yd <= q(k))
				q         = q ./ max(q);
				if(exist('S_FAC', 'var'))
					q = fix(2^S_FAC .* q);
				end
				pixWeight = q(k);
			end
		end
		% Paranoid about this check, but in practice should be fine
		if(~exist('pixWeight', 'var'))
			fpritnf('ERROR: pixWeight unassigned - setting to zero\n');
			pixWeight = 0;
		end
	else
		pixWeight = 0;
	end

end 	%kbw_lut()
