function [moments wparam] = vecAccum(T, bpdata, varargin)
% VECACCUM
%
% Vector moment accumulation for camshift tracker
% This file is intended for testing purposes ONLY. The final results of this test 
% should be integrated into the winAccum and imgAccum functions directly
%

% Stefan Wong 2012

	if(nargin > 1)
		fprintf('Optional arguments not yet implemented\n');
	end

	%top 'row' of matrix is x data
	%bottom 'row' of matrix is y data
	N   = length(bpdata);
	M00 = N;
	M10 = sum(bpdata(1,:));
	M01 = sum(bpdata(2,:));
	

end 	%vecAccum()
