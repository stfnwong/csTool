function wparam = wparamComp(T, moments)
% WPARAMCOMP
%
% Compute window parameters from moment sums.
% Moment sums are assumed to be normalised. If moments are not normalised this method
% will give erroneous results

% Stefan Wong 2012

	%Pull moments out of array
	xm  = moments(1);
	ym  = moments(2);
	xym = moments(3);
	xxm = moments(4);
	yym = moments(5);

	%Compute covariance terms
	u11      = xym - (xm * xm);
	u20      = xxm - (xm * xm);
	u02      = yym - (ym * ym);
	%Compute eigenvector termsa
	mu2_sum  = u20 + u02;
	mu2_diff = u20 - u02;
	sqArg    = 4 * (u11 * u11) + (mu2_diff * mu2_diff);
	axmaj    = 0.5 * (mu2_sum + sqrt(sqArg));
	axmin    = 0.5 * (mu2_sum - sqrt(sqArg));
	%Find theta
	if(T.CORDIC_MODE)
		sf    = (2^32)/360;
		theta = 0.5 * (cordic_vecd32(mu2_diff, 2*u11, 32, 0) / sf);
	else
		theta = (180/pi) * 0.5 * atan((2*u11)/mu2_diff);
	end
	%Format output
	wparam = [xm ym theta axmaj axmin];

end 	%wparamComp()
