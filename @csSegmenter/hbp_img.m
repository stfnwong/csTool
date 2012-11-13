function [bpimg rhist] = hbp_img(T, img, mhist)
% HBP_IMG
%
% [bpimg rhist] = hbp_img(T, img, mhist);
%
% Perform un-windowed histogram backprojection on image img using model histogram
% mhist.
%
% ARGUMENTS:
%
% T     - csSegmented object
% img   - Matrix containing image pixels
% mhist - Model histogram

% Stefan Wong 2012

	%Get image parameters and set up histogram bins
	[img_h img_w d] = size(img);
	bpimg           = zeros(img_h, img_w);
	imhist          = zeros(1,T.N_BINS, 'uint8');
	if(T.FPGA_MODE)
		bins = (T.DATA_SZ/T.N_BINS) .* (1:T.N_BINS);
	else
		bins = T.DATA_SZ .* (1:T.N_BINS);
	end

	for x = 1:img_w
		for y = 1:img_h
			idx         = find(bins > img(y,x), 1, 'first');
			imhist(idx) = imhist(idx) + 1; 
		end
	end
	%Compute ratio histogram and backprojection
	rhist = mhist ./ imhist;
	rhist = rhist ./ (max(max(rhist)));
	rhist = rhist .* T.DATA_SZ;
	%clean up garbage values
	rhist(isnan(rhist)) = 0;
	rhist(isinf(rhist)) = 1;
	for x = 1:img_w
		for y = 1:img_h
			idx        = find(bins > img(y,x), 1, 'first');
			bpimg(y,x) = rhist(idx);
		end
	end

end 		%hbp_img()
