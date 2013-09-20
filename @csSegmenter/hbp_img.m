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

	%Kernel range function
	kbandw = @(x,y,bw) (x < bw) & (y < bw);

	KDENS = false;
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'kdens', 5))
					xy_prev = vararginn{k+1};
					KDENS   = true;
				elseif(strncmpi(varargin{k}, 'bw', 2))
					kbw     = varargin{k+1};		%kernel bandwidth
				end
			end
		end
	end

	% If no bandwidth specified, use this default value
	if(KDENS && ~exist('kbw', 'var'))
		kbw = T.KERNEL_BW;
	end
	if(exist('xy_prev', 'var'))
		if(~isnumeric(xvy_prev))
			fprintf('ERROR: Incorrect type for xy_prev, ignoring kernel weighting\n');
			KDENS = false;
		end
	end

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
				% Perform kernel weighting?
				if(KDENS)
					pixel  = [x y];
					kw = kernelLookup(T, pixel);
					%kw = kbw_lut(pixel, T.XY_PREV, 'quant', T.BPIMG_BIT_DEPTH, 'scale', log2(T.BPIMG_BIT_DEPTH));
			 		if(kw > 0)
						idx = find(bins > img(y,x), 1, 'first');
						bpimg(y,x) = kw * rhist(idx);
					end		
				else
					idx        = find(bins > img(y,x), 1, 'first');
					if(rhist(idx) > T.BP_THRESH)
						bpimg(y,x) = rhist(idx);
					end
				end
			end
		end
	end

	if(T.FPGA_MODE)
		bpimg = bpimg ./ (max(max(bpimg))); 	%range - [0 1]
		bpimg = fix(bpimg .* T.BPIMG_BIT_DEPTH);
	end
	bpdata = bpimg2vec(bpimg, 'bpval');
	
	%if(T.FPGA_MODE)
	%	bpdata = bpimg2vec(bpimg);	
	%else
	%	bpdata = bpimg2vec(bpimg, 'bpval');
	%end

end 		%hbp_img()
