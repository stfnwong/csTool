function bpimg = vec2bpimg(vec, varargin)
% VEC2BPIMG
%
% Convert vector representation of backprojection into a backprojection image. If no
% size is specified, the backprojection image is made only large enought to encompass
% the further spread pixel locations in the vector vec. Pass in a 2 element row vector
% in the form [w h] to specify the width and height of the output image

	%error(nargchk(1,3,nargin, 'struct'));
	%if(nargin > 1)
	%	dim = varargin{1};
	%	%sz  = size(dim);
	%	if(~isvector(dim))
	%		error('Dim must be 1x2 vector of [w h]');
	%	end
	%end

	DISP_WAITBAR = false;
	FORCE_CHECK  = false;

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'dims', 4))
					dim = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'wait', 4) || ...
                       strncmpi(varargin{k}, 'wb', 2))
					DISP_WAITBAR = true;
				elseif(strncmpi(varargin{k}, 'force', 5))
					%Use this for sparse vectors that haven't had redundant zero
					%elements trimmed out
					FORCE_CHECK  = true;
				en
			end
		end
	end

	if(exist('dim','var'))
		bpimg = zeros(dim(2), dim(1));
	else
		if(numel(vec) == 0)
			fprintf('ERROR: argument vec contains no elements\n');
			bpimg = [];
			return;
		end
		%figure out the max and min span of the vec data
		xmax  = range(vec(1,:));
		ymax  = range(vec(2,:));
		bpimg = zeros(ymax, xmax);
	end

	vsz = size(vec);
	if(vsz(1) == 3)
		for k = 1:length(vec)
			bpimg(vec(2,k), vec(1,k)) = vec(3,k);
		end
	elseif(vsz(1) == 2)
		N = length(vec);
		if(DISP_WAITBAR)
			wb = waitbar(0, 'Formatting bpimg', 'Name', 'Creating bpimg');
		end
		for k = 1:N
			if(FORCE_CHECK)
				%Ignore zero elements
				if(vec(1,k) ~= 0 && vec(2,k) ~= 0)
					bpimg(vec(2,k), vec(1,k)) = 1;
				end
			else
				bpimg(vec(2,k), vec(1,k)) = 1;
			end
			if(DISP_WAITBAR)
				waitbar(k/N, wb, sprintf('Creating bpimg (element %d/%d)\n', k, N));
			end
		end
		if(DISP_WAITBAR)
			delete(wb);
		end
	else
		error('Input vec illegal size (must be 2xN or 3xN)');
	end


end 	%vec2bpimg()
