function [moments wparam] = ut_mwinaccum(bpimg, winregion)
% UT_MWINACCUM
%
% [moments wparam] = ut_mwinaccum(bpimg, winregion)
%
% Naive windowed accumulation utility function. This function is intended
% for unit testing csTool internal functions, and is not reccomended for
% production use.
%
% ARGUMENTS:
% bpimg     - Backprojection image
% winregion - 2x2 matrix containing the limits of a bounding box in the
%             form:
%             [xmin xmax ; ymin ymax]
%
%

% Stefan Wong 2012

	%argcheck
	if(size(winregion) ~= [2 2])
		error('Incorrect size in winregion (must be 2x2)');
	end
	xmin    = winregion(1,1);
	xmax    = winregion(1,2);
	ymin    = winregion(2,1);
	ymax    = winregion(2,2);
	
	%Initialise moment sums and accumulate
	M00 = 0;
	M10 = 0;
	M01 = 0;
	M11 = 0;
	M20 = 0;
	M02 = 0;
	for x = xmin:xmax
		for y = ymin:ymax
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
	mu      = moments(2:6)./moments(1);
	u11     = mu(3) - mu(1) * mu(2);
	u20     = mu(4) - mu(1) * mu(1);
	u02     = mu(5) - mu(2) * mu(2);
	sqArg   = 4 * (u11 * u11) + (u20 - u02) * (u20 - u02);
	axmaj   = 0.5 * ((u20 + u02) + sqrt(sqArg));
	axmin   = 0.5 * ((u20 + u02) - sqrt(sqArg));
	theta   = 0.5 * atan((2*u11)/(u20 - u02));
	wparam  = [mu(1) mu(2) theta axmaj axmin];
	
end		%ut_mwinaccum()