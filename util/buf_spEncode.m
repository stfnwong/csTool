function [spvec varargout] = buf_spEncode(bpimg, bpsum, varargin)
% BUF_SPENCODE
% Create sparsely coded vector to simulate sparse buffer component
%
% spvec = buf_spEncode(bpimg, [optional arguments])
%
% This function takes a backprojection image and re-codes it to appear as
% it would in the sparse buffer module in the tracking pipeline. The
% function can perform the spatial re-coding by a factor of 2, 4, or 8. 
%
% ARGUMENTS:
% 
% bpimg - Backprojection image to convert to sparse vector
%
% OPTIONAL ARGUMENTS:
%
% 'factor', factor - Pass in the string 'factor' followed by the spatial
%                    reduction factor. Legal values are 1, 2, 4, 8. (Default:
%                    2)
% 'anchor', anchor - Pass in the string 'anchor' followed by one of the
%                    following two-letter strings specifying the anchor
%                    point (the point whose value will be place into the
%                    buffer) (Default: 'tl')
%
%                    'tl' - Top Left corner
%                    'tr' - Top right corner
%                    'bl' - Bottom left corner
%                    'br' - Bottom right corner
%                    
%                    Note that this refers to the extreme corner. In the
%                    case of a fac2 encoding, 'bl' will take on the value
%                    of pixel [x+1. y+1]. In a fac8 encoding,, 'bl' will
%                    take on the value of pixel [x+7, y+7]
%
% 'thresh', thresh - Summing threshold for resulting block. (Default: 2).
%                    This value determines how many pixels there must be in
%                    the encoding block before an element of the sparse
%                    vector is genrated. Typical value is 0.5*(fac^2).
%
% 'auto'           - Automatically determine the scaling factor and buffer
%                    size
% 'trim'           - Automatically resize the vector to be the correct
%                    length. Note that this is slower and is not
%                    reccomended if encoding is to be done in a loop. If
%                    trim is not used, be sure to check for zero values in
%                    the resulting vector.
% 'rtvec'/'rt'     - If the target is small enough (ie: the length of the
%                    backprojection vector is smaller than the implied
%                    buffer size available, and would therfore fit into the
%                    buffer without requiring any pixels to be removed)
%                    compute the bpvec transform and return that instead.
%                    This may be faster in a loop
% bufsz, [sz]      - Set the buffer size to be 1/sz the size required to store
%                    the entire image. Legal values for this operation are 32, 16, 8,
%                    4,2 (default: 4). Setting a larger value here forces the encoding
%                    routine to be more aggressive at removing pixels in the target. 
%                    Note that the spatial resolution of the tracker will be reduced 
%                    by an amount equal to the factor specified here
% 
%
% OUTPUTS:
% spvec            - Sparse buffer vector.
% stat_struct      - Structure containing statistics for the encoding
%                    process
%
% When performing tracking simulations, the sparse vector option in
% csTracker should be set. Alternatively, the resulting spvec can be
% converted back to a backprojection image using buf_spDecode(), however
% this will not provide an accurate simulation of the FPGA process.
%

% Stefan Wong 2012

	%Set defaults
	fac    = 2;
	anchor = 'tl';
	thresh = 2;
	auto   = 0;

    TRIM = false;
    RTVEC = false;      %Return vector if num pixels is small enough

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				%Check which argument
				if(strncmpi(varargin{k}, 'factor', 6) || ...
                   strncmpi(varargin{k}, 'fac', 3))
					fac = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'anchor', 6))
					anchor = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'thresh', 6))
					thresh = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'auto', 4))
					auto = 1;
                elseif(strncmpi(varargin{k}, 'trim', 4))
                    TRIM = true;
                elseif(strncmpi(varargin{k}, 'rt', 2))
                    RTVEC = true;
                elseif(strncmpi(varargin{k}, 'eps', 3))
                    buf_eps   = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'buf', 3) || ...
                       strncmpi(varargin{k}, 'sz',  2))
					bufsz = varargin{k+1};
				end
			end
		end
	end

	SP_BUFSZ = [64 32 16 8 4 2 1];

	if(exist('bufsz', 'var'))
		valid_sz = find(SP_BUFSZ == bufsz, 1);
		if(isempty(valid_sz))
			fprintf('Invalid size %d, using default (4)\n', bufsz);
			SZ = 4;	%turns out (coincidentally) that the index for 4 is also 4
		else
            SZ = bufsz;
		end
	else
		SZ = 4;
	end
	%Genrate factors and thresholds for scaling test
    %SP_FACTORS = 2.^(length(SP_BUFSZ)-1:-1:0);

    %SP_THRESH  = 2.^(length(SP_BUFSZ):-1:0) ./ 2;
    %SP_THRESH  = (SP_BUFSZ(SZ:end).^2) ./ 2;
	%SP_THRESH  = 2.^(0:(length(SP_BUFSZ(SZ:end)) + 1));

	
    if(~exist('buf_eps', 'var'))
        buf_eps = 0;
    end
    %NOTE ON USING EPS
    % The point of the eps variable here is to allow some amount of leeway
    % in the window size that causes the vector to be sparse. For example,
    % it may be preferable to make the transition size slightly larger or
    % (more often) slightly smaller. By default
	[h w d] = size(bpimg); %#ok
	imsz    = h * w;
	%bpsum   = sum(sum(bpimg));

	if(TRIM)
		spvec = zeros(2, imsz);	%excess gets cut off anyway
	end

	% =============================================================================
	% AUTOMATICALLY DETERMINE PARAMETERS:
	% =============================================================================
	% The buffer sizes are sorted from left to right in descending order. We can think
	% of these values as being a scaling factor of 1/N (so for example, selecting 32 
	% is really selecting a buffer that is 1/32 the size of the image. Since the 
	% buffer size can be set from the csToolTrackOpts panel, we first find the index
	% of the buffer size, and then test the image size with increasingly larger buf
	% sizes (so 1/16, 1/8, etc...), until the image is larger than the buffer size.
	% We can then determine the factor to scale by observing how many elements to the
	% right we are from the sparse size, and reducing the image size by 2 to the power
	% of that amount.
	%
	% EXAMPLE SCALING
	% Say the buffer size is set at 32 (meaning that the total memory available is 
	% 1/32 of that required to store the entire image), and that the backprojection 
	% image contains more than 1/16 available pixels, but less than 1/8. 
	% We set the initial index to whatever the 1/32 position is, and work our way to 
	% the right-hand side of the BUFSZ array.
	%
	% (1st call) -> if(bpsum < imsz/BUFSZ(k))	%BUFSZ(k) = 32, test fails
	% (2nd call) -> if(bpsum < imsz/BUFSZ(k+1))	%BUFSZ(k+1) = 16, test fails
	% (3rd call) -> if(bpsum < imsz/BUFSZ(k+2)) %BUFSZ(k+2) = 8, test succeeds
	% 
	% Now we set the scaling factor to be 4, since we moved 2 places to the right in 
	% the BUFSZ array (2^2). This will rescale vector to fit in buffer. The larger the
	% target, the more aggresively the image needs to be rescaled. In software, the
	% more aggressive the scaling factor the long the encoding process will take. In 
	% hardware, I expect the amount of time to roughly the same 
	%3
	% Note that in actual practise, the FPGA needs to do the scaling automatically, so
	% while forcing a particular size may be useful for investigation, its the auto
	% scaling that needs to work in the chip to be useful.
	if(auto)
		sIdx = find(SP_BUFSZ == SZ);
		%value should be correct by this point, but check anyway
		if(isempty(sIdx))
			fprintf('ERROR: Invalid index %d, exiting...\n', sIdx);
			%Generate defaults
			spvec = [];
			if(nargout > 1)
				varargout{1} = [];
			end
			return;
		end
		factors              = 2.^(0:(length(SP_BUFSZ(sIdx:end-1))));
		thresholds           = 2.^(0:(length(SP_BUFSZ(sIdx:end-1)))) ./ 2;
		SP_FACTORS           = zeros(1, length(SP_BUFSZ));
		SP_THRESH            = zeros(1, length(SP_BUFSZ));
		SP_FACTORS(sIdx:end) = factors;
		SP_THRESH(sIdx:end)  = thresholds;
		%SP_FACTORS = 2.^(0:(length(SP_BUFSZ(sIdx:end-1))));
	    %SP_THRESH  = 2.^(0:(length(SP_BUFSZ(sIdx:end-1)))) ./ 2;

		for k = sIdx:length(SP_BUFSZ)
			if(bpsum < imsz/SP_BUFSZ(k) + buf_eps)
				%Vector fits into specified buffer
				%if(k == SZ)		%Already small enough to fit
				if(k == sIdx)
					if(RTVEC)	%Return original vector
						spvec = bpimg2vec(bpimg);
						if(nargout > 1)		%format some stats for sp_stat
							stat_struct.anchor   = 'tl';
							stat_struct.thresh   = 1;
							stat_struct.fac      = 1;
							stat_struct.bpsz     = length(spvec);
							stat_struct.imsz     = [h w];
							stat_struct.zerLog   = 0;
							stat_struct.numZeros = 0;
							varargout{1} = stat_struct;
						end
						return;
					end
					fac = 1;
					thresh = 1;
				else
					fac    = SP_FACTORS(k);
					thresh = SP_THRESH(k);
					break;
				end
			end
		end

		%If we get to here and haven't set any fac or thresh variables, 
		%something went wrong
		if(~exist('fac', 'var') || ~exist('thresh', 'var'))
			%Print appropriate message
			if(~exist('fac', 'var'))
				fprintf('ERROR: Unable to set fac in buf_spEncode()\n');
			end
			if(~exist('thresh', 'var'))
				fprintf('ERROR: Unable to set thresh in buf_spEncode()\n');
			end
			if(RTVEC)
				spvec = bpimg2vec(bpimg);
				if(nargout > 1)		%give back bpvec info
                    stat_struct.thresh   = 1;
                    stat_struct.fac      = 1;
                    stat_struct.bpsz     = length(spvec);
                    stat_struct.imsz     = [h w];
                    stat_struct.zerLog   = 0;
                    stat_struct.numZeros = 0;
                    varargout{1} = stat_struct;
				end
				return;
			end
			%if(nargout > 1)	%Give dummy info in spstat
			%	varargout{1} = [];
			%end
		end	
	end	
	
	k        = 1;		%vector index
    numZeros = 0;
    zeroLog  = zeros(1, length(spvec));
	% NOTE: Would it be worth moving the switch outside the loop? (Could test this in
	% profiler, although MATLAB may do some optimizations here anyway)
	%for x = 1:w/fac
	%	for y = 1:h/fac
    for x = 1:fac:w
        for y = 1:fac:h
            %Need to do bounds check here for block size
            if((x + fac - 1) > w)
                xrng = x:w;
            else
                xrng = x:x+fac-1;
            end
            if((y + fac - 1) > h)
                yrng = y:h;
            else
                yrng = y:y+fac-1;
            end
            blk = bpimg(yrng, xrng);
			%blk = bpimg(y:y+fac-1, x:x+fac-1);
			if(sum(sum(blk)) > thresh)
				switch anchor
					case 'tl'
						spvec(:,k) = [x ; y];
					case 'tr'
						spvec(:,k) = [x ; y+fac-1];
					case 'bl'
						spvec(:,k) = [x+fac-1 ; y];
					case 'br'
						spvec(:,k) = [x+fac-1 ; y+fac-1];
					case 'cent'
						%Find the 'mid-point' pixel. This will be biased one pixel up
						%and one pixel left since the 'mid-point' in this case is the
						%top left of the 2x2 block inside the main NxN block
						spvec(:,k) = [x+(fac/2)-1 ; y+(fac/2)-1];	
					otherwise
						error('Invalid anchor point %s', anchor);
				end
    			k = k + 1;
				if(k > length(spvec))
					fprintf('WARNING: k exceeded length of spvec (%d)\n', k);
					k = length(spvec);
				end
			end
        end
    end

    if(TRIM)
        [idy idx] = find(spvec == 0, 1, 'first');   %#ok
        spvec = spvec(:,1:idx-1);
    end
            
	%Place options into stat_struct 
	stat_struct.anchor   = anchor;
	stat_struct.thresh   = thresh;
	stat_struct.fac      = fac;
	stat_struct.bpsz     = length(spvec);
	stat_struct.imsz     = [h w];
    stat_struct.zeroLog  = zeroLog;
    stat_struct.numZeros = numZeros;
    
	if(nargout > 1)
		varargout{1}       = stat_struct;
	end
	


end		%buf_spEncode
