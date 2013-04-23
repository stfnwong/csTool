function [bpdata rhist] = hbp_img(T, img, mhist, varargin)
% HBP_IMG
%
% [bpdata rhist] = hbp_img(T, img, mhist);
%
% Perform un-windowed histogram backprojection on image img using model histogram
% mhist.
%
% ARGUMENTS:
%
% T     - csSegmented object
% img   - Matrix containing image pixels
% mhist - Model histogram
%
% If the option GEN_BP_VEC is set in the csSegmenter object, bpdata will be returned
% as a 2xN matrix of backprojected data points. Otherwise bpdata will be a HxW matrix
% of binary values, where H and W are the height and width of a the input image

% Stefan Wong 2012

	%Get image parameters and set up histogram bins
	[img_h img_w d] = size(img);
	if(T.FPGA_MODE)
		bpimg       = zeros(img_h, img_w, 'uint8');
	else
		bpimg       = zeros(img_h, img_w);
	end
    imhist          = zeros(1,T.N_BINS);
	%if(T.FPGA_MODE)
	%	bins = (T.DATA_SZ/T.N_BINS) .* (1:T.N_BINS);
	%else
	%	bins = T.DATA_SZ .* (1:T.N_BINS);
	%end
	bins = T.N_BINS .* (1:T.N_BINS);

	for x = 1:img_w
		for y = 1:img_h
			%Save some time by discarding 0 values, since 0 undefined in HSV space
			if(img(y,x) ~= 0)
				idx         = find(bins > img(y,x), 1, 'first');
				imhist(idx) = imhist(idx) + 1; 
			end
		end
	end
	%Compute ratio histogram and backprojection
	rhist = mhist ./ imhist;
	rhist = rhist ./ (max(max(rhist)));
	%NOTE: This should be upgraded in the future to handle multi-bit segmentation
	if(T.FPGA_MODE)
		rhist = rhist .* T.DATA_SZ;
	end
	%clean up garbage values
	rhist(isnan(rhist)) = 0;
	if(T.FPGA_MODE)
		rhist(isinf(rhist)) = T.DATA_SZ;
	else
		rhist(isinf(rhist)) = 1;
	end
	% TODO: MEX this?
	for x = 1:img_w
		for y = 1:img_h
			%Reference against original pixel to get rid of zeros
			if(img(y,x) ~= 0)
				idx        = find(bins > img(y,x), 1, 'first');
				bpimg(y,x) = rhist(idx);
			end
		end
	end
	bpdata = bpimg2vec(bpimg);	

end 		%hbp_img()
