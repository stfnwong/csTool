function [moments] = ut_maccum(bpimg, varargin)
% UT_MACCUM
% 
% moments = ut_maccum(bpimg, varargin)
%
% Naive moment accumlator for unit testing. This module accumulates the 5 moments over
% the data in bpimg in two nested loops. This routine is intended for unit testing 
% methods in csTool and is not reccomended for production use.
%
% ARGUMENTS:
% bpimg - Backprojection image to accumlate moments for
%

% Stefan Wong 2012

	[h w d] = size(bpimg);

	%Initialise moment sums
	M00 = 0;
	M10 = 0;
	M01 = 0;
	M11 = 0;
	M20 = 0;
	M02 = 0;
	for y = 1:h
		for x = 1:w
			if(bpimg(y,x) > 0)
				M00 = M00 + 1;
				M10 = M10 + x;
				M01 = M01 + y;
				M11 = M11 + x * y;
				M20 = M20 + x * x;
				M02 = M02 + y * y;
			end
		end
	end
	moments = [M00 M10 M01 M11 M20 M02];

end 	%ut_maccum()
