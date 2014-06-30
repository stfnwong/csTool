function [ohist] = hist_norm(ihist, scale)
% HIST_NORM
% Re-normalise a histogram to fit buffer dimensions in FPGA
% [ohist] = hist_norm(ihist, scale)

% Stefan Wong 2013
%
	%hist_max = max(max(ihist));
	%ohist = scale .* (ihist./hist_max);

	hist_norm = ihist ./ max(max(ihist));
	ohist     = scale .* hist_norm;

end 	%hist_norm()
