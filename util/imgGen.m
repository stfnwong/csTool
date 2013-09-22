function img = imgGen(varargin)
% IMGGEN
% Generate test images.
%

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'dims', 4))
					dims   = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'max', 3))
					maxVal = varargin{k+1};
				end
			end
		end
	end

	% Check what we have
	if(~exist('dims', 'var'))
		dims = [256 256];
	end
	if(~exist('maxVal', 'var'))
		maxVal = 256;
	end

	img = zeros(dims(2), dims(1));

	for y = 1:dims(2)
		img(y,:) = 1:(maxVal/dims(1)):maxVal;
	end


end 	%imgGen()
