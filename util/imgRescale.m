function scImg = imgRescale(img, scale)
% IMGRESCALE
% scImg = imgRescale(img, scale)
%
% Rescale the image img to have data points in the range [0 scale]
%

% Stefan Wong 2013

	imgMax   = range(range(img));
	imgUnity = img./imgMax; 
	scImg    = scale .* imgUnity;

end 	%imgRescale()
