function vec = genRGBVec(V, img, vtype, val, varargin)
% GENRGBVEC
% Generate RGB image vector (as a raster) from image img. 
%

% Stefan Wong 2012

% TODO : Incorporate row and column orientation into this function

	if(~isempty(varargin))
		DATA_SZ = varargin{1};
	else
		DATA_SZ = 256;
	end

	if(range(range(img)) <= 1.0)
		img = img .* DATA_SZ;
	end

	[h w d] = size(img); %#ok
	red     = zeros(1, h*w);
	grn     = zeros(1, h*w);
	blu     = zeros(1, h*w);
	vec     = cell(3, 1);
	%Unroll image and place each channel value in seperate cell compart
	k = 1;
	t = w * h;
	wb = waitbar(0, sprintf('Generating RGB Vector (0/%d)', t), ...
                    'Name', 'Generating RGB Vector'));
	for x = 1:w
		for y = 1:h
			red(k) = img(y,x,1);
			grn(k) = img(y,x,2);
			blu(k) = img(y,x,3);
			k = k + 1;
			waitbar(k/t, wb, sprintf('Generating RGB Vector (%d/%d)', k, t));
		end
	end
	delete(wb);
	vec{1,1} = red;
	vec{2,1} = grn;
	vec{3,1} = blu;

end 	%genRGBVec
