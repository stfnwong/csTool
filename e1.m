function [X Y] = calcEllipse(x,y,a,b,ang,steps)
% This function returns points to draw an ellipse (courtesy Amro, Stackoverflow)
%
% x   - x coord
% y   - y coord
% a   - semimajor axis
% b   - semiminor axis
% ang - angle of ellipse (degrees)
%

	error(nargchk(5,6,nargin))
	if(nargin < 6)
		steps = 36;
	end

	phi   = -angle * (pi/180);
	sp    = sin(phi);
	cp    = cos(phi);
	alpha = linspace(0, 360, steps)' .* (pi/180);
	sa    = sin(alpha);
	ca    = cos(alpha);

	X     = x + (a * ca * cp - b * sa * sp);
	Y     = y + (a * ca * sp + b * sa * cp);
	if(nargout == 1)
		X = [X Y];
	end

end 
	
