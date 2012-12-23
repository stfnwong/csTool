function bpimg = vec2bpimg(vec, varargin)
% VEC2BPIMG
%
% Convert vector representation of backprojection into a backprojection image. If no
% size is specified, the backprojection image is made only large enought to encompass
% the further spread pixel locations in the vector vec. Pass in a 2 element row vector
% in the form [w h] to specify the width and height of the output image

	error(nargchk(1,3,nargin, 'struct'));
	if(nargin > 1)
		dim = varargin{1};
		sz  = size(dim)
		if(sz(1) ~= 1 || sz(2) ~= 2)
			error('Dim must be 1x2 vector of [w h]');
		end
	end

	if(exist('dim','var'))
		bpimg = zeros(dim(2), dim(1));
	else
		%figure out the max and min span of the vec data
		xmax  = range(idx);
		ymax  = range(idy);
		bpimg = zeros(ymax, xmax);
	end

	vsz = size(vec);
	if(vsz(1) == 3)
		for k = 1:length(vec)
			bpimg(vec(2,k), vec(1,k)) = vec(3,k);
		end
	elseif(vsz(1) == 2)
		for k = 1:length(vec)
			bpimg(vec(2,k), vec(1,k)) = 1;
		end
	else
		error('Input vec illegal size (must be 2xN or 3xN)');
	end


end 	%vec2bpimg()
