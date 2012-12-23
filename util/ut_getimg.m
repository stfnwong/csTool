function [img hsvimg hueimg] = ut_getimg(fn, varargin)
% UT_GETIMG
%
% [img hsvimg hueimg] = ut_getimg(fn)
%
% Load the image with filename fn and automatically generate hsv and hue
% images
%

% Stefan Wong 2012

	ext = 'tif';
	%Check optional arguments
	if(nargin > 1)
		if(strncmpi(varargin{1}, 'ext', 3))
			ext = varargin{2};
		end
	end
	
	img    = imread(fn, ext);
	hsvimg = rgb2hsv(img);
	hueimg = 256.*hsvimg(:,:,1);
	
end		%ut_getimg()