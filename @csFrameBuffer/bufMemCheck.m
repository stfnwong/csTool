function status = bufMemCheck(nFrames, path, varargin)
% BUFMEMCHECK
%
% Estimate size of frame buffer object

% Stefan Wong 2012

	%Check arguments
	if(~ischar(path))
		error('Path must be string');
	end
	if(nargin > 2)
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'ext', 3))
					ext = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'max', 3))
					max = varargin{k+1};
				end
			end
		end
	end
	%Fill in gaps for un-allocated variables
	if(~exist('ext', 'var'))
		ext = 'tif';
	end
	if(~exist('max', 'var'))
		max = 10 ^ 8;
	end
	
	img = imread(path, ext);
	[img_w img_h d] = size(img);
	memEst = img_w * img_h * d * 8 * nFrames;
	fprintf('Memory estimate : %d bytes\n', memEst / 8);
	if(memEst >= max)
		status = 1;
		return;
	else
		status = 0;
		return;
	end
end 