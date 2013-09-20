function wparam = wparamCompB(T, moments, varargin)
% WPARAMCOMPB
%
% Bradski equations for window parameter computation
%

% Stefan Wong 2013

	IS_NORM = 0;
	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'norm', 4))
			IS_NORM = 1;
		end
	end

	if(IS_NORM)
		if(length(moments) ~= 5)
			fprintf('ERROR: Incorrect size in parameter [moments]\n');
			wparam = [];
			return;
		end
		xm  = moments(1);
		ym  = moments(2);
		xym = moments(3);
		xxm = moments(4);
		yym = moments(5);
	else
		if(length(moments) ~= 6)
			fprintf('ERROR: Incorrect size in parameter [moments]\n');
			wparam = [];
			return;
		end
		xm  = moments(2) / moments(1);  % M20 / M00
		ym  = moments(3) / moments(1);  % M02 / M00
		xym = moments(4) / moments(1);  % M11 / M00
		xxm = moments(5) / moments(1);  % M20 / M00
		yym = moments(6) / moments(1);  % M02 / M00
	end
	% Bradski-style window parameter calculations
	u11   = 2 * (xym - (xm * ym));
	u20   = xxm - (xm * xm);
	u02   = yym - (ym * ym); 
	sqArg = (u11 * u11) + (u20 -u02) * (u20 - u02);
    axmaj = sqrt( 0.5 * ((u20 + u02) + sqrt(sqArg)));
	axmin = sqrt( 0.5 * ((u20 + u02) - sqrt(sqArg)));

	% Find theta
	if(T.CORDIC_MODE)
		sf   =  (2^32)/360;
		theta = 0.5 * cordic_vecd32((u20 - u02), 2*u11, 32, 0) / sf;
	else
		theta = (180/pi) * 0.5 * atan((2*u11) / (u20 - u02));
	end
	%Format output
	wparam = [xm ym theta axmaj axmin];


end 	%wparamCompB()

