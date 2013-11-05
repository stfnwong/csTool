function klut = gen_kernel_lut(S, scale, bw, quant, varargin)
% GEN_KERNEL_LUT
% klut = gen_kernel_lut(scale, bw, quant)
%
% Generate Lookup Table for a kernel with profile
%
% k(r) =  { ar : 1 < r <= h
%         { 0  : otherwise
%
% Where a is the scaling factor, and h is the bandwidth. To simulate the 
% approximation int he FPGA, the level of quantisation for the lookup table
% can be specified using the quant argument. This should be specified as the
% number of bits of precision made available in the FPGA (ie, 4 value LUT
% should be specifed as 2 (2^2 = 4).
%
% ARGUMENTS
% S     - csSegmenter object
% scale - Scaling factor for kernel 
% bw    - Bandwidth of kernel in pixels
% quant - Quantisation precision for lookup table. If this is empty or equal
%         to one, the output will be represented as a float with range 
%         [0 1].
%
% OPTIONAL ARGUMENTS
% kernel - Pass the string 'kernel' followed by one of 
%          'ekov' - Epanechnikov Kernel
%          'tri'  - Triangular Kernel
%          'flat' - Flat kernel
%

% Stefan Wong 2013

	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'kernel', 6))
			kernel = varargin{2};
		end
	end

	% Check kernel arguments
	if(~exist('kernel', 'var'))
		kernel = 'ekov';
	end

	if(isempty(quant))
		quant = 1;
	end
	if(scale == 0)
		scale = 1;
	end

	if(strncmpi(kernel, 'ekov', 4))
		% Ke(x) = { (a - x)     : x <= a
		%         {  0          : else	
		x = 0 : (bw/quant) : bw;
		q = scale - x;
		q = q ./ max(q);
		if(quant > 1)
			q = fix(scale .* q);
		end
	elseif(strncmpi(kernel, 'tri', 3))
		% Kf(x) = { ax          : 1 < x <= a
		%         { 0           : else
		q = 0 : (bw/quant) : bw;
		q = q ./ max(q);
		if(quant > 1)
			q = fix(scale .* q);
		end
	elseif(strncmpi(kernel, 'flat', 4))
		% Kt(x) = { a           : 1 < x <= a
		%         { 0           : else
		q = scale * ones(length(0 : (bw/quant) : bw));
	else
		fprintf('Invalid kernel [%s]\n', kernel);
		klut = [];
		return;
	end	

	klut = q;

end 	%gen_kernel_lut()
