function bpimg = vec2bpimg(vec, varargin)
% VEC2BPIMG
% bpimg = vec2bpimg(vec, [...OPTIONS...])
%
% Convert vector representation of backprojection into a backprojection image. If no
% size is specified, the backprojection image is made only large enought to encompass
% the further spread pixel locations in the vector vec. Pass in a 2 element row vector
% in the form [w h] to specify the width and height of the output image
% 
% OUTPUTS:
% bpimg       - Recovered backprojection image. If no dims parameter is specified, 
% vec2bpimg attempts to guess the size of the original image by examining the extreme
% values in the vector, and reconstructing the image to fit those. 
%
% ARGUMENTS:
% vec         - Backprojection vector to re-assemble
% (OPTIONAL ARUGMENTS)
% dims, [w h] - True image dimensions. Supplying these will cause vec2bpimg to produce
%               the strictly correct output image;
% wait/wb     - Display a waitbar during processing.
% force       - Force the routine to check for zero values during reconstruction. This
%               option is useful when a sparse vector has not been created with the 
%               'trim' flag, and may have trailing zeros. Trim (in buf_spEncode) 
%               requires a call to find(), and may be slower in a loop.

	DISP_WAITBAR = false;
	FORCE_CHECK  = false;
	DEBUG        = false;

	error(nargchk(1,5,nargin, 'struct'));

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
				elseif(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = true;
				end
			end
		end
	end

	if(exist('dim','var'))
		bpimg = zeros(dim(2), dim(1));
		if(DEBUG)
			fprintf('DEBUG: vec2bpimg got dims %d x %d\n', dims(2), dims(1));
		end
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
