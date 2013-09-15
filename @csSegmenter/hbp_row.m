function [bpdata rhist] = hbp_row(T, img, mhist, varargin)
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

	[img_h img_w d] = size(img);
	%See if we have a row option
	if(~isempty(varargin))
		row_len = varargin{1};
		N_ROWS  = fix(row_len / img_w);
	else
		row_len = img_w;
		N_ROWS  = 1;
	end

	%Get image paramters
	bpimg  = zeros(img_h, img_w, 'uint8');
	imhist = zeros(1,T.N_BINS);
	if(T.FPGA_MODE)
		bins = (T.DATA_SZ/T.N_BINS) .* (1:T.N_BINS);
	else
		bins = T.DATA_SZ .* (1:T.N_BINS);
	end

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
					pix      = bcomp(0, bins(k), imRow);
					ihist(k) = sum(sum(pix));
				else
					pix      = bcomp(bins(k-1), bins(k), imRow);
					ihist(k) = sum(sum(pix));
				end
			end
		end
		%Backproject this row
	end

	%for r = 1:img_h
	%	ihist = zeros(1, T.N_BINS);
	%	imRow = img(r, 1:row_len);
	%	for k = 1:length(bins)
	%		if(k == 1)
	%			pix      = bcomp(0, bins(k), imRow);
	%			ihist(k) = sum(sum(pix));
	%		else
	%			pix      = bcomp(bins(k-1), bins(k), imRow);
	%			ihist(k) = sum(sum(pix));
	%		end
	%	end
	%	%Backproject this row
	%	rhrow = zeros(1, T.N_BINS);
	%end

	%Convert to bpvec, if required
	if(GEN_BP_VEC)
		bpdata = bpimg2vec(bpimg);
	else
		bpdata = bpimg;
	end
		



end 		%hbp_row()
