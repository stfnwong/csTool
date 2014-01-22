function [vec] = injectOffset(V, imVec, offset, imsz)
% INJECTOFFSET
% Inject an offset error into the image data in imVec
%
% ARGUMENTS
% V      - vecManager object
% imVec  - Matrix of image data. This should be a 2xN or 3xN backprojection
%          vector
% offset - Amount to offset by. This should be a 2 element vector where 
%          the first element is the x offset and the second element the y
%          offset.
% imsz   - Dimensions of the output image. 
%

% Stefan Wong 2014

	vec        = zeros(size(imVec));
	vec(1,:)   = imVec(1,:) + offset(1);
	vec(2,:)   = imVec(2,:) + offset(2);
	% Clip to limits
	vxidx      = (vec(1,:) > imsz(1));
	vyidx      = (vec(2,:) > imsz(2));
	vec(vxidx) = imsz(1);
	vec(vyidx) = imsz(2);

end 	%injectOffset
