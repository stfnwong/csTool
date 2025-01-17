function moments = imgAccum(T, bpimg)
% IMGACCUM
%
% Accumulate moment sums over entire image (no tracking window)

% Stefan Wong 2012

	if(T.BP_THRESH > 0)
		[idy idx] = find(bpimg > T.BP_THRESH);
		%M00       = find(bpimg > T.BP_THRESH);
	else
		[idy idx] = find(bpimg > 0);
		%M00       = find(bpimg > 0);
	end
	%Do sanity check
	if(isempty(idx) || isempty(idy))
		error('Image contains no segmented pixels');
	end
	M00     = length(idx);
	M10     = sum(idx);
	M01     = sum(idy);
	M11     = sum(idx .* idy);
	M20     = sum(idx .* idx);
	M02     = sum(idy .* idy);
	moments = [M00 M10 M01 M11 M20 M02];
% 	xm      = M10 / M00;
% 	ym      = M01 / M00;
% 	xym     = M11 / M00;
% 	xxm     = M20 / M00;
% 	yym     = M02 / M00;
% 	moments = [xm ym xym xxm yym];


end 	%imgAccum()

