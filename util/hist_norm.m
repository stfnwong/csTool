function [ohist] = hist_norm(ihist, scale)
% HIST_NORM
% Re-normalise a histogram to fit buffer dimensions in FPGA
% [ohist] = hist_norm(ihist, scale)

% Stefan Wong 2013
%
	hist_max = max(max(ihist));
	ohist = scale .* (ihist./hist_max);

end 	%hist_norm()
