function wparam = wparamComp(T, moments, varargin)
% WPARAMCOMP
%
% Compute window parameters from moment sums.
% Moment sums are assumed to be normalised. If moments are not normalised this method
% will give erroneous results

%TODO: Clean up normalisation requirements

% Stefan Wong 2012
	IS_NORM = 0;
	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'norm', 4))
			IS_NORM = 1;
		end
	end
	if(IS_NORM)
		if(length(moments) ~= 5)
			error('Incorrect size in parameter [moments]');
		end
		%Pull moments out of array
		xm  = moments(1);
		ym  = moments(2);
		xym = moments(3);
		xxm = moments(4);
		yym = moments(5);
	else
		if(length(moments) ~= 6)
			error('Incorrect size in parameter [moments]');
		end
		xm  = moments(2) / moments(1);
		ym  = moments(3) / moments(1);
		xym = moments(4) / moments(1);
		xxm = moments(5) / moments(1);
		yym = moments(6) / moments(1);
	end


	%Compute covariance terms
	u11      = xym - (xm * ym);
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
