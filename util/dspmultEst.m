function [nbits varargout] = dspmultEst(imsz, vlen, vdim, N, varargin)
% DSPMULTEST
% Estimate the DSP multiplier bit usage. This function assumes EP4C115F73CN FPGA 
% which has 9-bit multipliers. To change the device multiplier word size, use the
% 'mult' switch followed by the width in bits
%
% ARGUMENTS
% imsz - Vector of image size in [h w ] form
% vlen - Length of vector in vectorised dimension (typically 8 or 16)
% vdim - Dimension which is vectored. Any of ('x'/'y'), ('h'/'w') or ('row'/'col').
% N    - Number of tracking pipelines in system 
%


% Stefan Wong 2013

	%Constants for pipeline
	MU_PIPE = 6;
	CORDIC_DEG = 1;

	stepped = false;
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'mult', 4))
					msize = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'accumw', 6))
					accumw = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'stepped', 7))
					stepped = true;
				elseif(strncmpi(varargin{k}, 'grad', 4))
					grad = varargin{k+1};
				end
			end
		end
	end

	%Check input arguments
	if(~exist('msize', 'var'))
		msize = 9;
	end
	if(~exist('accumw', 'var'))
		accumw = 35;
	end
	if(~exist('grad', 'var'))
		grad = 1;	%amount of gradiation in backprojection image
	else
		grad = 2 ^ (nextpow2(grad));
	end
	if(stepped)
		%Compute multiplier size if register sizes are stepped to match moment order
		zm = 0; xm = 0; ym = 0; xym = 0; xxm = 0; yym = 0;
		for y = 1:imsz(1)
			for x = 1:imsz(2)
				zm  = zm  + 1;
				xm  = xm  + x;
				ym  = ym  + y;
				xym = xym + x * y;
				xxm = xxm + x * x;
				yym = yym + y * y;
			end
		end
		moments = [zm xm ym xym xxm yym];
		for k = length(moments):-1:1
			accumw(k) = ceil(log2(moments(k)));
		end
		for k = 1:length(moments)
			fprintf('Moments [%d] : word size = %d\n', k, accumw(k));
		end
	end

	%In all cases, we need 6 internal multiply passes
	if(length(accumw) > 1)
		baccum = grad * sum(accumw);
	else
		baccum = grad * 6 * accumw;
	end
	%In all cases we need the number of mulitipliers in moment pipeline
	if(length(accumw) > 1)
		mpipe = accumw(end) * MU_PIPE + CORDIC_DEG;
	else
		mpipe = accumw * MU_PIPE * CORDIC_DEG;
	end
	
	if(strncmpi(vdim, 'y', 1) || strncmpi(vdim, 'h', 1) || strncmpi(vdim, 'col', 3))
		%Need to expand scalar along column dimension, compute required word size
		vexp  = 2 * vlen * ceil(log2(imsz(1)));
		total = baccum + vexp + mpipe;
		nmult = ceil(total / msize); 
		if(nargout > 1)
			%Generate more detailed statistics
			if(mod(total, msize) == 0)
				dspstat.exact = true;
			else
				dspstat.exact = false;
			end
			dspstat.total  = total;
			dspstat.accum  = vexp + baccum;
			dspstat.vexp   = vexp;
			dspstat.baccum = baccum;
			dspstat.nmult  = nmult;
			varargout{1}   = dspstat;
		end
		nbits = total;
		return;
	elseif(strncmpi(vdim, 'x', 1) || strncmpi(vdim, 'w', 1) || strncmpi(vdim,'row',3))
		%Need to expand scalar along row dimension, compute required word size
		vexp  = 2 * vlen * ceil(log2(imsz(2)));
		total = baccum + vexp + mpipe;
		nmult = ceil(total / msize);
		if(nargout > 1)
			if(mod(total, msize) == 0)
				dspstat.exact = true;
			else
				dspstat.exact = false;
			end
			dspstat.accum  = vexp + baccum;
			dspstat.vexp   = vexp;
			dspstat.baccum = baccum;
			dspstat.nmult  = nmult;
			varargout{1}   = dspstat;
		end
		nbits = total;
		return; 
	else
		fprintf('Invalid vector dimension %s\n', vdim);
		nbits = -1;
		if(nargout > 1)
			varargout{1} = -1;
		end
		return;
	end

end 	%dspmultEst()

