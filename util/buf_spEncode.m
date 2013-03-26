function [spvec varargout] = buf_spEncode(bpimg, varargin)
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
                    eps   = varargin{k+1};
				end
			end
		end
	end
	
    if(~exist('eps', 'var'))
        eps = 0;
    end
    %NOTE ON USING EPS
    % The point of the eps variable here is to allow some amount of leeway
    % in the window size that causes the vector to be sparse. For example,
    % it may be preferable to make the transition size slightly larger or
    % (more often) slightly smaller. By default
	[h w d] = size(bpimg);
	imsz    = h * w;
	bpsum   = sum(sum(bpimg));
	spvec   = zeros(2, imsz/4);
	if(auto)
		%try to determine parameters automatically	
		if(bpsum < (imsz/4) + eps)
            if(RTVEC)
                spvec = bpimg2vec(bpimg);
                if(nargout > 1)
                	stat_struct.anchor   = 'tl';
                    stat_struct.thresh   = 1;
                    stat_struct.fac      = 1;
                    stat_struct.bpsz     = length(spvec);
                    stat_struct.imsz     = [h w];
                    stat_struct.zeroLog  = 0;
                    stat_struct.numZeros = 0;
                    varargout{1}         = stat_struct;
                end
                return;
            else
            	fac    = 1;
                thresh = 1;
            end
		elseif(bpsum < (imsz/2) + eps)
			fac    = 2;
			thresh = 2;
		else
			fac    = 4;
			thresh = 8;
		end
		anchor = 'tl';
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
			blk = bpimg(y:y+fac-1, x:x+fac-1);
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
