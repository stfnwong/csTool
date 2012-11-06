function [bpimg rhist] = hbp_row(T, img, mhist)
% HBP_ROW
%
% Perform histogram backprojection on each row of the image
% TODO: Finish documentation

% Stefan Wong 2012

	rcomp = @(rl, rh, blk) (blk > rl) & (blk < rh);

	%Get image paramters
	[img_h img_w d] = size(img);
	bpimg           = zeros(img_h, img_w);
	imhist          = zeros(1:T.N_BINS);
	if(T.FPGA_MODE)
		bins = (T.DATA_SZ/T.N_BINS) .* (1:T.N_BINS);
	else
		bins = T.DATA_SZ .* (1:T.N_BINS);
	end

	for r = 1:img_h
		ihist = zeros(1, T.N_BINS);
		imRow = img(r, 1:end);
		for k = 1:length(bins)
			if(k == 1)
				pix      = bcomp(0, bins(k), imRow);
				ihist(k) = sum(sum(pix));
			else
				pix      = bcomp(bins(k-1), bins(k), imRow);
				ihist(k) = sum(sum(pix));
			end
		end
		%Backproject this row
	end
		



end 		%hbp_row()