function vec = genHueVec(fh, opts)
% GENHUEVEC
% Generate test vector of hue channel data from file referred to in fh. This method
% reads the image file specified by fh.filename, performs a HSV color space transform
% quantises the hue channel to the specified precision (default: 8-bit) and creates a
% test vector based on the formatting argument in the opts structure

% Stefan Wong 2012

	%For now, hardcode DATA_SZ at default of 256
	DATA_SZ = 256;

	type = opts.type;
	val  = opts.val;

	%Get image data
	%img     = imread(get(fh, 'filename'));
	hsv_img = rgb2hsv(imread(get(fh, 'filename')));
	hue_img = hsv_img(:,:,1).*DATA_SZ;
	[h w d] = size(hue_img);

	switch(type)
		case 'row'
			rdim = w/val;
			vec  = cell(h, rdim);
			for y = 1:h
				for x = 1:rdim
					vec{y,x} = hue_img(y, x:x+val);
				end
			end
		case 'col'
			cdim = h/val;
			vec  = cell(cdim, w);
			for y = 1:w	
				for x = 1:cdim
					vec{y,x} = data(y:y+val, x);
				end
			end
		case 'scalar'
			%unroll data
			vec = zeros(1, h*w);
			k   = 1;
			for x = 1:w
				for y = 1:h
					vec(k) = hue_img(y,x);
					k = k + 1;
				end
			end
		otherwise
			%probably never get here, but just in case
			error('Invalid direction (HOW?!?!)');
	end



end 	%genHueVec()
