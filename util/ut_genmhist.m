function [mhist varargout] = ut_genmhist(img, varargin)
% GENMHIST
%
% mhist = ut_genmhist(img, ... 'region', region/ 'default')
% [mhist region] = ut_genmhist(img, 'default')
%
% Generate model histogram for testing. If the string 'region' is passed in, the 
% following argument is taken as a region matrix of the form 
%
%			[xmin xmax ; ymin ymax]
%
% If the string 'default' is passed in, the default region is used, which is taken to
% be a square whose origin is the centre of the image, and whose span is 20% of the
% image span on each dimension respectively (ie: the height is h/5, and width is w/5)
% This routine performs a naive histogram lookup, and is intended primarily for unit
% testing features within csTool. It is not reccomended for production use
%
% 

% Stefan Wong 2012

	USE_DEFAULT = 1;
	N_BINS      = 16;
	%Check optional arguments
	if(nargin > 1)
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'default', 7))
					USE_DEFAULT = 1;
				elseif(strncmpi(varargin{k}, 'region', 6))
					USE_DEFAULT = 0;
					region = varargin{k+1};
				end
			end
		end
	end

	%get image dimensions 
	[h w d] = size(img);

	if(USE_DEFAULT)
		%Get default region
		xc   = w/2;
		yc   = h/2;
		xmin = fix(xc - w/6);
		xmax = fix(xc + w/6);
		ymin = fix(yc - h/6);
		ymax = fix(yc + h/6);
	else
		%do quick sanity checl
		if(~exist('region', 'var'))
			error('Not using default but region var not in scope!');
		end
		xmax = region(1,1);
		xmin = region(1,2);
		ymin = region(2,1);
		ymax = region(2,2);
	end

	mhist = zeros(1,N_BINS, 'uint8');
	bins  = N_BINS.*(0:N_BINS-1);
	for x = xmin:xmax
		for y = ymin:ymax
			%Accumulate model histogram
			v = img(y,x);
			k = 1;
			while(k < length(bins))
				if(v < bins(k))
					mhist(k) = mhist(k) + 1;
					k = length(bins) + 1;
				else
					k = k + 1;
				end
			end
		end
	end	
	%Generate region if requested
	if(USE_DEFAULT)
		varargout{1} = [xmin xmax ; ymin ymax];
	end


end 	%ut_gemhist()
