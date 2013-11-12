function timg = genHueBars(V, opts) %#ok<INUSL>
% GENHUEBARS
% timg = genHueBars(V, opts)
%
% Generate hue test image consisting of vertical bars of increasing hue.
%
%

% Stefan Wong 2013

	timg = repmat(opts.bins, [imsz(2), imsz(1)/length(opts.bins)]);

end 	%genHueBars()
