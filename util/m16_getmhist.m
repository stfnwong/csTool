%% m16_getmhist
%
% Generate model histogram from region on image
%
% [mhist] = m16_getmhist(img, region, ... ,'debug', 'norm', 'size', SIZE);
% 
% Image should be passed in as single hue channel 
% Region should be specified as a 2x2 matrix with the boundaries arranged as follows:
% 
% Pass in the optional string 'size' followed by and integer to change the data size
% (Default, 256)
%
% Pass in the optional string 'norm' to normalise the histogram to [0 DATA_SZ].
%
% [xmin xmax]
% [ymin ymax]
%
% Stefan Wong 2012

function [mhist] = m16_getmhist(img, region, varargin)

%Internal constants
MAX_ARG     = 5;
PRINT_DEBUG = 1;
DBG_STR     = 'DEBUG (m16_getmhist) :';
DATA_SZ     = 256;
NORM_MHIST  = 0;

	sz = size(region)
	if(sz(1) ~= 2 | sz(2) ~= 2)
		error('region must be 2x2 matrix');
	end

	%Parse optional arguments
	if(nargin > 2)
		%Got some optional arguments
		for k = 1:nargin-2;
			if(ischar(varargin{k}))
				%Normalise ratio histogram
				if(strncmpi(varargin{k}, 'norm', 4))
					NORM_MHIST = 1;
					fprintf('%s Normalising ratio histogram\n', DBG_STR);
				end
				%Change data size
				if(strncmpi(varargin{k}, 'size', 4))
					if(~isnumeric(varargin{k+1}))
						error('New size must be numeric (integer)');
					else
						DATA_SZ = varargin{k+1};
						fprintf('Data size changed to %d\n', DATA_SZ);
					end
				end
			end
		end
	end

	xmin = region(1,1);
	xmax = region(1,2);
	ymin = region(2,1);
	ymax = region(2,2);

	%Allocate memory for histograms
	N_BINS     = 16;
	bins       = N_BINS.*(1:N_BINS);
	mhist      = zeros(1,N_BINS);

	for j = ymin : ymax;
		for i = xmin : xmax;
			idx = find(bins > img(j,i), 1, 'first');
			mhist(idx) = mhist(idx) + 1;
			%k = 1;
			%while(k <= length(bins))
			%	if(img(j,i) <= bins(k))
			%		mhist(k) = mhist(k) + 1;
			%		k = length(bins) + 1;
			%	else
			%		k = k + 1;
			%	end
			%end
		end
	end

	if(NORM_MHIST)
		mhist = mhist./max(max(mhist));
		mhist = fix(DATA_SZ.*mhist);
	end
			
	

end 	%function
