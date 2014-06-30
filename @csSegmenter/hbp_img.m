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

	KDENS = false;
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'kdens', 5))
					xy_prev = varargin{k+1};
					KDENS   = true;
				elseif(strncmpi(varargin{k}, 'bw', 2))
					kbw     = varargin{k+1};		%kernel bandwidth
				end
			end
		end
	end

	[img_h img_w d] = size(img);
    imhist          = zeros(1,T.N_BINS);
	%if(T.FPGA_MODE)
	%	bins = (T.DATA_SZ/T.N_BINS) .* (1:T.N_BINS);
	%else
	%	bins = T.DATA_SZ .* (1:T.N_BINS);
	%end
	bins  = T.N_BINS .* (1:T.N_BINS);
	mhist = hist_norm(mhist, img_w * img_h); 

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
	% TODO: MEX this?
	
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
