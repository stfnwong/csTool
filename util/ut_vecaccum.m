function moments = ut_vecaccum(bpvec)
% UT_VECACCUM
%
% Test moment accumulation of vector data
%
%

% Stefan Wong 2012

	M00 = length(bpvec);
	M10 = sum(bpvec(1,:));
	M01 = sum(bpvec(2,:));
	M11 = sum(bpvec(1,:) .* bpvec(2,:));
	M20 = sum(bpvec(1,:) .* bpvec(1,:));
	M02 = sum(bpvec(2,:) .* bpvec(2,:));
	moments = [M00 M10 M01 M11 M20 M02];

end 	%ut_vecaccum
