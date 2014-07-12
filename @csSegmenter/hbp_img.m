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
% img   - Matrix containing hue pixels
% mhist - Model histogram
%
% If the option GEN_BP_VEC is set in the csSegmenter object, bpdata will be returned
% as a 2xN matrix of backprojected data points. Otherwise bpdata will be a HxW matrix
% of binary values, where H and W are the height and width of a the input image

% Stefan Wong 2012

	%Kernel range function
	kbandw = @(x,y,bw) (x < bw) & (y < bw);

	% NOTE : Need to call d as part of varargout otherwise second arg
	% takes the value of (img_w * d)
	[img_h img_w d] = size(img); %#ok
    imhist          = zeros(1,T.N_BINS);
	bins    = T.N_BINS .* (1:T.N_BINS);
	mhist   = hist_norm(mhist, img_w * img_h); 
    mhist(mhist < T.mhistThresh) = 0;
    %mthresh = fix(T.mhistThresh * BLK_SZ*BLK_SZ);
    %mhist(mhist < mthresh) = 0;

	% Histogram computation
	for x = 1:img_w
		for y = 1:img_h
			%Save some time by discarding 0 values, since 0 undefined in HSV space
			if(img(y,x) ~= 0)
				idx         = find(bins > img(y,x), 1, 'first');
				imhist(idx) = imhist(idx) + 1; 
			end
		end
	end

	%NOTE: This should be upgraded in the future to handle multi-bit segmentation
	%if(T.FPGA_MODE)
	%	rhist = rhist .* T.DATA_SZ;
	%end
	
	%Compute ratio histogram and backprojection
	rhist = mhist ./ imhist;
	%clean up garbage values
	rhist(isnan(rhist)) = 0;
    rhist(isinf(rhist)) = 0;
    rhist = rhist ./ (max(max(rhist))); %TODO : DO this last
	
	bpimg = hbp(T, img, rhist);

	if(T.FPGA_MODE)
		bpimg = bpimg ./ (max(max(bpimg))); 	%range - [0 1]
		bpimg = fix(bpimg .* T.kQuant);			%range - [0 kQuant]
	end
	bpdata = bpimg2vec(bpimg, 'bpval');
	
	%if(T.FPGA_MODE)
	%	bpdata = bpimg2vec(bpimg);	
	%else
	%	bpdata = bpimg2vec(bpimg, 'bpval');
	%end

end 		%hbp_img()
