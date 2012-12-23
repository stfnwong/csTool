function [moments wparam] = ut_vecwinaccum(bpvec, winregion)
% UT_VECWINACCUM
%
% [moments wparam] = ut_vecwinaccumm(bpvec, winregion)
%
% Utility function to perform basic windowed accumulation. This function is
% inteded to unit test behaviour within csTool and is not reccomended for
% production use.
%
% ARGUMENTS:
% bpvec     - Backprojection vector 
% winregion - 2x2 matrix containing the limits of a bounding box in the
%             form:
%             [xmin xmax ; ymin ymax]
%
%

% Stefan Wong 2012

	%argcheck
	if(size(winregion) ~= [2 2])
		error('Incorrect matrix size in winregion (must be 2x2)');
	end
	
	xmin = winregion(1,1);
	xmax = winregion(1,2);
	ymin = winregion(2,1);
	ymax = winregion(2,2);
	
	%Initialise and accumulate moments
	M00 = 0;
	M10 = 0;
	M01 = 0;
	M11 = 0;
	M20 = 0;
	M02 = 0;
	for k = 1:length(bpvec)
		if(bpvec(1,k) > xmin && bpvec(1,k) < xmax && ...
		   bpvec(2,k) > ymin && bpvec(2,k) < ymax)
		   M00 = M00 + 1;
		   M10 = M10 + bpvec(1,k);
		   M01 = M01 + bpvec(2,k);
		   M11 = M11 + bpvec(1,k) * bpvec(2,k);
		   M20 = M20 + bpvec(1,k) * bpvec(1,k);
		   M02 = M02 + bpvec(2,k) * bpvec(2,k);
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

end		%ut_vecwinaccum()