function [spvec rhist] = hbp_img_sp(T, img, mhist, varargin)
% HBP_IMG_SP
% [spvec rhist] = hbp_img_sp(T, img, mhist)
% [spvec rhist] = hbp_img_sp(T, img, mhist, [..OPTIONS..])
%
% Peform histogram backprojection over image and generate sparse vector output. 
%
% ARGUMENTS
% T     - csSegmenter object
% img   - Matrix containing image pixels
% mhist - Model histogram of target
% [OPTIONAL ARGUMENTS]
%

% Stefan Wong 2013

	%Parse optional parameters (if any)
	if(~isempty(varargin))
		fprintf('Optional parameters not yet implemented\n');
	end

	[img_h img_w d] = size(img);
end
	
