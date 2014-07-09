function [bpdata rhist_row] = hbp_row(T, img, mhist, varargin)
% HBP_ROW
%
% [bpdata rhist] = hbp_row(T, img, mhist)
%
% Perform histogram backprojection on each row of the image
% 
% ARGUMENTS:
%
% T     -   csSegmenter object
% img   -   Matrix containing image data. This is assumed to be a grayscale hue 
%           image
% mhist -   Model histogram. This must be normalised to the row size to give correct
%           results.
% [OPTIONAL]
% row_len - Pass an argument to varargin to specify the length of the row for 
%           histogram computation.
%
% If the option GEN_BP_VEC is set in the csSegmenter object, bpdata will be returned
% as a 2xN matrix of backprojected data points. Otherwise, bpdata will be a HxW matrix
% of binary values, where H and W are the height and width of the input image
%
% 

% Stefan Wong 2012

	rcomp = @(rl, rh, blk) (blk > rl) & (blk < rh);

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

	[img_h img_w d] = size(img); %#ok
	if(T.rowLen == 0)
		row_len = img_w;
		N_ROWS  = 1;
	else
		row_len = T.rowLen;
		N_ROWS  = fix(T.rowLen / img_w);
	end

	%Get image paramters
	bpimg  = zeros(img_h, img_w, 'uint8');
	if(T.FPGA_MODE)
		bins = (T.DATA_SZ/T.N_BINS) .* (1:T.N_BINS);
	else
		bins = T.DATA_SZ .* (1:T.N_BINS);
	end

	%Normalise ratio histogram to fit block size
	mhist   = hist_norm(mhist, row_len);
    mthresh = fix(T.mhistThresh * row_len);
    mhist(mhist < mthresh) = 0;

	rhistRow = cell(img_w, row_len);
	ihistRow = cell(img_w, row_len);

	% Process rows
	for r = 1:img_h
		ihist_row = zeros(1, T.N_BINS);
		% NOTE : This loop is designed to make it easier to modify the effective
		% buffer size for testing. When the buffer is large enough to hold an entire
		% row, this loop isn't needed, and because this is MATLAB, we don't bother 
		% with the loop at all
		for n = 1 : N_ROWS
			imRow = img(r, (n-1)*row_len+1:n*row_len);
			for k = 1:length(bins)
				if(k == 1)
					pix          = rcomp(0, bins(k), imRow);
					ihist_row(k) = sum(sum(pix));
				else
					pix          = rcomp(bins(k-1), bins(k), imRow);
					ihist_row(k) = sum(sum(pix));
				end
			end
			rhist_row = mhist ./ ihist_row;
			rhist_row(isnan(rhist_row)) = 0;
            rhist_row(isinf(rhist_row)) = 0;
            rhist_row = rhist_row ./ (max(max(rhist_row)));
			bprow = hbp(T, imRow, rhist_row, KDENS, 'offset', [n 0]);
			bpimg(r, (n-1)*row_len+1:n*row_len) = bprow;
			%bpimg(r, :) = bprow;
		end
		%Backproject this row, write backprojection back to image
		%rhist_row = mhist ./ ihist_row;
		%bprow = hbp(T, imRow, rhist_row, KDENS, 'offset', [n 0]);
		%bpimg(r, :) = bprow;
	end
	
	bpimg(bpimg < T.BP_THRESH) = 0;
	if(T.FPGA_MODE)
		bpimg = bpimg ./ (max(max(bpimg))); 	%range - [0 1]
		bpimg = fix(bpimg .* T.kQuant);			%range - [0 kQuant]
	end
	bpdata = bpimg2vec(bpimg, 'bpval');

end 		%hbp_row()
