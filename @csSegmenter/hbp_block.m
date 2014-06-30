function [bpdata rhist] = hbp_block(T, img, mhist, varargin)
% HBP_BLOCK
%
% [bpdata rhist] = hbp_block(T, img, mhist);
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

	%Check for dims parameter
	KDENS = false;
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'kdens', 5))
					xy_prev = varargin{k+1};
					KDENS   = true;
				elseif(strncmpi(varargin{k}, 'bw', 2))
					kbw     = varargin{k+1};		%kernel bandwidth
				elseif(strncmpi(varargin{k}, 'dims', 4))
					dims    = varargin{k+1};
				end
			end
		end
	end

	% If no bandwidth specified, use this default value
	%if(KDENS && ~exist('kbw', 'var'))
	%	kbw = T.KERNEL_BW;
	%end
	%if(exist('xy_prev', 'var'))
	%	if(~isnumeric(xvy_prev))
	%		fprintf('ERROR: Incorrect type for xy_prev, ignoring kernel weighting\n');
	%		KDENS = false;
	%	end
	%end

	%Get image paramters
	
	[img_h img_w d] = size(img);
	if(T.FPGA_MODE)
		bpimg       = zeros(img_h, img_w, 'uint8');
	else
		bpimg           = zeros(img_h, img_w);
	end
	%if(T.FPGA_MODE)
	%	bins = (T.DATA_SZ/T.N_BINS) .* (1:T.N_BINS);
	%else
	%	bins = T.DATA_SZ .* (1:T.N_BINS);
	%end
	bins     = T.N_BINS .* (1:T.N_BINS);
	%Create block memory
	BLK_SZ   = T.BLK_SZ;
	BLOCKS_X = fix(img_w/T.BLK_SZ);
	BLOCKS_Y = fix(img_h/T.BLK_SZ);

	% Save rhist blocks, compute an 'average' rhist at the end
	rhistBlk = cell(BLOCKS_X, BLOCKS_Y);
    ihistBlk = cell(BLOCKS_X, BLOCKS_Y);

	%Normalise ratio histogram to fit block size
	mhist = hist_norm(mhist, BLK_SZ*BLK_SZ);

	for y = 0 : BLOCKS_Y - 1
		for x = 0 : BLOCKS_X - 1
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
			%rhist(isinf(rhist)) = T.DATA_SZ;
			%rhist = T.DATA_SZ .* rhist;		%scale to data size
			%Save this ratio histogram
			rhistBlk{x+1, y+1} = rhist;
            ihistBlk{x+1, y+1} = ihist;
			%Backproject this block, write block results back to 
			%corresponding location in original image.
			bpblk = hbp(T, iblk, rhist, 'offset', [x+1 y+1]); 
			bpimg(y_pix, x_pix) = bpblk;
		end
	end
	%Compute overall ratio histogram, image histogram
	rhist = zeros(1, T.N_BINS);
    ihist = zeros(1, T.N_BINS);
	for x = 1:BLOCKS_X
		for y = 1:BLOCKS_Y
			rhist = rhist + rhistBlk{x,y};
            ihist = ihist + ihistBlk{x,y};
		end
	end
	rhist = rhist ./ max(max(rhist));
    ihist = ihist ./ max(max(ihist));

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
