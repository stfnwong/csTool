function [bpimg rhist] = hbp_block(T, img, mhist);
% HBP_BLOCK
%
% [bpimg rhist] = hbp_block(T, img, mhist);
%
% Perform block-wise histogram backprojeciton on img using model histogram specified
% in mhist. 
% ARGUMENTS:
% 
% T     - csSegmenter object
% img   - Matrix containing image data. This is assumed to be a grayscale hue image
% mhist - Model histogram 
%

% TODO: Clean up documentation

% Stefan Wong 2012

	%Create function handle to do block compares inside loop
	bcomp = @(rl, rh, blk) (blk > rl) & (blk < rh);

	%Get image paramters
	[img_h img_w d] = size(img);
	bpimg           = zeros(img_h, img_w);
	if(T.FPGA_MODE)
		bins = (T.DATA_SZ/T.N_BINS) .* (1:T.N_BINS);
	else
		bins = T.DATA_SZ .* (1:T.N_BINS);
	end
	%Create block memory
	BLK_SZ   = T.BLK_SZ;
	BLOCKS_X = fix(img_w/T.BLK_SZ);
	BLOCKS_Y = fix(img_h/T.BLK_SZ);

	% Save rhist blocks, compute an 'average' rhist at the end
	rhistBlk = cell(BLOCKS_X, BLOCKS_Y);

	for y = 0 : BLOCKS_Y - 1
		for x = 0 : BLOCKS_X - 1
			imhist = zeros(1, T.N_BINS);
			x_pix  = (x*BLK_SZ)+1 : (x+1)*BLK_SZ;
			y_pix  = (y*BLK_SZ)+1 : (y+1)*BLK_SZ;
			iblk   = img(y_pix, x_pix);
			for k = 1:length(bins)
				if(k == 1)
					pix      = bcomp(0, bins(k), iblk);
					ihist(k) = sum(sum(pix));
				else
					pix      = bcomp(bins(k-1), bins(k), iblk);
					ihist(k) = sum(sum(pix));
				end
			end
			rhist = mhist ./ ihist;
			%Sanitise extreme values
			rhist(isnan(rhist)) = 0;
			if(T.FPGA_MODE)
				rhist(isinf(rhist)) = T.DATA_SZ-1;
			else
				rhist(isinf(rhist)) = 1;
			end
			%Save this ratio histogram
			rhistBlk{x+1, y+1} = rhist;
			%TODO: Check if we need to normalise here
			%Backproject this block
			bpblk = zeros(size(iblk));
			for k = 1:length(bins)
				if(k == 1)
					idx = bcomp(0, bins(k), img(y_pix, x_pix));
				else
					idx = bcomp(bins(k-1), bins(k), img(y_pix, x_pix));
				end
				bpblk(idx) = rhist(k);
			end
			bpimg(y_pix, x_pix) = bpblk;
		end
	end
	%Compute overall ratio histogram
	rhist = zeros(1, T.N_BINS);
	for x = 1:BLOCKS_X
		for y = 1:BLOCKS_Y
			rhist = rhist + rhistBlk{x,y};
		end
	end
	rhist = rhist ./ max(max(rhist));
	if(T.FPGA_MODE)
		rhist = rhist .* T.DATA_SZ;
	end
	
end 	%hbp_block()
