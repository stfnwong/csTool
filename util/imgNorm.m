function nImg = imgNorm(img)
% IMGNORM
% Nofmalise Image to rnage [0 1]

% Stefan Wong 2014

	nImg = img./max(max(img));

end  	%imgNorm
