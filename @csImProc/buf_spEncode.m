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

	if(nargin > 1)
		for k = 1:length(varagin)
			if(ischar(varargin{k}))
				%Check which argument
				if(strnmcpi(varargin{k}, 'factor', 6))
					fac = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'anchor', 6))
					anchor = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'thresh', 6))
					thresh = varargin{k+1};
				elseif(strnmcpi(varargin{k}, 'auto', 4))
					auto = 1;
				end
			end
		end
	end
	eps     = 0;	%adjustment factor
	[h w d] = size(bpimg);
	imsz    = h * w;
	bpsum   = sum(sum(bpimg));
	spvec   = zeros(2, imsz/4);
	if(auto)
		%try to determine parameters automatically	
		if(bpsum < (imsz/4) + eps)
			fac    = 1;
			thresh = 1;
		elseif(bpsum < (imsz/2) + eps)
			fac    = 2;
			thresh = 2;
		else
			fac    = 4;
			thresh = 8;
		end
		anchor = 'tl';
	end
	
	k = 1;		%vector index
	% NOTE: Would it be worth moving the switch outside the loop? (Could test this in
	% profiler, although MATLAB may do some optimizations here anyway)
	for x = 1:w/fac
		for y = 1:h/fac
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
				k = k+1;
				if(k > length(spvec))
					fprintf('WARNING: k exceeded length of spvec (%d)\n', k);
					k = length(spvec);
				end
			end
		end
	end
	%Place options into stat_struct 
	stat_struct.anchor = anchor;
	stat_struct.thresh = thresh;
	stat_struct.fac    = fac;
	stat_struct.bpsz   = length(spvec);
	stat_struct.imsz   = [h w];
	varargout{1}       = stat_struct;
	


end		%buf_spEncode
