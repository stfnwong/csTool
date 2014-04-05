function [vec varargout] = bpimg2vec(bpimg, varargin)
% BPIMG2VEC
% vec = bpimg2vec(bpimg, [..OPTIONS..])
% Convert back projection image into 2 dimensional vector whose columns are the 
% coordinates of data points in the image. In effect, this function is a poor man's 
% sparse(img) for use in csTool
%
% ARGUMENTS 
% bpimg - Backprojection image to generate vector from
% (OPTIONAL ARGUMENTS)
% 'idxonly'  - Only save the pixel positions (Default)
% 'bpval'    - Save a third row with the backprojection weight 
% 'thresh'   - Discard pixels that fall below this value (default: 0)
%

% Stefan Wong 2012

	%error(nargchk(1,2,nargin, 'struct'));
	%if(nargin > 1)
	%	thresh = varargin{1};
	%end
	
	idxonly = true;
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'idxonly', 7))
					idxonly = true;
				elseif(strncmpi(varargin{k}, 'bpval', 5))
					idxonly = false;
				elseif(strncmpi(varargin{k}, 'thresh', 6))
					thresh = varargin{k+1};
				end
			end
		end
	end

	%Find non-zero elements of bpimg
	if(exist('thresh', 'var'))
		[idy idx] = find(bpimg > thresh);
	else
		[idy idx] = find(bpimg > 0);
	end

	if(idxonly)
		vec      = zeros(2, length(idy));
		vec(1,:) = idx';
		vec(2,:) = idy';
	else
		vec      = zeros(3, length(idy));
		vec(1,:) = idx';
		vec(2,:) = idy';
		%TODO: Vector this loop
		%vec(3,k) = bpimg(idy, idx);
		for k = 1:length(idy)
			vec(3,k) = bpimg(idy(k), idx(k));
		end
	end

	if(nargout > 1)
		bpsum = sum(sum(bpimg));
		varargout{1} = bpsum;
	end
	
end 	%bpimg2vec()
