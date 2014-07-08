function [bpdata rhist] = hbp_block_spatial(T, img, mhist, wparam)
% HBP_BLOCK_SPATIAL
%
% [bpdata rhist] = hbp_block_spatial(T, img, mhist, wparam, varargin)
%
% Perform block-wise histogram backprojeciton on img using model histogram specified
% in mhist. 
% ARGUMENTS:
% 
% T     - csSegmenter object
% img   - Matrix containing image data. This is assumed to be a grayscale hue image
% mhist - Model histogram 
% 
% If the option GEN_BP_VEC is set in the csSegmenter object, bpdata will be returned
% as a 2xN matrix of backprojected data points. Otherwise, bpdata will be a HxW matrix
% of binary values, where H and W are the height and width of the input image.


% TODO: Clean up documentation

% Stefan Wong 2012

	%Create function handle to do block compares inside loop
	bcomp = @(rl, rh, blk) (blk > rl) & (blk < rh);

	%Get image paramters
	[img_h img_w d] = size(img); %#ok
	if(T.FPGA_MODE)
		bpimg = zeros(img_h, img_w, 'uint8');
	else
		bpimg = zeros(img_h, img_w);
	end
	bins     = T.N_BINS .* (1:T.N_BINS);
	%Create block memory
	BLK_SZ   = T.BLK_SZ;
	BLOCKS_X = fix(img_w/T.BLK_SZ);
	BLOCKS_Y = fix(img_h/T.BLK_SZ);

	% Save rhist blocks, compute an 'average' rhist at the end
	rhistBlk = cell(BLOCKS_X, BLOCKS_Y);
    ihistBlk = cell(BLOCKS_X, BLOCKS_Y);

	%Normalise ratio histogram to fit block size
	mhist   = hist_norm(mhist, BLK_SZ*BLK_SZ);
    mthresh = fix(T.mhistThresh * BLK_SZ*BLK_SZ);
    mhist(mhist < mthresh) = 0;
	
	% Compute window boundaries
	xmin = wparam(1) - wparam(4) - T.WIN_REGION(1);
	xmax = wparam(1) + wparam(4) + T.WIN_REGION(1);
	ymin = wparam(2) - wparam(5) - T.WIN_REGION(2);
	ymax = wparam(2) + wparam(5) + T.WIN_REGION(2);
	if(xmin < 1)
		xmin = 1;
	end
	if(xmax > img_w)
		xmax = img_w;
	end
	if(ymin < 1)
		ymin = 1;
	end
	if(ymax > img_h)
		ymax = img_h;
	end

	for y = 0 : BLOCKS_Y - 1
		for x = 0 : BLOCKS_X - 1
			% TODO : Dont bother to compute this unless we are sufficiently close to the positon in wparam. Sufficiently close is defined by the parameter T.WIN_REGION
			if((x*BLK_SZ >= xmin && x*BLK_SZ <= xmax) && (y*BLK_SZ >= ymin && y*BLK_SZ <= ymax))
				ihist = zeros(1, T.N_BINS);
				x_pix  = (x*BLK_SZ)+1 : (x+1)*BLK_SZ;
				y_pix  = (y*BLK_SZ)+1 : (y+1)*BLK_SZ;
				iblk   = img(y_pix, x_pix);
				% TODO : Does this need to be done for each row?
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
				rhist(isinf(rhist)) = 0;
				rhist = rhist ./ (max(max(rhist)));
				%Save this ratio histogram
				rhistBlk{x+1, y+1} = rhist;
				ihistBlk{x+1, y+1} = ihist;
				%Backproject this block, write block results back to 
				%corresponding location in original image.
				bpblk = hbp(T, iblk, rhist, 'offset', [x+1 y+1]); 
				bpimg(y_pix, x_pix) = bpblk;
			end
		end
	end
	%Compute overall ratio histogram, image histogram
	rhist = zeros(1, T.N_BINS);
    ihist = zeros(1, T.N_BINS);
	% TODO : put this back
	%for x = 1:BLOCKS_X
	%	for y = 1:BLOCKS_Y
	%		rhist = rhist + rhistBlk{x,y};
    %        ihist = ihist + ihistBlk{x,y};
	%	end
	%end
	%rhist = rhist ./ max(max(rhist));
    %ihist = ihist ./ max(max(ihist));

	bpimg(bpimg < T.BP_THRESH) = 0;
	if(T.FPGA_MODE)
		bpimg = bpimg ./ (max(max(bpimg))); 	%range - [0 1]
		bpimg = fix(bpimg .* T.kQuant);
	end


    bpdata = bpimg2vec(bpimg, 'bpval');

	% TODO : Check this
	%if(T.kQuant == 1)
	%	bpdata = bpimg2vec(bpimg);
	%else
	%	bpdata = bpimg2vec(bpimg, 'bpval');
	%end
	
	
end 	%hbp_block()
