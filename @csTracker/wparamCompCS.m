function wparam = wparamCompCS(T, moments, varargin) %#ok
% WPARAMCOMPCS
% wparam = wparamCompCS(T, moments, [..OPTIONS..])
%
% CAMSHIFT adaptive window parameter computation.
% The method here is taken from the French Wikipedia page on CAMSHIFT
%

% Stefan Wong 2013

	% Get more convenient notation for moments
	zm    = moments(1);
	xm    = moments(2);
	ym    = moments(3);
	xym   = moments(4);
	xxm   = moments(5);
	yym   = moments(6);	
	xc    = xm / zm;
	yc    = ym / zm;

	% mu(i,j) = sum((x-xc)^i (y-yc)^j I(x,y))

	u11    = 2 * (xym - (xm * ym));
	u20    = xxm - (xm * xm);
	u02    = yym - (ym * ym); 
	uDiff  = abs(u20 - u02);
	%uSum   = u20 + u02;
	thArg  = uDiff - sqrt(4*u11^2 + uDiff * uDiff);
	theta  = atan2(2*u11, thArg);
	eArg   = 2 * u11 * cos(theta) * sin(theta);
	imax   = u20 * (cos(theta) * cos(theta)) + eArg + u02 * (sin(theta) * sin(theta));
	imin   = u20 * (sin(theta) * sin(theta)) - eArg + u02 * (cos(theta) * cos(theta));
	axmaj  = 4 * sqrt(imax / zm);
	axmin  = 4 * sqrt(imin / zm);
	% Project ellipse back onto a rectangle
	w      = max(axmaj * cos(theta), axmin * sin(theta));
	h      = max(axmaj * sin(theta), axmin * cos(theta));

	wparam = [xc yc theta w h];

end 	%wparamCompCS()
