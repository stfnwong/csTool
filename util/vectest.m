% SCRIPT TO TEST VECTOR ACCUMULATOR
%Get bpvec, then format a high and low vector for find. In order to use the find
%command to get a list of valid points, we make a high and low vector of the same size
%as the bpvec and then index this back into the bpvec
%

%Call utility functions to setup environment
[img hsvimg hueimg] = ut_getimg('data/assets/frames/2g1ctest_011.tif');
mhist = ut_genmhist(hueimg, 'default');
[bpimg rhist] = ut_hbp(hueimg, mhist);
bpvec = bpimg2vec(bpimg);

%Change these values at will
xlim = [230 294]; 		
ylim = [156 220];

%Get the high and low limits as xlim, ylim
rlow  = repmat([xlim(1) ylim(1)]', [1 length(bpvec)]);
rhigh = repmat([xlim(2) ylim(2)]', [1 length(bpvec)]);

%[ry rx] = find(bpvec > rlow & bpvec < rhigh);
%winvec  = bpvec(:,rx);
winvec = bpvec(bpvec >= rlow & bpvec <= rhigh);

% format table of moments and print to console
imoments = ut_maccum(bpimg);
vmoments = ut_vecaccum(bpvec);
rmoments = ut_maccum(bpimg(ylim(1):ylim(2), xlim(1):xlim(2)));
rvmoments = ut_vecaccum(bpvec(:,winvec));
rlmoments = ut_vecloopaccum(bpvec(:,winvec));
rrmoments = ut_vecloopaccum(bpvec, 'region', [xlim ; ylim]);	
mstr = {'M00', 'M10', 'M01', 'M11', 'M20', 'M02'};

fprintf('MOMENT SUMS:\n');
fprintf('Moments over backprojection image (loops)\n');
for k = 1:length(imoments)
	fprintf('%s : %14d\n', mstr{k}, imoments(k));
end
fprintf('\n');
fprintf('Moments over backprojection image (vector)\n');
for k = 1:length(vmoments)
	fprintf('%s : %14d\n', mstr{k}, vmoments(k));
end
fprintf('\n');
fprintf('Moments over backprojection region (loops)\n');
for k = 1:length(rmoments)
	fprintf('%s : %14d\n', mstr{k}, rmoments(k));
end
fprintf('\n');
fprintf('Moments over backprojection region (rx, ry, winvec)\n');
for k = 1:length(rvmoments)
	fprintf('%s : %14d\n', mstr{k}, rvmoments(k));
end
fprintf('END SCRIPT\n');
