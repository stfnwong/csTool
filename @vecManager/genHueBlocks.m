function timg = genHueBlocks(V, opts)
% GENHUEBLOCKS
% timg = genHueBlocks(V, opts)
%
% Generate hue test image consisting of blocks of constant hue
%
%
%

% Stefan Wong 2013

	len    = length(opts.bins);
	imline = zeros(len, img_w);
	for n = 1 : len
		imline((n-1)*len+1:n*len) = opts.bins(n);
	end

	timg = repmat(imline, [imsz(2), 1]);
	
end 	%genHueBlocks()
