function vec = genRGBVec(V, fh, opts)
% GENRGBVEC
% Generate RGB image vector (as a raster) from image reffered to by fh. This method
% reads the image file referred to by fh.filename and creates a test vector consisting
% of a raster pattern stream of RED, GREEN, and BLUE values for each pixel.
%

% Stefan Wong 2012

	%DATA_SZ fixed for now - this could be made a settable property in future
	DATA_SZ = 256;

	img = imread(get(fh, 'filename'));
	if(range(range(img)) <= 1.0)
		img = img .* DATA_SZ;
	end

	[h w d] = size(img);
	red     = zeros(1, h*w);
	grn     = zeros(1, h*w);
	blu     = zeros(1, h*w);
	vec     = cell(3, 1);
	%Unroll image and place each channel value in seperate cell compart
	k = 1;
	for x = 1:w
		for y = 1:h
			red(k) = img(y,x,1);
			grn(k) = img(y,x,2);
			blu(k) = img(y,x,3);
		end
	end
	vec{1,1} = red;
	vec{2,1) = grn;
	vec{3,1} = blu;

end 	%genRGBVec
