function vec = genHSVVec(fh, varargin)
% GENHSVVEC
% vec = genHSVVec(fh, [..OPTIONS..])
% Generate HSV vector for use with Verilog testbench
%
% This function generates an HSV vector for use with CSoC Verilog testbences. Since 
% the pixels in the CSoC system are presented in raster format, there is no need for
% this function to generate vectors of various orientations. To produce row or column
% vectors for testing the segmentation pipeline, use the genHueVec() function instead.
%
% ARGUMENTS:
% fh - Frame handle to generate HSV data from
% (OPTIONAL ARGUMENTS)
% 'scale', scale - Pass the string 'scale' followed by a factor to scale the data by.
%                  By default, the hue data in MATLAB/Octave is a double in the range
%                  0 to 1, with 0 representing 0 degrees, and 1 representing 360 
%                  degrees
%
% OUTPUTS:
% vec - HSV Vector for use with vecDiskWrite()
%

% Stefan Wong 2013

	%Parse optional arguments
	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'scale', 5))
			scale = varargin{2};
		end
	end

	if(exist('scale', 'var'))
		SFAC = scale;
	else
		SFAC = 256;
	end

	hsv_img = rgb2hsv(imread(get(fh, 'filename'), 'TIFF'));
	[h w d] = size(hsv_img);
	if(d > 3)
		hsv_img = hsv_img{:,:,1:3);
	end

	hue = zeros(1, h*w);
	sat = zeros(1, h*w);
	val = zeros(1, h*w);
	k   = 1;
	t   = h*w;
	wb = waitbar(0, sprintf('Generating HSV vector (0/%d)', t), ...
                    'Name', 'Generating HSV Vector');
	for y = 1:h
		for x =1:w
			hue(k) = SFAC * hsv_img(y,x,1);
			sat(k) = hsv_img(y,x,2);
			val(k) = hsv_img(y,x,3);
			k = k + 1;
			waitbar(k/t, wb, sprintf('Generating HSV Vector (%d/%d)', k, t));
		end
	end
	delete(wb);
	vec{1,1} = hue;
	vec{2,1} = sat;
	vec{3,1} = val;	


end 	%genHSVVec() 
