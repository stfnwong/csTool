function vec = bpimg2vec(bpimg, varargin)
% BPIMG2VEC
%
% Convert back projection image into 2 dimensional vector whose columns are the 
% coordinates of data points in the image. In effect, this function is a poor man's 
% sparse(img) for use in csTool
%

% Stefan Wong 2012

	error(nargchk(1,2,nargin, 'struct'));
	if(nargin > 1)
		thresh = varargin{1};
	end

	%Find non-zero elements of bpimg
	if(nargin > 1)
		[idy idx] = find(bpimg > thresh);
	else
		[idy idx] = find(bpimg > 0);
	end

	if(nargin > 1)
		vec      = zeros(3, length(idy));
		vec(1,:) = idx';
		vec(2,:) = idy';
		%TODO: Vector this loop
		for k = 1:length(idy)
			vec(3,k) = bpimg(idy(k), idx(k));
		end
	else
		vec      = zeros(2, length(idy));
		vec(1,:) = idx';
		vec(2,:) = idy';
	end
	
end 	%img2vec()
